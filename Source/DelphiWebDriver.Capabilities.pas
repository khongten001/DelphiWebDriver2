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
    property BrowserName: string read FBrowserName write FBrowserName;
    function ToJSON: TJSONObject;
  end;

implementation

function TWebDriverCapabilities.ToJSON: TJSONObject;
var
  FirstMatchArray: TJSONArray;
begin
  if FBrowserName = '' then
    raise Exception.Create('BrowserName cannot be empty');

  FirstMatchArray := TJSONArray.Create;
  FirstMatchArray.Add(TJSONObject.Create);

  Result := TJSONObject.Create;
  Result.AddPair('capabilities',
    TJSONObject.Create
      .AddPair('firstMatch', FirstMatchArray)
      .AddPair('alwaysMatch',
        TJSONObject.Create.AddPair('browserName', FBrowserName))
  );
end;

end.

