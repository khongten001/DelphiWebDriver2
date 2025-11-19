unit DelphiWebDriver.Core.Actions;

interface

uses
  System.JSON,
  System.SysUtils,
  System.Generics.Collections,
  DelphiWebDriver.Interfaces,
  DelphiWebDriver.Types;

type
  TWebDriverActions = class(TInterfacedObject, IWebDriverActions)
  private
    [weak]
    FDriver: IWebDriver;
    FActions: TList<TWebDriverActionItem>;
  public
    constructor Create(ADriver: IWebDriver);
    destructor Destroy; override;
    function MoveToElement(By: TBy; X: Integer = 0; Y: Integer = 0): IWebDriverActions;
    function Click: IWebDriverActions;
    function DoubleClick: IWebDriverActions;
    function ClickAndHold: IWebDriverActions;
    function Release: IWebDriverActions;
    function SendKeys(const Keys: string): IWebDriverActions;
    procedure Perform;
  end;

implementation

{ TWebDriverActions }

constructor TWebDriverActions.Create(ADriver: IWebDriver);
begin
  inherited Create;
  FDriver := ADriver;
  FActions := TList<TWebDriverActionItem>.Create;
end;

destructor TWebDriverActions.Destroy;
begin
  FActions.Free;
  inherited;
end;

function TWebDriverActions.MoveToElement(By: TBy; X: Integer = 0; Y: Integer = 0): IWebDriverActions;
var
  Elem: IWebElement;
  Item: TWebDriverActionItem;
begin
  Elem := FDriver.Elements.FindElement(By);
  if not Assigned(Elem) then
    raise EWebDriverError.CreateFmt('Element not found for strategy: %s, value: %s', [By.Strategy, By.Value]);
  Item.ActionType := TWebDriverActionItemType.MouseMove;
  Item.ElementId := Elem.ElementId;
  Item.X := X;
  Item.Y := Y;
  FActions.Add(Item);
  Result := Self;
end;

function TWebDriverActions.Click: IWebDriverActions;
var
  Item: TWebDriverActionItem;
begin
  Item.ActionType := TWebDriverActionItemType.Click;
  FActions.Add(Item);
  Result := Self;
end;

function TWebDriverActions.DoubleClick: IWebDriverActions;
var
  Item: TWebDriverActionItem;
begin
  Item.ActionType := TWebDriverActionItemType.DoubleClick;
  FActions.Add(Item);
  Result := Self;
end;

function TWebDriverActions.ClickAndHold: IWebDriverActions;
var
  Item: TWebDriverActionItem;
begin
  Item.ActionType := TWebDriverActionItemType.MouseDown;
  FActions.Add(Item);
  Result := Self;
end;

function TWebDriverActions.Release: IWebDriverActions;
var
  Item: TWebDriverActionItem;
begin
  Item.ActionType := MouseUp;
  FActions.Add(Item);
  Result := Self;
end;

function TWebDriverActions.SendKeys(const Keys: string): IWebDriverActions;
var
  I: Integer;
  Item: TWebDriverActionItem;
begin
  for I := 1 to Keys.Length do
  begin
    Item.ActionType := TWebDriverActionItemType.KeyDown;
    Item.Key := Keys[I];
    FActions.Add(Item);
    Item.ActionType := TWebDriverActionItemType.KeyUp;
    Item.Key := Keys[I];
    FActions.Add(Item);
  end;
  Result := Self;
end;

procedure TWebDriverActions.Perform;
var
  Root: TJSONObject;
  PointerAction, KeyboardAction: TJSONObject;
  PointerActionsArray, KeyActionsArray: TJSONArray;
  I: Integer;
  ActionItem: TWebDriverActionItem;
  ActionObj, OriginObj: TJSONObject;
