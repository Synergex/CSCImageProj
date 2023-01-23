unit CSCImageProj_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ CSCImageProj Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_CSCImageProj: TGUID = '{407C41C0-EF71-11D1-804B-00A0245B570C}';

const

{ TxActiveFormBorderStyle }

  afbNone = 0;
  afbSingle = 1;
  afbSunken = 2;
  afbRaised = 3;

{ TxPrintScale }

  poNone = 0;
  poProportional = 1;
  poPrintToFit = 2;

{ TxMouseButton }

  mbLeft = 0;
  mbRight = 1;
  mbMiddle = 2;

{ TxWindowState }

  wsNormal = 0;
  wsMinimized = 1;
  wsMaximized = 2;

const

{ Component class GUIDs }
  Class_CSCImageX: TGUID = '{407C41C3-EF71-11D1-804B-00A0245B570C}';

type

{ Forward declarations: Interfaces }
  ICSCImageX = interface;
  ICSCImageXDisp = dispinterface;
  ICSCImageXEvents = dispinterface;

{ Forward declarations: CoClasses }
  CSCImageX = ICSCImageX;

{ Forward declarations: Enums }
  TxActiveFormBorderStyle = TOleEnum;
  TxPrintScale = TOleEnum;
  TxMouseButton = TOleEnum;
  TxWindowState = TOleEnum;

{ Dispatch interface for CSCImageX Control }

  ICSCImageX = interface(IDispatch)
    ['{407C41C1-EF71-11D1-804B-00A0245B570C}']
    function Get_AutoScroll: WordBool; safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    function Get_AxBorderStyle: TxActiveFormBorderStyle; safecall;
    procedure Set_AxBorderStyle(Value: TxActiveFormBorderStyle); safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Color: TColor; safecall;
    procedure Set_Color(Value: TColor); safecall;
    function Get_Font: Font; safecall;
    procedure Set_Font(const Value: Font); safecall;
    function Get_KeyPreview: WordBool; safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    function Get_PixelsPerInch: Integer; safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    function Get_PrintScale: TxPrintScale; safecall;
    procedure Set_PrintScale(Value: TxPrintScale); safecall;
    function Get_Scaled: WordBool; safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    function Get_Active: WordBool; safecall;
    function Get_DropTarget: WordBool; safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    function Get_HelpFile: WideString; safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    function Get_WindowState: TxWindowState; safecall;
    procedure Set_WindowState(Value: TxWindowState); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function Get_Cursor: Smallint; safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    procedure AboutBox; safecall;
    function Get_ImageFile: OleVariant; safecall;
    procedure Set_ImageFile(Value: OleVariant); safecall;
    function Get_Stretch: Integer; safecall;
    procedure Set_Stretch(Value: Integer); safecall;
    property AutoScroll: WordBool read Get_AutoScroll write Set_AutoScroll;
    property AxBorderStyle: TxActiveFormBorderStyle read Get_AxBorderStyle write Set_AxBorderStyle;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Color: TColor read Get_Color write Set_Color;
    property Font: Font read Get_Font write Set_Font;
    property KeyPreview: WordBool read Get_KeyPreview write Set_KeyPreview;
    property PixelsPerInch: Integer read Get_PixelsPerInch write Set_PixelsPerInch;
    property PrintScale: TxPrintScale read Get_PrintScale write Set_PrintScale;
    property Scaled: WordBool read Get_Scaled write Set_Scaled;
    property Active: WordBool read Get_Active;
    property DropTarget: WordBool read Get_DropTarget write Set_DropTarget;
    property HelpFile: WideString read Get_HelpFile write Set_HelpFile;
    property WindowState: TxWindowState read Get_WindowState write Set_WindowState;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Cursor: Smallint read Get_Cursor write Set_Cursor;
    property ImageFile: OleVariant read Get_ImageFile write Set_ImageFile;
    property Stretch: Integer read Get_Stretch write Set_Stretch;
  end;

{ DispInterface declaration for Dual Interface ICSCImageX }

  ICSCImageXDisp = dispinterface
    ['{407C41C1-EF71-11D1-804B-00A0245B570C}']
    property AutoScroll: WordBool dispid 1;
    property AxBorderStyle: TxActiveFormBorderStyle dispid 2;
    property Caption: WideString dispid 3;
    property Color: TColor dispid 4;
    property Font: Font dispid 5;
    property KeyPreview: WordBool dispid 6;
    property PixelsPerInch: Integer dispid 7;
    property PrintScale: TxPrintScale dispid 8;
    property Scaled: WordBool dispid 9;
    property Active: WordBool readonly dispid 10;
    property DropTarget: WordBool dispid 11;
    property HelpFile: WideString dispid 12;
    property WindowState: TxWindowState dispid 13;
    property Visible: WordBool dispid 14;
    property Enabled: WordBool dispid 15;
    property Cursor: Smallint dispid 16;
    procedure AboutBox; dispid -552;
    property ImageFile: OleVariant dispid 17;
    property Stretch: Integer dispid 18;
  end;

