unit DelphiWebDriverDemo.Main;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls;

type
  TMainForm = class(TForm)
    StartChromeButton: TButton;
    procedure StartChromeButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  DelphiWebDriver.Core,
  DelphiWebDriver.Types,
  DelphiWebDriver.Capabilities,
  DelphiWebDriver.Server,
  DelphiWebDriver.Interfaces;

{$R *.fmx}

procedure TMainForm.StartChromeButtonClick(Sender: TObject);
var
  Server: TWebDriverServer;
  Driver: IWebDriver;
  Caps: TWebDriverCapabilities;
  TranslateBox: IWebElement;
begin
  Server := TWebDriverServer.Create('chromedriver.exe');
  try
    Server.Start; // launch ChromeDriver

    Driver := TWebDriver.Create('http://localhost:9515');
    try
      Caps := TWebDriverCapabilities.Create;
      try
        Caps.BrowserName := 'chrome';
        Driver.StartSession(Caps);
      finally
        Caps.Free;
      end;

      Driver.Navigate('https://translate.google.com/');

      // Wait for translate box and send text
      TranslateBox := Driver.WaitUntilElement(TBy.XPath('//*[@id="yDmH0d"]/c-wiz/div/div[2]/c-wiz/div[2]/c-wiz/div[1]/div[2]/div[2]/div/c-wiz/span/span/div/textarea'));
      TranslateBox.SendKeys('Hello from DelphiWebDriver!');

      // Take screenshot
      Driver.SaveScreenshotToFile('screenshot.png');

    finally
      Driver.Quit;
    end;
  finally
    Server.Stop;
    Server.Free;
  end;
end;

end.