begin
  if FActions.Count = 0 then
    Exit;
  Root := TJSONObject.Create;
  PointerActionsArray := TJSONArray.Create;
  KeyActionsArray := TJSONArray.Create;
  try
    PointerAction := TJSONObject.Create;
    PointerAction.AddPair('type', 'pointer');
    PointerAction.AddPair('id', 'mouse');
    PointerAction.AddPair('parameters', TJSONObject.Create.AddPair('pointerType', 'mouse'));
    for I := 0 to FActions.Count - 1 do
    begin
      ActionItem := FActions[I];
      if ActionItem.ActionType in [TWebDriverActionItemType.MouseMove, TWebDriverActionItemType.Click,
                                   TWebDriverActionItemType.DoubleClick, TWebDriverActionItemType.MouseDown,
                                   TWebDriverActionItemType.MouseUp] then
      begin
        ActionObj := TJSONObject.Create;
        case ActionItem.ActionType of
          TWebDriverActionItemType.MouseMove:
            begin
              ActionObj.AddPair('type', 'pointerMove');
              OriginObj := TJSONObject.Create;
              OriginObj.AddPair('element-6066-11e4-a52e-4f735466cecf', ActionItem.ElementId);
              ActionObj.AddPair('origin', OriginObj);
              ActionObj.AddPair('x', TJSONNumber.Create(ActionItem.X));
              ActionObj.AddPair('y', TJSONNumber.Create(ActionItem.Y));
            end;
          TWebDriverActionItemType.Click:
            begin
              ActionObj.AddPair('type', 'pointerDown');
              ActionObj.AddPair('button', TJSONNumber.Create(0));
              PointerActionsArray.Add(ActionObj);
              ActionObj := TJSONObject.Create;
              ActionObj.AddPair('type', 'pointerUp');
              ActionObj.AddPair('button', TJSONNumber.Create(0));
            end;
          TWebDriverActionItemType.DoubleClick:
            begin
              ActionObj.AddPair('type', 'pointerDown'); ActionObj.AddPair('button', TJSONNumber.Create(0));
              PointerActionsArray.Add(ActionObj);
              ActionObj := TJSONObject.Create; ActionObj.AddPair('type', 'pointerUp'); ActionObj.AddPair('button', TJSONNumber.Create(0));
              PointerActionsArray.Add(ActionObj);
              ActionObj := TJSONObject.Create; ActionObj.AddPair('type', 'pointerDown'); ActionObj.AddPair('button', TJSONNumber.Create(0));
              PointerActionsArray.Add(ActionObj);
              ActionObj := TJSONObject.Create; ActionObj.AddPair('type', 'pointerUp'); ActionObj.AddPair('button', TJSONNumber.Create(0));
            end;
          TWebDriverActionItemType.MouseDown:
            begin
              ActionObj.AddPair('type', 'pointerDown');
              ActionObj.AddPair('button', TJSONNumber.Create(0));
            end;
          TWebDriverActionItemType.MouseUp:
            begin
              ActionObj.AddPair('type', 'pointerUp');
              ActionObj.AddPair('button', TJSONNumber.Create(0));
            end;
        end;
        PointerActionsArray.Add(ActionObj);
      end;
    end;
    PointerAction.AddPair('actions', PointerActionsArray);
    KeyboardAction := TJSONObject.Create;
    KeyboardAction.AddPair('type', 'key');
    KeyboardAction.AddPair('id', 'keyboard');
    for I := 0 to FActions.Count - 1 do
    begin
      ActionItem := FActions[I];
      if ActionItem.ActionType in [KeyDown, KeyUp] then
      begin
        ActionObj := TJSONObject.Create;
        case ActionItem.ActionType of
          KeyDown: ActionObj.AddPair('type', 'keyDown');
          KeyUp:   ActionObj.AddPair('type', 'keyUp');
        end;
        ActionObj.AddPair('value', ActionItem.Key);
        KeyActionsArray.Add(ActionObj);
      end;
    end;
    KeyboardAction.AddPair('actions', KeyActionsArray);
    var ActionsArray := TJSONArray.Create;
    ActionsArray.Add(PointerAction);
    ActionsArray.Add(KeyboardAction);
    Root.AddPair('actions', ActionsArray);
    FDriver.Commands.SendCommand('POST',
      '/session/' + FDriver.Sessions.GetSessionId + '/actions',
      Root).Free;
  finally
    Root.Free;
  end;
end;

end.