{ Events interface for CSCImageX Control }

  ICSCImageXEvents = dispinterface
    ['{407C41C2-EF71-11D1-804B-00A0245B570C}']
    procedure OnActivate; dispid 1;
    procedure OnClick; dispid 2;
    procedure OnCreate; dispid 3;
    procedure OnDblClick; dispid 4;
    procedure OnDestroy; dispid 5;
    procedure OnDeactivate; dispid 6;
    procedure OnKeyPress(var Key: Smallint); dispid 7;
    procedure OnPaint; dispid 8;
  end;

{ CSCImageXControl }

  TCSCImageXOnKeyPress = procedure(Sender: TObject; var Key: Smallint) of object;

  TCSCImageX = class(TOleControl)
  private
    FOnActivate: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnCreate: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnKeyPress: TCSCImageXOnKeyPress;
    FOnPaint: TNotifyEvent;
    FIntf: ICSCImageX;
  protected
    procedure InitControlData; override;
    procedure InitControlInterface(const Obj: IUnknown); override;
  public
    procedure AboutBox;
    property ControlInterface: ICSCImageX read FIntf;
    property Active: WordBool index 10 read GetWordBoolProp;
  published
    property Align;
    property DragCursor;
    property DragMode;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDrag;
    property AutoScroll: WordBool index 1 read GetWordBoolProp write SetWordBoolProp stored False;
    property AxBorderStyle: TxActiveFormBorderStyle index 2 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Caption: WideString index 3 read GetWideStringProp write SetWideStringProp stored False;
    property Color: TColor index 4 read GetTColorProp write SetTColorProp stored False;
    property Font: TFont index 5 read GetTFontProp write SetTFontProp stored False;
    property KeyPreview: WordBool index 6 read GetWordBoolProp write SetWordBoolProp stored False;
    property PixelsPerInch: Integer index 7 read GetIntegerProp write SetIntegerProp stored False;
    property PrintScale: TxPrintScale index 8 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Scaled: WordBool index 9 read GetWordBoolProp write SetWordBoolProp stored False;
    property DropTarget: WordBool index 11 read GetWordBoolProp write SetWordBoolProp stored False;
    property HelpFile: WideString index 12 read GetWideStringProp write SetWideStringProp stored False;
    property WindowState: TxWindowState index 13 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Visible: WordBool index 14 read GetWordBoolProp write SetWordBoolProp stored False;
    property Enabled: WordBool index 15 read GetWordBoolProp write SetWordBoolProp stored False;
    property Cursor: Smallint index 16 read GetSmallintProp write SetSmallintProp stored False;
    property ImageFile: OleVariant index 17 read GetOleVariantProp write SetOleVariantProp stored False;
    property Stretch: Integer index 18 read GetIntegerProp write SetIntegerProp stored False;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnKeyPress: TCSCImageXOnKeyPress read FOnKeyPress write FOnKeyPress;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

procedure Register;

implementation

uses ComObj;

procedure TCSCImageX.InitControlData;
const
  CEventDispIDs: array[0..7] of Integer = (
    $00000001, $00000002, $00000003, $00000004, $00000005, $00000006,
    $00000007, $00000008);
  CTFontIDs: array [0..0] of Integer = (
    $00000005);
  CControlData: TControlData = (
    ClassID: '{407C41C3-EF71-11D1-804B-00A0245B570C}';
    EventIID: '{407C41C2-EF71-11D1-804B-00A0245B570C}';
    EventCount: 8;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil;
    Flags: $00000000;
    Version: 300;
    FontCount: 1;
    FontIDs: @CTFontIDs);
begin
  ControlData := @CControlData;
end;

procedure TCSCImageX.InitControlInterface(const Obj: IUnknown);
begin
  FIntf := Obj as ICSCImageX;
end;

procedure TCSCImageX.AboutBox;
begin
  ControlInterface.AboutBox;
end;


procedure Register;
begin
  RegisterComponents('ActiveX', [TCSCImageX]);
end;

end.
