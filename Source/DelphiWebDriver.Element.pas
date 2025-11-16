unit DelphiWebDriver.Element;

interface

uses
  System.SysUtils,
  System.JSON,
  DelphiWebDriver.Interfaces;

type
  TWebElement = class(TInterfacedObject, IWebElement)
  private
    FDriver: IWebDriver;
    FElementId: string;
  public
    constructor Create(ADriver: IWebDriver; const AElementId: string);
    function GetElementId: string;
    procedure Click;
    procedure SendKeys(const Text: string);
    procedure Submit;
    function GetText: string;
    function GetAttribute(const Attr: string): string;
  end;

implementation

constructor TWebElement.Create(ADriver: IWebDriver; const AElementId: string);
begin
  inherited Create;
  FDriver := ADriver;
  FElementId := AElementId;
end;

function TWebElement.GetElementId: string;
begin
  Result := FElementId;
end;

procedure TWebElement.Click;
begin
  FDriver.SendCommand('POST', '/session/' + FDriver.GetSessionId +
    '/element/' + FElementId + '/click', TJSONObject.Create).Free;
end;

procedure TWebElement.SendKeys(const Text: string);
var
  Body: TJSONObject;
begin
  Body := TJSONObject.Create;
  try
    Body.AddPair('text', Text);
    FDriver.SendCommand('POST', '/session/' + FDriver.GetSessionId +
      '/element/' + FElementId + '/value', Body).Free;
  finally
    Body.Free;
  end;
end;

procedure TWebElement.Submit;
begin
  FDriver.SendCommand('POST', '/session/' + FDriver.GetSessionId +
    '/element/' + FElementId + '/submit', TJSONObject.Create).Free;
end;

function TWebElement.GetText: string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET', '/session/' + FDriver.GetSessionId +
    '/element/' + FElementId + '/text');
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

function TWebElement.GetAttribute(const Attr: string): string;
var
  JSON: TJSONValue;
begin
  JSON := FDriver.SendCommand('GET', '/session/' + FDriver.GetSessionId +
    '/element/' + FElementId + '/attribute/' + Attr);
  try
    Result := JSON.GetValue<string>('value');
  finally
    JSON.Free;
  end;
end;

end.

