unit DelphiWebDriver.Types;

interface

type
  TCookie = record
    Name: string;
    Value: string;
    Domain: string;
    Path: string;
    Secure: Boolean;
    HttpOnly: Boolean;
    Expiry: Int64;
  end;

  TBy = record
    Strategy: string;
    Value: string;
    class function Name(const AValue: string): TBy; static;
    class function Id(const AValue: string): TBy; static;
    class function ClassName(const AValue: string): TBy; static;
    class function CssSelector(const AValue: string): TBy; static;
    class function XPath(const AValue: string): TBy; static;
    class function Css(const AValue: string): TBy; static;
  end;

implementation

{ TBy }

class function TBy.Css(const AValue: string): TBy;
begin
  Result.Strategy := 'css selector';
  Result.Value := AValue;
end;

class function TBy.XPath(const AValue: string): TBy;
begin
  Result.Strategy := 'xpath';
  Result.Value := AValue;
end;

class function TBy.CssSelector(const AValue: string): TBy;
begin
  Result.Strategy := 'css selector';
  Result.Value := AValue;
end;

class function TBy.Name(const AValue: string): TBy;
begin
  Result.Strategy := 'name';
  Result.Value := AValue;
end;

class function TBy.Id(const AValue: string): TBy;
begin
  Result.Strategy := 'id';
  Result.Value := AValue;
end;

class function TBy.ClassName(const AValue: string): TBy;
begin
  Result.Strategy := 'class name';
  Result.Value := AValue;
end;

end.
