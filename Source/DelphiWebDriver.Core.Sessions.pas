{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Core.Sessions;

interface

uses
  System.JSON,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types;

type
  TWebDriverSessions = class(TInterfacedObject, IWebDriverSessions)
  private
    [weak]
    FDriver: IWebDriver;
    FSessionId: string;
    FWindowHandle: string;
  public
    constructor Create(ADriver: IWebDriver);
    function StartSession: string;
    procedure Quit;
    function GetSessionId: string;
    function GetWindowHandle: string;
  end;

implementation

{ TWebDriverSessions }

constructor TWebDriverSessions.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
end;

function TWebDriverSessions.GetWindowHandle: string;
begin
  Result := FWindowHandle;
end;

function TWebDriverSessions.GetSessionId: string;
begin
  Result := FSessionId;
end;

procedure TWebDriverSessions.Quit;
begin
  if FSessionId <> '' then
    FDriver.Commands.SendCommand('DELETE', '/session/' + FSessionId).Free;
end;

function TWebDriverSessions.StartSession: string;
var
  LCapObj: TJSONObject;
  LRes: TJSONValue;
  LSessionObj: TJSONObject;
begin
  LCapObj := nil;
  try
    LCapObj := FDriver.Capabilities.ToJSON;
    LRes := FDriver.Commands.SendCommand('POST', '/session', LCapObj);
    try
      LSessionObj := LRes.GetValue<TJSONObject>('value');
      if not Assigned(LSessionObj) then
        raise EWebDriverError.Create('No value object returned from WebDriver');

      if LSessionObj.TryGetValue<string>('sessionId', FSessionId) then
        begin
          Result := FSessionId;
          FWindowHandle := FDriver.Contexts.GetWindowHandle;
        end
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

end.
