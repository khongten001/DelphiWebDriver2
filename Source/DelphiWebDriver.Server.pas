{
  ------------------------------------------------------------------------------
  Author: ABDERRAHMANE
  Github: https://github.com/DA213/DelphiWebDriver
  ------------------------------------------------------------------------------
}

unit DelphiWebDriver.Server;

interface

uses
  System.SysUtils,
  Winapi.Windows;

type
  TWebDriverServer = class
  private
    FProcessInfo: TProcessInformation;
    FStarted: Boolean;
    FExePath: string;
  public
    constructor Create(const AExePath: string);
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    property Started: Boolean read FStarted;
  end;

implementation

{ TWebDriverServer }

constructor TWebDriverServer.Create(const AExePath: string);
begin
  inherited Create;
  FExePath := AExePath;
  FStarted := False;
end;

destructor TWebDriverServer.Destroy;
begin
  Stop;
  inherited;
end;

procedure TWebDriverServer.Start;
var
  StartupInfo: TStartupInfo;
  CmdLine: string;
begin
  if FStarted then Exit;
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  ZeroMemory(@FProcessInfo, SizeOf(FProcessInfo));
  CmdLine := '"' + FExePath + '" --port=9515';
  if CreateProcess(nil, PChar(CmdLine), nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, StartupInfo, FProcessInfo) then
  begin
    FStarted := True;
    Sleep(800);
  end
  else
    raise Exception.Create('Failed to start ChromeDriver. Error: ' + SysErrorMessage(GetLastError));
end;

procedure TWebDriverServer.Stop;
begin
  if not FStarted then Exit;
  if WaitForSingleObject(FProcessInfo.hProcess, 1500) = WAIT_TIMEOUT then
    TerminateProcess(FProcessInfo.hProcess, 0);
  if FProcessInfo.hProcess <> 0 then
    CloseHandle(FProcessInfo.hProcess);
  if FProcessInfo.hThread <> 0 then
    CloseHandle(FProcessInfo.hThread);
  FStarted := False;
end;

end.

