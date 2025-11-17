{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Capabilities;

interface

uses
  System.SysUtils,
  System.JSON;

type
  TWebDriverCapabilities = class
  private
    FBrowserName: string;
  public
    constructor Create;
    property BrowserName: string read FBrowserName write FBrowserName;

    function ToJSON: TJSONObject;
  end;

implementation

{ TWebDriverCapabilities }

constructor TWebDriverCapabilities.Create;
begin
  inherited;
end;

function TWebDriverCapabilities.ToJSON: TJSONObject;
var
  FirstMatchArray: TJSONArray;
  AlwaysObj, EdgeOptions: TJSONObject;
begin
  if FBrowserName = '' then
    raise Exception.Create('BrowserName cannot be empty');

  FirstMatchArray := TJSONArray.Create;
  FirstMatchArray.Add(TJSONObject.Create);

  AlwaysObj := TJSONObject.Create;
  AlwaysObj.AddPair('browserName', FBrowserName);

  if SameText(FBrowserName, 'edge') then
  begin
    EdgeOptions := TJSONObject.Create;
    EdgeOptions.AddPair('args', TJSONArray.Create);
    AlwaysObj.AddPair('ms:edgeOptions', EdgeOptions);
  end;

  Result := TJSONObject.Create;
  Result.AddPair('capabilities',
    TJSONObject.Create
      .AddPair('firstMatch', FirstMatchArray)
      .AddPair('alwaysMatch', AlwaysObj)
  );
end;

end.

