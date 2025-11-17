# DelphiWebDriver

A modern, lightweight Delphi client (No third party) for the W3C WebDriver protocol (the same protocol used by Selenium). This library allows Delphi developers to automate browsers such as Chrome, Firefox, and Edge by communicating with their corresponding WebDriver executables.

---

## ✨ Features

* Create and manage WebDriver sessions
* Navigate to URLs
* Locate elements (`By.Id`, `By.Name`, `By.ClassName`, `By.CSS`, `By.XPath`...)
* Click elements, send keys, submit forms
* Take screenshots and save to file
* Wait for elements to appear or conditions to be true
* Manage cookies, frames
* Interface-based memory management for stability
* Cross-browser support (Chrome, Firefox, Edge) 
* headless mode support (Chrome, Firefox, Edge)
* And more cool stuff is coming...

---

## 📁 Project Structure

```
/DelphiWebDriver
  /Source
    DelphiWebDriver.Core.pas
    DelphiWebDriver.Element.pas
    DelphiWebDriver.Interfaces.pas
    DelphiWebDriver.Types.pas
    DelphiWebDriver.Capabilities.pas
    DelphiWebDriver.Server.pas
    DelphiWebDriver.Cookies.pas
  /Demo
    DelphiWebDriverDemo.Main.pas
    DelphiWebDriverDemo.Main.fmx
  README.md
  LICENSE
```

> `Source/` contains the core library units
> `Demo/` contains a small FMX demo showing Chrome automation

---

## 🚀 Getting Started

### Requirements

* Delphi 10.2+ (or any recent version)
* Corresponding WebDriver binaries:  

  * ChromeDriver - Chrome (download from here https://developer.chrome.com/docs/chromedriver/downloads)
  * GeckoDriver - Firefox (download from here https://github.com/mozilla/geckodriver/releases)
  * MSEdgeDriver - Edge (download from here https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver)

Place the driver executable next to your application.

---

### Example Usage

```delphi
uses
  DelphiWebDriver.Core,
  DelphiWebDriver.Types,
  DelphiWebDriver.Capabilities,
  DelphiWebDriver.Server,
  DelphiWebDriver.Interfaces;

procedure TMainForm.StartDriverButtonClick(Sender: TObject);
var
  Server: TWebDriverServer;
  Driver: IWebDriver;
  Caps: TWebDriverCapabilities;
begin
  var DriverName := '';
  var BrowserName := '';
  if ChromeRadioButton.IsChecked then
    begin
      DriverName  := TBrowser.Chrome.DriverName;
      BrowserName := TBrowser.Chrome.Name;
    end;
  if FirefoxRadioButton.IsChecked then
    begin
      DriverName  := TBrowser.Firefox.DriverName;
      BrowserName := TBrowser.Firefox.Name;
    end;
  if EdgeRadioButton.IsChecked then
    begin
      DriverName  := TBrowser.Edge.DriverName;
      BrowserName := TBrowser.Edge.Name;
    end;

  if DriverName.IsEmpty then
    begin
      LogsMemo.Text := 'You must select driver';
      Exit;
    end;

  Server := TWebDriverServer.Create(DriverName);
  try
    Server.Start;
    Driver := TWebDriver.Create('http://localhost:9515');
    try
      Caps := TWebDriverCapabilities.Create;
      try
        Caps.BrowserName := BrowserName;
        if HeadlessModeCheckBox.IsChecked then
          Caps.Headless := True
        else
          Caps.Headless := False;

        // Optional Args
        // Caps.Args.Add('--disable-gpu');
        // Caps.Args.Add('--window-size=1920,1080');

        Driver.StartSession(Caps);
      finally
        Caps.Free;
      end;

      Driver.Navigate('https://www.google.com');
      Driver.WaitUntilPageLoad;

      LogsMemo.Text := Driver.GetPageSource;

    finally
      Driver.Quit;
    end;
  finally
    Server.Stop;
    Server.Free;
  end;
end;
```

---

## ⚡ Notes

* Use **interface variables** (`IWebDriver`, `IWebElement`) for safe automatic memory management.
* Avoid keeping element references after quitting the driver.
* `WaitUntilElement` supports **Id, Name, ClassName, CSS Selector, XPath**.
* `TWebDriverServer` helps start/stop ChromeDriver for your tests.

---

## 📜 License

MIT License

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

---

## 🐞 Issues

If you find a bug, please provide:

* Steps to reproduce
* Expected behavior
* Actual behavior
* Delphi version
* WebDriver and browser version

---

## 🗺️ Roadmap

* [x] Minimal viable implementation
* [x] Element location by CSS/XPath
* [x] Wait for elements and conditions
* [x] Click, send keys, submit forms
* [x] Wait for page to load
* [x] Screenshot support  
* [x] Cross-browser (Chrome, Firefox, Edge)
* [x] Cookie management
* [x] Frame 
* [x] JavaScript execution
* [x] handling headless mode
* [ ] Full WebDriver command coverage
