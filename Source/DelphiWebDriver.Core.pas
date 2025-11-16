unit DelphiWebDriver.Core;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  System.JSON,
  System.Generics.Collections,
  System.DateUtils,
  System.NetEncoding,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types,
  DelphiWebDriver.Capabilities,
  DelphiWebDriver.Element,
  DelphiWebDriver.Cookies;

type
  EWebDriverError = class(Exception);

  TWebDriver = class(TInterfacedObject, IWebDriver)
  private
    FHTTP: THTTPClient;
    FSessionId: string;
    FBaseUrl: string;
    FCookies: IWebDriverCookies;
  public
    constructor Create(const ABaseUrl: string); virtual;
    destructor Destroy; override;
    function StartSession(Capabilities: TWebDriverCapabilities): string;
    procedure Quit;
    function FindElement(By: TBy): IWebElement;
    function FindElements(By: TBy): TArray<IWebElement>;
    function SendCommand(const Method, Endpoint: string; Body: TJSONObject = nil): TJSONValue;
    function GetSessionId: string;
    procedure Navigate(const Url: string);
    function GetTitle: string;
    function GetCurrentUrl: string;
    procedure Back;
    procedure Forward;
    procedure Refresh;
    procedure SwitchToFrameElement(const Element: IWebElement);
    procedure SwitchToFrame(const FrameName: string);
    procedure SwitchToDefaultContent;
    function Cookies: IWebDriverCookies;
    function TakeScreenshot: TBytes;
    procedure SaveScreenshotToFile(const FileName: string);
    function WaitUntilElement(By: TBy; TimeoutMS: Integer = 5000; IntervalMS: Integer = 200): IWebElement;
  end;

implementation

{ TWebDriver }

constructor TWebDriver.Create(const ABaseUrl: string);
begin
  inherited Create;
  FBaseUrl := ABaseUrl;
  FHTTP := THTTPClient.Create;
end;

destructor TWebDriver.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

function TWebDriver.WaitUntilElement(By: TBy; TimeoutMS, IntervalMS: Integer) : IWebElement;
var
  ElemTemp: IWebElement;
  StartTime: TDateTime;
begin
  ElemTemp := nil;
  StartTime := Now;
  while MilliSecondsBetween(Now, StartTime) < TimeoutMS do
  begin
    try
      ElemTemp := FindElement(By);
      if Assigned(ElemTemp) then
      begin
        Result := ElemTemp;
        Exit;
      end;
    except
      ElemTemp := nil;
    end;
    Sleep(IntervalMS);
  end;
  Result := nil;
end;

procedure TWebDriver.SwitchToFrame(const FrameName: string);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', TJSONString.Create(FrameName));
    SendCommand('POST', '/session/' + FSessionId + '/frame', JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWebDriver.SwitchToDefaultContent;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', TJSONNull.Create);
    SendCommand('POST', '/session/' + FSessionId + '/frame', JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWebDriver.SwitchToFrameElement(const Element: IWebElement);
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', TJSONObject.Create.AddPair('ELEMENT', Element.ElementId)
      .AddPair('element-6066-11e4-a52e-4f735466cecf', Element.ElementId));
    SendCommand('POST', '/session/' + FSessionId + '/frame', JSON);
  finally
    JSON.Free;
  end;
end;

function TWebDriver.SendCommand(const Method, Endpoint: string; Body: TJSONObject): TJSONValue;
var
  LUrl: string;
  LResponse: IHTTPResponse;
  Stream: TStringStream;
begin
  LUrl := FBaseUrl + Endpoint;
  Stream := nil;
  try
    if Assigned(Body) then
      Stream := TStringStream.Create(Body.ToJSON, TEncoding.UTF8);

    if Method = 'POST' then
      LResponse := FHTTP.Post(LUrl, Stream)
    else if Method = 'DELETE' then
      LResponse := FHTTP.Delete(LUrl)
    else
      LResponse := FHTTP.Get(LUrl);

    Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString);
    if not Assigned(Result) then
      raise EWebDriverError.Create
        ('Invalid JSON response received from WebDriver');
  finally
    Stream.Free;
  end;
end;

function TWebDriver.StartSession(Capabilities: TWebDriverCapabilities): string;
var
  LCapObj: TJSONObject;
  LRes: TJSONValue;
  LSessionObj: TJSONObject;
begin
  LCapObj := nil;
  try
    LCapObj := Capabilities.ToJSON;
    LRes := SendCommand('POST', '/session', LCapObj);
    try
      LSessionObj := LRes.GetValue<TJSONObject>('value');
      if not Assigned(LSessionObj) then
        raise EWebDriverError.Create('No value object returned from WebDriver');

      if LSessionObj.TryGetValue<string>('sessionId', FSessionId) then
        Result := FSessionId
      else
        raise EWebDriverError.Create('SessionId not found in response: ' +
          LRes.ToString);
    finally
      LRes.Free;
    end;
  finally
    LCapObj.Free;
  end;
