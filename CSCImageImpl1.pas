unit CSCImageImpl1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActiveX, AxCtrls, CSCImageProj_TLB, ExtCtrls;

type
  TCSCImageX = class(TActiveForm, ICSCImageX)
    Image1: TImage;
    procedure CSCImageCreate(Sender: TObject);
  private
    { Private declarations }
    m_ImageFile : String;
    FEvents: ICSCImageXEvents;
    procedure ActivateEvent(Sender: TObject);
    procedure ClickEvent(Sender: TObject);
    procedure CreateEvent(Sender: TObject);
    procedure DblClickEvent(Sender: TObject);
    procedure DeactivateEvent(Sender: TObject);
    procedure DestroyEvent(Sender: TObject);
    procedure KeyPressEvent(Sender: TObject; var Key: Char);
    procedure PaintEvent(Sender: TObject);
  protected
    { Protected declarations }
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    procedure Initialize; override;
    function Get_Active: WordBool; safecall;
    function Get_AutoScroll: WordBool; safecall;
    function Get_AxBorderStyle: TxActiveFormBorderStyle; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Color: TColor; safecall;
    function Get_Cursor: Smallint; safecall;
    function Get_DropTarget: WordBool; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_Font: Font; safecall;
    function Get_HelpFile: WideString; safecall;
    function Get_KeyPreview: WordBool; safecall;
    function Get_PixelsPerInch: Integer; safecall;
    function Get_PrintScale: TxPrintScale; safecall;
    function Get_Scaled: WordBool; safecall;
    function Get_Visible: WordBool; safecall;
    function Get_WindowState: TxWindowState; safecall;
    procedure AboutBox; safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    procedure Set_AxBorderStyle(Value: TxActiveFormBorderStyle); safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    procedure Set_Color(Value: TColor); safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_Font(const Value: Font); safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    procedure Set_PrintScale(Value: TxPrintScale); safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    procedure Set_WindowState(Value: TxWindowState); safecall;
    function Get_ImageFile: OleVariant; safecall;
    procedure Set_ImageFile(Value: OleVariant); safecall;
    function Get_Stretch: Integer; safecall;
    procedure Set_Stretch(Value: Integer); safecall;
  public
    { Public declarations }
  end;

implementation

uses ComServ, About1;

{$R *.DFM}

{ TCSCImageX }

procedure TCSCImageX.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as ICSCImageXEvents;
end;

procedure TCSCImageX.Initialize;
begin
  OnActivate := ActivateEvent;
  OnClick := ClickEvent;
  OnCreate := CreateEvent;
  OnDblClick := DblClickEvent;
  OnDeactivate := DeactivateEvent;
  OnDestroy := DestroyEvent;
  OnKeyPress := KeyPressEvent;
  OnPaint := PaintEvent;
end;

function TCSCImageX.Get_Active: WordBool;
begin
  Result := Active;
end;

function TCSCImageX.Get_AutoScroll: WordBool;
begin
  Result := AutoScroll;
end;

function TCSCImageX.Get_AxBorderStyle: TxActiveFormBorderStyle;
begin
  Result := Ord(AxBorderStyle);
end;

function TCSCImageX.Get_Caption: WideString;
begin
  Result := WideString(Caption);
end;

function TCSCImageX.Get_Color: TColor;
begin
  Result := Color;
end;

function TCSCImageX.Get_Cursor: Smallint;
begin
  Result := Smallint(Cursor);
end;

function TCSCImageX.Get_DropTarget: WordBool;
begin
  Result := DropTarget;
end;

function TCSCImageX.Get_Enabled: WordBool;
begin
  Result := Enabled;
end;

function TCSCImageX.Get_Font: Font;
begin
  GetOleFont(Font, Result);
end;

function TCSCImageX.Get_HelpFile: WideString;
begin
  Result := WideString(HelpFile);
end;

function TCSCImageX.Get_KeyPreview: WordBool;
begin
  Result := KeyPreview;
end;

function TCSCImageX.Get_PixelsPerInch: Integer;
begin
  Result := PixelsPerInch;
end;

