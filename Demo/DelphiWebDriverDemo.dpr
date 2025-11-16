program DelphiWebDriverDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  DelphiWebDriverDemo.Main in 'DelphiWebDriverDemo.Main.pas' {MainForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