end;

procedure TWebDriver.Quit;
begin
  if FSessionId <> '' then
    SendCommand('DELETE', '/session/' + FSessionId).Free;
end;

function TWebDriver.GetSessionId: string;
begin
  Result := FSessionId;
end;

function TWebDriver.FindElement(By: TBy): IWebElement;
var
  Body: TJSONObject;
  LRes: TJSONValue;
  ElemObj: TJSONObject;
  ElemId: string;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('using', By.Strategy);
    Body.AddPair('value', By.Value);

    LRes := SendCommand('POST', '/session/' + FSessionId + '/element', Body);
    try
      ElemObj := LRes.GetValue<TJSONObject>('value');
      if not Assigned(ElemObj) then
        raise EWebDriverError.Create('No element object returned');

      if not ElemObj.TryGetValue<string>('element-6066-11e4-a52e-4f735466cecf',
        ElemId) then
      begin
        ElemId := ElemObj.GetValue<string>('ELEMENT');
      end;

      Result := TWebElement.Create(Self as IWebDriver, ElemId);
    finally
      LRes.Free;
    end;
  finally
    Body.Free;
  end;
end;

function TWebDriver.FindElements(By: TBy): TArray<IWebElement>;
var
  Body: TJSONObject;
  LRes: TJSONValue;
  Arr: TJSONArray;
  Item: TJSONValue;
  ElemObj: TJSONObject;
  ElemId: string;
  List: TList<IWebElement>;
begin
  Body := TJSONObject.Create;
  List := TList<IWebElement>.Create;
  try
    Body.AddPair('using', By.Strategy);
    Body.AddPair('value', By.Value);

    LRes := SendCommand('POST', '/session/' + FSessionId + '/elements', Body);
    try
      Arr := LRes.GetValue<TJSONArray>('value');
      for Item in Arr do
      begin
        ElemObj := Item as TJSONObject;
        if not ElemObj.TryGetValue<string>
          ('element-6066-11e4-a52e-4f735466cecf', ElemId) then
          ElemId := ElemObj.GetValue<string>('ELEMENT');
        List.Add(TWebElement.Create(Self as IWebDriver, ElemId));
      end;
      Result := List.ToArray;
    finally
      LRes.Free;
    end;
  finally
    Body.Free;
    List.Free;
  end;
end;

procedure TWebDriver.Navigate(const Url: string);
var
  B: TJSONObject;
begin
  B := TJSONObject.Create;
  try
    B.AddPair('url', Url);
    SendCommand('POST', '/session/' + FSessionId + '/url', B).Free;
  finally
    B.Free;
  end;
end;

function TWebDriver.GetTitle: string;
var
  L: TJSONValue;
begin
  L := SendCommand('GET', '/session/' + FSessionId + '/title');
  try
    Result := L.GetValue<string>('value');
  finally
    L.Free;
  end;
end;

function TWebDriver.GetCurrentUrl: string;
var
  L: TJSONValue;
begin
  L := SendCommand('GET', '/session/' + FSessionId + '/url');
  try
    Result := L.GetValue<string>('value');
  finally
    L.Free;
  end;
end;

procedure TWebDriver.Back;
begin
  SendCommand('POST', '/session/' + FSessionId + '/back',
    TJSONObject.Create).Free;
end;

procedure TWebDriver.Forward;
begin
  SendCommand('POST', '/session/' + FSessionId + '/forward',
    TJSONObject.Create).Free;
end;

procedure TWebDriver.Refresh;
begin
  SendCommand('POST', '/session/' + FSessionId + '/refresh',
    TJSONObject.Create).Free;
end;

function TWebDriver.Cookies: IWebDriverCookies;
begin
  if FCookies = nil then
    FCookies := TWebDriverCookies.Create(Self as IWebDriver);
  Result := FCookies;
end;

function TWebDriver.TakeScreenshot: TBytes;
var
  L: TJSONValue;
  Base64Str: string;
begin
  L := SendCommand('GET', '/session/' + FSessionId + '/screenshot');
  try
    Base64Str := L.GetValue<string>('value');
    Result := TNetEncoding.Base64.DecodeStringToBytes(Base64Str);
  finally
    L.Free;
  end;
end;

procedure TWebDriver.SaveScreenshotToFile(const FileName: string);
var
  Bytes: TBytes;
  FS: TFileStream;
begin
  Bytes := TakeScreenshot;
  FS := TFileStream.Create(FileName, fmCreate);
  try
    FS.WriteBuffer(Bytes[0], Length(Bytes));
  finally
    FS.Free;
  end;
end;

end.