function TCSCImageX.Get_PrintScale: TxPrintScale;
begin
  Result := Ord(PrintScale);
end;

function TCSCImageX.Get_Scaled: WordBool;
begin
  Result := Scaled;
end;

function TCSCImageX.Get_Visible: WordBool;
begin
  Result := Visible;
end;

function TCSCImageX.Get_WindowState: TxWindowState;
begin
  Result := Ord(WindowState);
end;

procedure TCSCImageX.AboutBox;
begin
  ShowCSCImageXAbout;
end;

procedure TCSCImageX.Set_AutoScroll(Value: WordBool);
begin
  AutoScroll := Value;
end;

procedure TCSCImageX.Set_AxBorderStyle(Value: TxActiveFormBorderStyle);
begin
  AxBorderStyle := TActiveFormBorderStyle(Value);
end;

procedure TCSCImageX.Set_Caption(const Value: WideString);
begin
  Caption := TCaption(Value);
end;

procedure TCSCImageX.Set_Color(Value: TColor);
begin
  Color := Value;
end;

procedure TCSCImageX.Set_Cursor(Value: Smallint);
begin
  Cursor := TCursor(Value);
end;

procedure TCSCImageX.Set_DropTarget(Value: WordBool);
begin
  DropTarget := Value;
end;

procedure TCSCImageX.Set_Enabled(Value: WordBool);
begin
  Enabled := Value;
end;

procedure TCSCImageX.Set_Font(const Value: Font);
begin
  SetOleFont(Font, Value);
end;

procedure TCSCImageX.Set_HelpFile(const Value: WideString);
begin
  HelpFile := String(Value);
end;

procedure TCSCImageX.Set_KeyPreview(Value: WordBool);
begin
  KeyPreview := Value;
end;

procedure TCSCImageX.Set_PixelsPerInch(Value: Integer);
begin
  PixelsPerInch := Value;
end;

procedure TCSCImageX.Set_PrintScale(Value: TxPrintScale);
begin
  PrintScale := TPrintScale(Value);
end;

procedure TCSCImageX.Set_Scaled(Value: WordBool);
begin
  Scaled := Value;
end;

procedure TCSCImageX.Set_Visible(Value: WordBool);
begin
  Visible := Value;
end;

procedure TCSCImageX.Set_WindowState(Value: TxWindowState);
begin
  WindowState := TWindowState(Value);
end;

procedure TCSCImageX.ActivateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnActivate;
end;

procedure TCSCImageX.ClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnClick;
end;

procedure TCSCImageX.CreateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnCreate;
end;

procedure TCSCImageX.DblClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDblClick;
end;

procedure TCSCImageX.DeactivateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDeactivate;
end;

procedure TCSCImageX.DestroyEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDestroy;
end;

procedure TCSCImageX.KeyPressEvent(Sender: TObject; var Key: Char);
var
  TempKey: Smallint;
begin
  TempKey := Smallint(Key);
  if FEvents <> nil then FEvents.OnKeyPress(TempKey);
  Key := Char(TempKey);
end;

procedure TCSCImageX.PaintEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnPaint;
end;

procedure TCSCImageX.CSCImageCreate(Sender: TObject);
begin
  Image1.Height := Height;
  Image1.Width := Width;
end;

function TCSCImageX.Get_ImageFile: OleVariant;
begin
  result := m_ImageFile;
end;

procedure TCSCImageX.Set_ImageFile(Value: OleVariant);
begin
  m_ImageFile := Value;
  Image1.Picture.LoadFromFile(m_ImageFile);
  Image1.Height := Height;
  Image1.Width := Width;
  Image1.Repaint;
  Repaint;
end;

function TCSCImageX.Get_Stretch: Integer;
begin
Result := Integer(Image1.Stretch);
end;

procedure TCSCImageX.Set_Stretch(Value: Integer);
begin
  Image1.Stretch := Boolean(Value);
end;

initialization
  TActiveFormFactory.Create(
    ComServer,
    TActiveFormControl,
    TCSCImageX,
    Class_CSCImageX,
    1,
    '',
    OLEMISC_SIMPLEFRAME or OLEMISC_ACTSLIKELABEL);
end.
