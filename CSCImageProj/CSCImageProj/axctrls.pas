{*******************************************************}
{                                                       }
{       Delphi Visual Component Library                 }
{       ActiveX Controls Unit                           }
{                                                       }
{       Copyright (c) 1997 Borland International        }
{                                                       }
{*******************************************************}

unit AxCtrls;

{$T-,H+,X+}
interface

uses
  Windows, Messages, ActiveX, SysUtils, ComObj, Classes, Graphics,
  Controls, Forms, Consts, ExtCtrls, StdVcl;

const
  { Delphi property page CLSIDs }
  Class_DColorPropPage: TGUID = '{5CFF5D59-5946-11D0-BDEF-00A024D1875C}';
  Class_DFontPropPage: TGUID = '{5CFF5D5B-5946-11D0-BDEF-00A024D1875C}';
  Class_DPicturePropPage: TGUID = '{5CFF5D5A-5946-11D0-BDEF-00A024D1875C}';
  Class_DStringPropPage: TGUID = '{F42D677E-754B-11D0-BDFB-00A024D1875C}';

type
  TOleStream = class(TStream)
  private
    FStream: IStream;
  public
    constructor Create(const Stream: IStream);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;

  TAggregatedObject = class
  private
    FController: Pointer;
    function GetController: IUnknown;
  protected
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): Integer; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(const Controller: IUnknown);
    property Controller: IUnknown read GetController;
  end;

  TContainedObject = class(TAggregatedObject, IUnknown)
  protected
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): Integer; virtual; stdcall;
  end;

  TConnectionPoints = class;

  TConnectEvent = procedure (const Sink: IUnknown; Connecting: Boolean) of object;
  TConnectionKind = (ckSingle, ckMulti);

  TConnectionPoint = class(TContainedObject, IConnectionPoint)
  private
    FContainer: TConnectionPoints;
    FIID: TGUID;
    FSinkList: TList;
    FOnConnect: TConnectEvent;
    FSinkCount: Integer;
    FKind: TConnectionKind;
    function AddSink(const Sink: IUnknown): Integer;
    procedure RemoveSink(Cookie: Longint);
  protected
    { IConnectionPoint }
    function GetConnectionInterface(out iid: TIID): HResult; stdcall;
    function GetConnectionPointContainer(
      out cpc: IConnectionPointContainer): HResult; stdcall;
    function Advise(const unkSink: IUnknown; out dwCookie: Longint): HResult; stdcall;
    function Unadvise(dwCookie: Longint): HResult; stdcall;
    function EnumConnections(out enum: IEnumConnections): HResult; stdcall;
  public
    constructor Create(Container: TConnectionPoints;
      const IID: TGUID; Kind: TConnectionKind; OnConnect: TConnectEvent);
    destructor Destroy; override;
  end;

  TConnectionPoints = class(TAggregatedObject,
    IConnectionPointContainer)
  private
    FConnectionPoints: TList;
  protected
    { IConnectionPointContainer }
    function EnumConnectionPoints(
      out enum: IEnumConnectionPoints): HResult; stdcall;
    function FindConnectionPoint(const iid: TIID;
      out cp: IConnectionPoint): HResult; stdcall;
  public
    constructor Create(const Controller: IUnknown);
    destructor Destroy; override;
    function CreateConnectionPoint(const IID: TGUID; Kind: TConnectionKind;
      OnConnect: TConnectEvent): TConnectionPoint;
  end;

  TDefinePropertyPage = procedure(const GUID: TGUID) of object;

  TActiveXControlFactory = class;

  IAmbientDispatch = dispinterface
    ['{00020400-0000-0000-C000-000000000046}']
    property BackColor: Integer dispid DISPID_AMBIENT_BACKCOLOR;
    property DisplayName: WideString dispid DISPID_AMBIENT_DISPLAYNAME;
    property Font: IFontDisp dispid DISPID_AMBIENT_FONT;
    property ForeColor: Integer dispid DISPID_AMBIENT_FORECOLOR;
    property LocaleID: Integer dispid DISPID_AMBIENT_LOCALEID;
    property MessageReflect: WordBool dispid DISPID_AMBIENT_MESSAGEREFLECT;
    property ScaleUnits: WideString dispid DISPID_AMBIENT_SCALEUNITS;
    property TextAlign: Smallint dispid DISPID_AMBIENT_TEXTALIGN;
    property UserMode: WordBool dispid DISPID_AMBIENT_USERMODE;
    property UIDead: WordBool dispid DISPID_AMBIENT_UIDEAD;
    property ShowGrabHandles: WordBool dispid DISPID_AMBIENT_SHOWGRABHANDLES;
    property ShowHatching: WordBool dispid DISPID_AMBIENT_SHOWHATCHING;
    property DisplayAsDefault: WordBool dispid DISPID_AMBIENT_DISPLAYASDEFAULT;
    property SupportsMnemonics: WordBool dispid DISPID_AMBIENT_SUPPORTSMNEMONICS;
    property AutoClip: WordBool dispid DISPID_AMBIENT_AUTOCLIP;
  end;

  TActiveXControl = class(TAutoObject,
    IPersistStreamInit,
    IPersistStorage,
    IOleObject,
    IOleControl,
    IOleInPlaceObject,
    IOleInPlaceActiveObject,
    IViewObject,
    IViewObject2,
    IPerPropertyBrowsing,
    ISpecifyPropertyPages,
    ISimpleFrameSite)
  private
    FControlFactory: TActiveXControlFactory;
    FConnectionPoints: TConnectionPoints;
    FEventSink: IUnknown;
    FPropertySinks: TConnectionPoint;
    FOleClientSite: IOleClientSite;
    FOleControlSite: IOleControlSite;
    FSimpleFrameSite: ISimpleFrameSite;
    FAmbientDispatch: IAmbientDispatch;
    FOleInPlaceSite: IOleInPlaceSite;
    FOleInPlaceFrame: IOleInPlaceFrame;
    FOleInPlaceUIWindow: IOleInPlaceUIWindow;
    FOleAdviseHolder: IOleAdviseHolder;
    FAdviseSink: IAdviseSink;
    FAdviseFlags: Integer;
    FControl: TWinControl;
    FControlWndProc: TWndMethod;
    FWinControl: TWinControl;
    FIsDirty: Boolean;
    FInPlaceActive: Boolean;
    FUIActive: Boolean;
    FEventsFrozen: Boolean;
    function CreateAdviseHolder: HResult;
    procedure EventConnect(const Sink: IUnknown; Connecting: Boolean);
    function GetPropertyID(const PropertyName: WideString): Integer;
    procedure RecreateWnd;
    procedure ViewChanged;
  protected
    { Renamed methods }
    function IPersistStreamInit.Load = PersistStreamLoad;
    function IPersistStreamInit.Save = PersistStreamSave;
    function IPersistStorage.InitNew = PersistStorageInitNew;
    function IPersistStorage.Load = PersistStorageLoad;
    function IPersistStorage.Save = PersistStorageSave;
    function IViewObject2.GetExtent = ViewObjectGetExtent;
    { IPersist }
    function GetClassID(out classID: TCLSID): HResult; stdcall;
    { IPersistStreamInit }
    function IsDirty: HResult; stdcall;
    function PersistStreamLoad(const stm: IStream): HResult; stdcall;
    function PersistStreamSave(const stm: IStream;
      fClearDirty: BOOL): HResult; stdcall;
    function GetSizeMax(out cbSize: Largeint): HResult; stdcall;
    function InitNew: HResult; stdcall;
    { IPersistStorage }
    function PersistStorageInitNew(const stg: IStorage): HResult; stdcall;
    function PersistStorageLoad(const stg: IStorage): HResult; stdcall;
    function PersistStorageSave(const stgSave: IStorage;
      fSameAsLoad: BOOL): HResult; stdcall;
    function SaveCompleted(const stgNew: IStorage): HResult; stdcall;
    function HandsOffStorage: HResult; stdcall;
    { IOleObject }
    function SetClientSite(const clientSite: IOleClientSite): HResult;
      stdcall;
    function GetClientSite(out clientSite: IOleClientSite): HResult;
      stdcall;
    function SetHostNames(szContainerApp: POleStr;
      szContainerObj: POleStr): HResult; stdcall;
    function Close(dwSaveOption: Longint): HResult; stdcall;
    function SetMoniker(dwWhichMoniker: Longint; const mk: IMoniker): HResult;
      stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function InitFromData(const dataObject: IDataObject; fCreation: BOOL;
      dwReserved: Longint): HResult; stdcall;
    function GetClipboardData(dwReserved: Longint;
      out dataObject: IDataObject): HResult; stdcall;
    function DoVerb(iVerb: Longint; msg: PMsg; const activeSite: IOleClientSite;
      lindex: Longint; hwndParent: HWND; const posRect: TRect): HResult;
      stdcall;
    function EnumVerbs(out enumOleVerb: IEnumOleVerb): HResult; stdcall;
    function Update: HResult; stdcall;
    function IsUpToDate: HResult; stdcall;
    function GetUserClassID(out clsid: TCLSID): HResult; stdcall;
    function GetUserType(dwFormOfType: Longint; out pszUserType: POleStr): HResult;
      stdcall;
    function SetExtent(dwDrawAspect: Longint; const size: TPoint): HResult;
      stdcall;
    function GetExtent(dwDrawAspect: Longint; out size: TPoint): HResult;
      stdcall;
    function Advise(const advSink: IAdviseSink; out dwConnection: Longint): HResult;
      stdcall;
    function Unadvise(dwConnection: Longint): HResult; stdcall;
    function EnumAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
    function GetMiscStatus(dwAspect: Longint; out dwStatus: Longint): HResult;
      stdcall;
    function SetColorScheme(const logpal: TLogPalette): HResult; stdcall;
    { IOleControl }
    function GetControlInfo(var ci: TControlInfo): HResult; stdcall;
    function OnMnemonic(msg: PMsg): HResult; stdcall;
    function OnAmbientPropertyChange(dispid: TDispID): HResult; stdcall;
    function FreezeEvents(bFreeze: BOOL): HResult; stdcall;
    { IOleWindow }
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    { IOleInPlaceObject }
    function InPlaceDeactivate: HResult; stdcall;
    function UIDeactivate: HResult; stdcall;
    function SetObjectRects(const rcPosRect: TRect;
      const rcClipRect: TRect): HResult; stdcall;
    function ReactivateAndUndo: HResult; stdcall;
    { IOleInPlaceActiveObject }
    function TranslateAccelerator(var msg: TMsg): HResult; stdcall;
    function OnFrameWindowActivate(fActivate: BOOL): HResult; stdcall;
    function OnDocWindowActivate(fActivate: BOOL): HResult; stdcall;
    function ResizeBorder(const rcBorder: TRect; const uiWindow: IOleInPlaceUIWindow;
      fFrameWindow: BOOL): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
    { IViewObject }
    function Draw(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
      ptd: PDVTargetDevice; hicTargetDev: HDC; hdcDraw: HDC;
      prcBounds: PRect; prcWBounds: PRect; fnContinue: TContinueFunc;
      dwContinue: Longint): HResult; stdcall;
    function GetColorSet(dwDrawAspect: Longint; lindex: Longint;
      pvAspect: Pointer; ptd: PDVTargetDevice; hicTargetDev: HDC;
      out colorSet: PLogPalette): HResult; stdcall;
    function Freeze(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
      out dwFreeze: Longint): HResult; stdcall;
    function Unfreeze(dwFreeze: Longint): HResult; stdcall;
    function SetAdvise(aspects: Longint; advf: Longint;
      const advSink: IAdviseSink): HResult; stdcall;
    function GetAdvise(pAspects: PLongint; pAdvf: PLONGINT;
      out advSink: IAdviseSink): HResult; stdcall;
    { IViewObject2 }
    function ViewObjectGetExtent(dwDrawAspect: Longint; lindex: Longint;
      ptd: PDVTargetDevice; out size: TPoint): HResult; stdcall;
    { IPerPropertyBrowsing }
    function GetDisplayString(dispid: TDispID; out bstr: WideString): HResult; stdcall;
    function MapPropertyToPage(dispid: TDispID; out clsid: TCLSID): HResult; stdcall;
    function GetPredefinedStrings(dispid: TDispID; out caStringsOut: TCAPOleStr;
      out caCookiesOut: TCALongint): HResult; stdcall;
    function GetPredefinedValue(dispid: TDispID; dwCookie: Longint;
      out varOut: OleVariant): HResult; stdcall;
    { ISpecifyPropertyPages }
    function GetPages(out pages: TCAGUID): HResult; stdcall;
    { ISimpleFrameSite }
    function PreMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
      out res: Integer; out Cookie: Longint): HResult; stdcall;
    function PostMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
      out res: Integer; Cookie: Longint): HResult; stdcall;
    { Standard properties }
    function Get_BackColor: Integer; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_Font: Font; safecall;
    function Get_ForeColor: Integer; safecall;
    function Get_HWnd: Integer; safecall;
    function Get_TabStop: WordBool; safecall;
    function Get_Text: WideString; safecall;
    procedure Set_BackColor(Value: Integer); safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_Font(const Value: Font); safecall;
    procedure Set_ForeColor(Value: Integer); safecall;
    procedure Set_TabStop(Value: WordBool); safecall;
    procedure Set_Text(const Value: WideString); safecall;
    { Standard event handlers }
    procedure StdClickEvent(Sender: TObject);
    procedure StdDblClickEvent(Sender: TObject);
    procedure StdKeyDownEvent(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StdKeyPressEvent(Sender: TObject; var Key: Char);
    procedure StdKeyUpEvent(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StdMouseDownEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StdMouseMoveEvent(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure StdMouseUpEvent(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    { Helper methods }
    function InPlaceActivate(ActivateUI: Boolean): HResult;
    procedure ShowPropertyDialog;
    { Overrideable methods }
    procedure DefinePropertyPages(
      DefinePropertyPage: TDefinePropertyPage); virtual;
    procedure EventSinkChanged(const EventSink: IUnknown); virtual;
    function GetPropertyString(DispID: Integer;
      var S: string): Boolean; virtual;
    function GetPropertyStrings(DispID: Integer;
      Strings: TStrings): Boolean; virtual;
    procedure GetPropertyValue(DispID, Cookie: Integer;
      var Value: OleVariant); virtual;
    procedure InitializeControl; virtual;
    procedure LoadFromStream(const Stream: IStream); virtual;
    procedure PerformVerb(Verb: Integer); virtual;
    procedure SaveToStream(const Stream: IStream); virtual;
    procedure WndProc(var Message: TMessage); virtual;
  public
    destructor Destroy; override;
    procedure Initialize; override;
    function ObjQueryInterface(const IID: TGUID; out Obj): Integer; override;
    function PropRequestEdit(const PropertyName: WideString): Boolean;
    procedure PropChanged(const PropertyName: WideString);
    property Control: TWinControl read FControl;
  end;

  TActiveXControlClass = class of TActiveXControl;

  TActiveXControlFactory = class(TAutoObjectFactory)
  private
    FWinControlClass: TWinControlClass;
    FMiscStatus: Integer;
    FToolboxBitmapID: Integer;
    FEventTypeInfo: ITypeInfo;
    FEventIID: TGUID;
    FVerbs: TStringList;
    FLicFileStrings: TStringList;
    FLicenseFileRead: Boolean;
  protected
    function GetLicenseFileName: string; virtual;
    function HasMachineLicense: Boolean; override;
  public
    constructor Create(ComServer: TComServerObject;
      ActiveXControlClass: TActiveXControlClass;
      WinControlClass: TWinControlClass; const ClassID: TGUID;
      ToolboxBitmapID: Integer; const LicStr: string; MiscStatus: Integer);
    destructor Destroy; override;
    procedure AddVerb(Verb: Integer; const VerbName: string);
    procedure UpdateRegistry(Register: Boolean); override;
    property EventIID: TGUID read FEventIID;
    property EventTypeInfo: ITypeInfo read FEventTypeInfo;
    property MiscStatus: Integer read FMiscStatus;
    property ToolboxBitmapID: Integer read FToolboxBitmapID;
    property WinControlClass: TWinControlClass read FWinControlClass;
  end;

  { ActiveFormControl }

  TActiveFormControl = class(TActiveXControl, IVCLComObject)
  protected
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
  public
    procedure FreeOnRelease;
    procedure InitializeControl; override;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
      override;
    function ObjQueryInterface(const IID: TGUID; out Obj): Integer; override;
  end;

  { ActiveForm }

  TActiveFormBorderStyle = (afbNone, afbSingle, afbSunken, afbRaised);

  TActiveForm = class(TCustomForm)
  private
    FAxBorderStyle: TActiveFormBorderStyle;
    procedure SetAxBorderStyle(Value: TActiveFormBorderStyle);
  protected
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure EventSinkChanged(const EventSink: IUnknown); virtual;
    procedure Initialize; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    function WantChildKey(Child: TControl; var Message: TMessage): Boolean; override;
  published
    property ActiveControl;
    property AutoScroll;
    property AxBorderStyle: TActiveFormBorderStyle read FAxBorderStyle
      write SetAxBorderStyle default afbSingle;
    property Caption stored True;
    property Color;
    property Font;
    property Height stored True;
    property HorzScrollBar;
    property KeyPreview;
    property PixelsPerInch;
    property PopupMenu;
    property PrintScale;
    property Scaled;
    property ShowHint;
    property VertScrollBar;
    property Width stored True;
    property OnActivate;
    property OnClick;
    property OnCreate;
    property OnDblClick;
    property OnDestroy;
    property OnDeactivate;
    property OnDragDrop;
    property OnDragOver;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint;
  end;

  TActiveFormClass = class of TActiveForm;

  { ActiveFormFactory }

  TActiveFormFactory = class(TActiveXControlFactory)
  public
    function GetIntfEntry(Guid: TGUID): PInterfaceEntry; override;
  end;

  { Property Page support }

  TActiveXPropertyPage = class;

  TPropertyPage = class(TCustomForm)
  private
    FActiveXPropertyPage: TActiveXPropertyPage;
    FOleObject: Variant;
    procedure CMChanged(var Msg: TCMChanged); message CM_CHANGED;
  public
    procedure Modified;
    procedure UpdateObject; virtual;
    procedure UpdatePropertyPage; virtual;
    property OleObject: Variant read FOleObject;
    procedure EnumCtlProps(PropType: TGUID; PropNames: TStrings);
  published
    property ActiveControl;
    property AutoScroll;
    property Caption;
    property ClientHeight;
    property ClientWidth;
    property Ctl3D;
    property Color;
    property Enabled;
    property Font;
    property Height;
    property HorzScrollBar;
    property KeyPreview;
    property PixelsPerInch;
    property ParentFont;
    property PopupMenu;
    property PrintScale;
    property Scaled;
    property ShowHint;
    property VertScrollBar;
    property Visible;
    property Width;
    property OnActivate;
    property OnClick;
    property OnClose;
    property OnCreate;
    property OnDblClick;
    property OnDestroy;
    property OnDeactivate;
    property OnDragDrop;
    property OnDragOver;
    property OnHide;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint;
    property OnResize;
    property OnShow;
  end;

  TPropertyPageClass = class of TPropertyPage;

  TActiveXPropertyPage = class(TComObject,
    IPropertyPage,
    IPropertyPage2)
  private
    FPropertyPage: TPropertyPage;
    FPageSite: IPropertyPageSite;
    FActive: Boolean;
    FModified: Boolean;
    procedure Modified;
  protected
    { IPropertyPage }
    function SetPageSite(const pageSite: IPropertyPageSite): HResult; stdcall;
    function Activate(hwndParent: HWnd; const rc: TRect; bModal: BOOL): HResult;
      stdcall;
    function Deactivate: HResult; stdcall;
    function GetPageInfo(out pageInfo: TPropPageInfo): HResult; stdcall;
    function SetObjects(cObjects: Longint; pUnkList: PUnknownList): HResult; stdcall;
    function Show(nCmdShow: Integer): HResult; stdcall;
    function Move(const rect: TRect): HResult; stdcall;
    function IsPageDirty: HResult; stdcall;
    function Apply: HResult; stdcall;
    function Help(pszHelpDir: POleStr): HResult; stdcall;
    function TranslateAccelerator(msg: PMsg): HResult; stdcall;
    { IPropertyPage2 }
    function EditProperty(dispid: TDispID): HResult; stdcall;
  public
    destructor Destroy; override;
    procedure Initialize; override;
  end;

  TActiveXPropertyPageFactory = class(TComObjectFactory)
  protected
    function CreateComObject(const Controller: IUnknown): TComObject; override;
  public
    constructor Create(ComServer: TComServerObject;
      PropertyPageClass: TPropertyPageClass; const ClassID: TGUID);
  end;

  { Type adapter support }

  TCustomAdapter = class(TInterfacedObject)
  private
    FOleObject: IUnknown;
    FConnection: Longint;
    FNotifier: IUnknown;
  protected
    Updating: Boolean;
    procedure Changed; virtual;
    procedure ConnectOleObject(OleObject: IUnknown);
    procedure ReleaseOleObject;
    procedure Update; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TAdapterNotifier = class(TInterfacedObject,
    IPropertyNotifySink)
  private
    FAdapter: TCustomAdapter;
  protected
    { IPropertyNotifySink }
    function OnChanged(dispid: TDispID): HResult; stdcall;
    function OnRequestEdit(dispid: TDispID): HResult; stdcall;
  public
    constructor Create(Adapter: TCustomAdapter);
  end;

  IFontAccess = interface
    ['{CBA55CA0-0E57-11D0-BD2F-0020AF0E5B81}']
    procedure GetOleFont(var OleFont: IFontDisp);
    procedure SetOleFont(const OleFont: IFontDisp);
  end;

  TFontAdapter = class(TCustomAdapter,
    IChangeNotifier,
    IFontAccess)
  private
    FFont: TFont;
  protected
    { IFontAccess }
    procedure GetOleFont(var OleFont: IFontDisp);
    procedure SetOleFont(const OleFont: IFontDisp);
    procedure Changed; override;
    procedure Update; override;
  public
    constructor Create(Font: TFont);
  end;

  IPictureAccess = interface
    ['{795D4D31-43D7-11D0-9E92-0020AF3D82DA}']
    procedure GetOlePicture(var OlePicture: IPictureDisp);
    procedure SetOlePicture(const OlePicture: IPictureDisp);
  end;

  TPictureAdapter = class(TCustomAdapter,
    IChangeNotifier,
    IPictureAccess)
  private
    FPicture: TPicture;
  protected
    { IPictureAccess }
    procedure GetOlePicture(var OlePicture: IPictureDisp);
    procedure SetOlePicture(const OlePicture: IPictureDisp);
    procedure Update; override;
  public
    constructor Create(Picture: TPicture);
  end;

  TOleGraphic = class(TGraphic)
  private
    FPicture: IPicture;
    function GetMMHeight: Integer;
    function GetMMWidth: Integer;
  protected
    procedure Changed(Sender: TObject); override;
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
    function GetEmpty: Boolean; override;
    function GetHeight: Integer; override;
    function GetPalette: HPALETTE; override;
    function GetTransparent: Boolean; override;
    function GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetPalette(Value: HPALETTE); override;
    procedure SetWidth(Value: Integer); override;
  public
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromFile(const Filename: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE); override;
    property MMHeight: Integer read GetMMHeight;      // in .01 mm units
    property MMWidth: Integer read GetMMWidth;
    property Picture: IPicture read FPicture write FPicture;
  end;

  TStringsAdapter = class(TAutoIntfObject, IStrings, IStringsAdapter)
  private
    FStrings: TStrings;
  protected
    { IStringsAdapter }
    procedure ReferenceStrings(S: TStrings);
    procedure ReleaseStrings;
    { IStrings }
    function Get_ControlDefault(Index: Integer): OleVariant; safecall;
    procedure Set_ControlDefault(Index: Integer; Value: OleVariant); safecall;
    function Count: Integer; safecall;
    function Get_Item(Index: Integer): OleVariant; safecall;
    procedure Set_Item(Index: Integer; Value: OleVariant); safecall;
    procedure Remove(Index: Integer); safecall;
    procedure Clear; safecall;
    function Add(Item: OleVariant): Integer; safecall;
    function _NewEnum: IUnknown; safecall;
  public
    constructor Create(Strings: TStrings);
  end;

procedure GetOleFont(Font: TFont; var OleFont: IFontDisp);
procedure SetOleFont(Font: TFont; const OleFont: IFontDisp);
procedure GetOlePicture(Picture: TPicture; var OlePicture: IPictureDisp);
procedure SetOlePicture(Picture: TPicture; const OlePicture: IPictureDisp);
procedure GetOleStrings(Strings: TStrings; var OleStrings: IStrings);
procedure SetOleStrings(Strings: TStrings; const OleStrings: IStrings);

implementation

const
  OCM_BASE = $2000;

type

  TWinControlAccess = class(TWinControl);

  IStdEvents = dispinterface
    ['{00020400-0000-0000-C000-000000000046}']
    procedure Click; dispid DISPID_CLICK;
    procedure DblClick; dispid DISPID_DBLCLICK;
    procedure KeyDown(var KeyCode: Smallint;
      Shift: Smallint); dispid DISPID_KEYDOWN;
    procedure KeyPress(var KeyAscii: Smallint); dispid DISPID_KEYPRESS;
    procedure KeyUp(var KeyCode: Smallint;
      Shift: Smallint); dispid DISPID_KEYDOWN;
    procedure MouseDown(Button, Shift: Smallint;
      X, Y: Integer); dispid DISPID_MOUSEDOWN;
    procedure MouseMove(Button, Shift: Smallint;
      X, Y: Integer); dispid DISPID_MOUSEMOVE;
    procedure MouseUp(Button, Shift: Smallint;
      X, Y: Integer); dispid DISPID_MOUSEUP;
  end;

var
  xParkingWindow: HWnd;

{ Dynamically load functions used in OLEPRO32.DLL }

function OleCreatePropertyFrame(hwndOwner: HWnd; x, y: Integer;
  lpszCaption: POleStr; cObjects: Integer; pObjects: Pointer; cPages: Integer;
  pPageCLSIDs: Pointer; lcid: TLCID; dwReserved: Longint;
  pvReserved: Pointer): HResult; forward;
function OleCreateFontIndirect(const FontDesc: TFontDesc; const iid: TIID;
  out vObject): HResult; forward;
function OleCreatePictureIndirect(const PictDesc: TPictDesc; const iid: TIID;
  fOwn: BOOL; out vObject): HResult; forward;
function OleLoadPicture(stream: IStream; lSize: Longint; fRunmode: BOOL;
  const iid: TIID; out vObject): HResult; forward;


function ParkingWindowProc(Wnd: HWND; Msg, wParam, lParam: Longint): Longint; stdcall;
var
  ControlWnd: HWND;
begin
  case Msg of
    WM_COMPAREITEM, WM_DELETEITEM, WM_DRAWITEM, WM_MEASUREITEM, WM_COMMAND:
      begin
        case Msg of
          WM_COMPAREITEM: ControlWnd := PCompareItemStruct(lParam).CtlID;
          WM_DELETEITEM:  ControlWnd := PDeleteItemStruct(lParam).CtlID;
          WM_DRAWITEM:    ControlWnd := PDrawItemStruct(lParam).CtlID;
          WM_MEASUREITEM: ControlWnd := PMeasureItemStruct(lParam).CtlID;
          WM_COMMAND:     ControlWnd := HWND(lParam);
        else
          Result := 0;
          Exit;
        end;
        Result := SendMessage(ControlWnd, OCM_BASE + Msg, wParam, lParam);
      end;
  else
    Result := DefWindowProc(Wnd, Msg, WParam, LParam);
  end;
end;

function ParkingWindow: HWnd;
var
  TempClass: TWndClass;
begin
  Result := xParkingWindow;
  if Result <> 0 then Exit;

  FillChar(TempClass, sizeof(TempClass), 0);
  if not GetClassInfo(HInstance, 'DAXParkingWindow', TempClass) then
  begin
    TempClass.hInstance := HInstance;
    TempClass.lpfnWndProc := @ParkingWindowProc;
    TempClass.lpszClassName := 'DAXParkingWindow';
    if Windows.RegisterClass(TempClass) = 0 then
      raise EOutOfResources.Create(SWindowClass);
  end;
  xParkingWindow := CreateWindowEx(WS_EX_TOOLWINDOW, TempClass.lpszClassName, nil,
    WS_POPUP, GetSystemMetrics(SM_CXSCREEN) div 2,
    GetSystemMetrics(SM_CYSCREEN) div 2, 0, 0, 0, 0, HInstance, nil);
  SetWindowPos(xParkingWindow, 0, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOREDRAW
    or SWP_NOZORDER or SWP_SHOWWINDOW);
  Result := xParkingWindow;
end;

function HandleException: HResult;
var
  E: TObject;
begin
  E := ExceptObject;
  if (E is EOleSysError) and (EOleSysError(E).ErrorCode < 0) then
    Result := EOleSysError(E).ErrorCode else
    Result := E_UNEXPECTED;
end;

procedure FreeObjects(List: TList);
var
  I: Integer;
begin
  for I := List.Count - 1 downto 0 do TObject(List[I]).Free;
end;

procedure FreeObjectList(List: TList);
begin
  if List <> nil then
  begin
    FreeObjects(List);
    List.Free;
  end;
end;

function CoAllocMem(Size: Integer): Pointer;
begin
  Result := CoTaskMemAlloc(Size);
  if Result = nil then OleError(E_OUTOFMEMORY);
  FillChar(Result^, Size, 0);
end;

procedure CoFreeMem(P: Pointer);
begin
  if P <> nil then CoTaskMemFree(P);
end;

function CoAllocString(const S: string): POleStr;
var
  W: WideString;
  Size: Integer;
begin
  W := S;
  Size := (Length(W) + 1) * 2;
  Result := CoAllocMem(Size);
  Move(PWideChar(W)^, Result^, Size);
end;

{ Connect an IConnectionPoint interface }

procedure InterfaceConnect(const Source: IUnknown; const IID: TIID;
  const Sink: IUnknown; var Connection: Longint);
var
  CPC: IConnectionPointContainer;
  CP: IConnectionPoint;
begin
  Connection := 0;
  if Source.QueryInterface(IConnectionPointContainer, CPC) >= 0 then
    if CPC.FindConnectionPoint(IID, CP) >= 0 then
      CP.Advise(Sink, Connection);
end;

{ Disconnect an IConnectionPoint interface }

procedure InterfaceDisconnect(const Source: IUnknown; const IID: TIID;
  var Connection: Longint);
var
  CPC: IConnectionPointContainer;
  CP: IConnectionPoint;
begin
  if Connection <> 0 then
    if Source.QueryInterface(IConnectionPointContainer, CPC) >= 0 then
      if CPC.FindConnectionPoint(IID, CP) >= 0 then
        if CP.Unadvise(Connection) >= 0 then Connection := 0;
end;

function GetFontAccess(Font: TFont): IFontAccess;
begin
  if Font.FontAdapter = nil then
    Font.FontAdapter := TFontAdapter.Create(Font);
  Result := Font.FontAdapter as IFontAccess;
end;

function GetPictureAccess(Picture: TPicture): IPictureAccess;
begin
  if Picture.PictureAdapter = nil then
    Picture.PictureAdapter := TPictureAdapter.Create(Picture);
  Result := Picture.PictureAdapter as IPictureAccess;
end;

procedure GetOleFont(Font: TFont; var OleFont: IFontDisp);
begin
  GetFontAccess(Font).GetOleFont(OleFont);
end;

procedure SetOleFont(Font: TFont; const OleFont: IFontDisp);
begin
  GetFontAccess(Font).SetOleFont(OleFont);
end;

procedure GetOlePicture(Picture: TPicture; var OlePicture: IPictureDisp);
begin
  GetPictureAccess(Picture).GetOlePicture(OlePicture);
end;

procedure SetOlePicture(Picture: TPicture; const OlePicture: IPictureDisp);
begin
  GetPictureAccess(Picture).SetOlePicture(OlePicture);
end;

function GetKeyModifiers: Integer;
begin
  Result := 0;
  if GetKeyState(VK_SHIFT) < 0 then Result := 1;
  if GetKeyState(VK_CONTROL) < 0 then Result := Result or 2;
  if GetKeyState(VK_MENU) < 0 then Result := Result or 4;
end;

function GetEventShift(Shift: TShiftState): Integer;
const
  ShiftMap: array[0..7] of Byte = (0, 1, 4, 5, 2, 3, 6, 7);
begin
  Result := ShiftMap[Byte(Shift) and 7];
end;

function GetEventButton(Button: TMouseButton): Integer;
begin
  Result := 1 shl Ord(Button);
end;

{ TOleStream }

constructor TOleStream.Create(const Stream: IStream);
begin
  FStream := Stream;
end;

function TOleStream.Read(var Buffer; Count: Longint): Longint;
begin
  OleCheck(FStream.Read(@Buffer, Count, @Result));
end;

function TOleStream.Seek(Offset: Longint; Origin: Word): Longint;
var
  Pos: Largeint;
begin
  OleCheck(FStream.Seek(Offset, Origin, Pos));
  Result := Longint(Pos);
end;

function TOleStream.Write(const Buffer; Count: Longint): Longint;
begin
  OleCheck(FStream.Write(@Buffer, Count, @Result));
end;

{ TAggregatedObject }

constructor TAggregatedObject.Create(const Controller: IUnknown);
begin
  FController := Pointer(Controller);
end;

function TAggregatedObject.GetController: IUnknown;
begin
  Result := IUnknown(FController);
end;

{ TAggregatedObject.IUnknown }

function TAggregatedObject.QueryInterface(const IID: TGUID; out Obj): Integer;
begin
  Result := IUnknown(FController).QueryInterface(IID, Obj);
end;

function TAggregatedObject._AddRef: Integer;
begin
  Result := IUnknown(FController)._AddRef;
end;

function TAggregatedObject._Release: Integer; stdcall;
begin
  Result := IUnknown(FController)._Release;
end;

{ TContainedObject.IUnknown }

function TContainedObject.QueryInterface(const IID: TGUID; out Obj): Integer;
begin
  if GetInterface(IID, Obj) then Result := S_OK else Result := E_NOINTERFACE;
end;

{ TEnumConnections }

type
  TEnumConnections = class(TContainedObject, IEnumConnections)
  private
    FConnectionPoint: TConnectionPoint;
    FIndex: Integer;
    FCount: Integer;
  protected
    { IEnumConnections }
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enum: IEnumConnections): HResult; stdcall;
  public
    constructor Create(ConnectionPoint: TConnectionPoint; Index: Integer);
  end;

constructor TEnumConnections.Create(ConnectionPoint: TConnectionPoint;
  Index: Integer);
begin
  inherited Create(ConnectionPoint.Controller);
  FConnectionPoint := ConnectionPoint;
  FIndex := Index;
  FCount := ConnectionPoint.FSinkList.Count;
end;

{ TEnumConnections.IEnumConnections }

function TEnumConnections.Next(celt: Longint; out elt;
  pceltFetched: PLongint): HResult;
type
  TConnectDatas = array[0..1023] of TConnectData;
var
  I: Integer;
  P: Pointer;
begin
  I := 0;
  while (I < celt) and (FIndex < FCount) do
  begin
    P := FConnectionPoint.FSinkList[FIndex];
    if P <> nil then
    begin
      Pointer(TConnectDatas(elt)[I].pUnk) := nil;
      TConnectDatas(elt)[I].pUnk := IUnknown(P);
      TConnectDatas(elt)[I].dwCookie := FIndex + 1;
      Inc(I);
    end;
    Inc(FIndex);
  end;
  if pceltFetched <> nil then pceltFetched^ := I;
  if I = celt then Result := S_OK else Result := S_FALSE;
end;

function TEnumConnections.Skip(celt: Longint): HResult; stdcall;
begin
  Result := S_FALSE;
  while (celt > 0) and (FIndex < FCount) do
  begin
    if FConnectionPoint.FSinkList[FIndex] <> nil then Dec(celt);
    Inc(FIndex);
  end;
  if celt = 0 then Result := S_OK;
end;

function TEnumConnections.Reset: HResult; stdcall;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TEnumConnections.Clone(out enum: IEnumConnections): HResult; stdcall;
begin
  try
    enum := TEnumConnections.Create(FConnectionPoint, FIndex);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ TConnectionPoint }

constructor TConnectionPoint.Create(Container: TConnectionPoints;
  const IID: TGUID; Kind: TConnectionKind;
  OnConnect: TConnectEvent);
begin
  inherited Create(Container.Controller);
  FContainer := Container;
  FContainer.FConnectionPoints.Add(Self);
  FSinkList := TList.Create;
  FSinkCount := 0;
  FIID := IID;
  FKind := Kind;
  FOnConnect := OnConnect;
end;

destructor TConnectionPoint.Destroy;
var
  I: Integer;
begin
  if FContainer <> nil then FContainer.FConnectionPoints.Remove(Self);
  if FSinkList <> nil then
  begin
    for I := 0 to FSinkList.Count - 1 do
      if FSinkList[I] <> nil then RemoveSink(I);
    FSinkList.Free;
  end;
  inherited Destroy;
end;

function TConnectionPoint.AddSink(const Sink: IUnknown): Integer;
var
  I: Integer;
begin
  I := 0;
  while I < FSinkList.Count do
    if FSinkList[I] <> nil then Break else Inc(I);
  if I >= FSinkList.Count then
    FSinkList.Add(Pointer(Sink)) else
    FSinkList[I] := Pointer(Sink);
  Inc(FSinkCount);
  Sink._AddRef;
  Result := I;
end;

procedure TConnectionPoint.RemoveSink(Cookie: Longint);
var
  Sink: Pointer;
begin
  Sink := FSinkList[Cookie];
  FSinkList[Cookie] := nil;
  Dec(FSinkCount);
  IUnknown(Sink)._Release;
end;

{ TConnectionPoint.IConnectionPoint }

function TConnectionPoint.GetConnectionInterface(out iid: TIID): HResult;
begin
  iid := FIID;
  Result := S_OK;
end;

function TConnectionPoint.GetConnectionPointContainer(
  out cpc: IConnectionPointContainer): HResult;
begin
  cpc := FContainer;
  Result := S_OK;
end;

function TConnectionPoint.Advise(const unkSink: IUnknown;
  out dwCookie: Longint): HResult;
begin
  if (FKind = ckSingle) and (FSinkCount > 0) then
  begin
    Result := CONNECT_E_CANNOTCONNECT;
    Exit;
  end;
  try
    if Assigned(FOnConnect) then FOnConnect(unkSink, True);
    dwCookie := AddSink(unkSink) + 1;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TConnectionPoint.Unadvise(dwCookie: Longint): HResult;
begin
  Dec(dwCookie);
  if (dwCookie < 0) or (dwCookie >= FSinkList.Count) or
    (FSinkList[dwCookie] = nil) then
  begin
    Result := CONNECT_E_NOCONNECTION;
    Exit;
  end;
  try
    if Assigned(FOnConnect) then
      FOnConnect(IUnknown(FSinkList[dwCookie]), False);
    RemoveSink(dwCookie);
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TConnectionPoint.EnumConnections(out enum: IEnumConnections): HResult;
begin
  try
    enum := TEnumConnections.Create(Self, 0);
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

{ TEnumConnectionPoints }

type
  TEnumConnectionPoints = class(TContainedObject, IEnumConnectionPoints)
  private
    FContainer: TConnectionPoints;
    FIndex: Integer;
  protected
    { IEnumConnectionPoints }
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enum: IEnumConnectionPoints): HResult; stdcall;
  public
    constructor Create(Container: TConnectionPoints;
      Index: Integer);
  end;

constructor TEnumConnectionPoints.Create(Container: TConnectionPoints;
  Index: Integer);
begin
  inherited Create(Container.Controller);
  FContainer := Container;
  FIndex := Index;
end;

{ TEnumConnectionPoints.IEnumConnectionPoints }

type
  TPointerList = array[0..0] of Pointer;

function TEnumConnectionPoints.Next(celt: Longint; out elt;
  pceltFetched: PLongint): HResult;
var
  I: Integer;
  P: Pointer;
begin
  I := 0;
  while (I < celt) and (FIndex < FContainer.FConnectionPoints.Count) do
  begin
    P := Pointer(IConnectionPoint(TConnectionPoint(
      FContainer.FConnectionPoints[FIndex])));
    IConnectionPoint(P)._AddRef;
    TPointerList(elt)[I] := P;
    Inc(I);
    Inc(FIndex);
  end;
  if pceltFetched <> nil then pceltFetched^ := I;
  if I = celt then Result := S_OK else Result := S_FALSE;
end;

function TEnumConnectionPoints.Skip(celt: Longint): HResult; stdcall;
begin
  if FIndex + celt <= FContainer.FConnectionPoints.Count then
  begin
    FIndex := FIndex + celt;
    Result := S_OK;
  end else
  begin
    FIndex := FContainer.FConnectionPoints.Count;
    Result := S_FALSE;
  end;
end;

function TEnumConnectionPoints.Reset: HResult; stdcall;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TEnumConnectionPoints.Clone(
  out enum: IEnumConnectionPoints): HResult; stdcall;
begin
  try
    enum := TEnumConnectionPoints.Create(FContainer, FIndex);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ TConnectionPoints }

constructor TConnectionPoints.Create(const Controller: IUnknown);
begin
  inherited Create(Controller);
  FConnectionPoints := TList.Create;
end;

destructor TConnectionPoints.Destroy;
begin
  FreeObjectList(FConnectionPoints);
end;

function TConnectionPoints.CreateConnectionPoint(const IID: TGUID;
  Kind: TConnectionKind; OnConnect: TConnectEvent): TConnectionPoint;
begin
  Result := TConnectionPoint.Create(Self, IID, Kind, OnConnect);
end;

{ TConnectionPoints.IConnectionPointContainer }

function TConnectionPoints.EnumConnectionPoints(
  out enum: IEnumConnectionPoints): HResult;
begin
  try
    enum := TEnumConnectionPoints.Create(Self, 0);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TConnectionPoints.FindConnectionPoint(const iid: TIID;
  out cp: IConnectionPoint): HResult;
var
  I: Integer;
  ConnectionPoint: TConnectionPoint;
begin
  for I := 0 to FConnectionPoints.Count - 1 do
  begin
    ConnectionPoint := FConnectionPoints[I];
    if IsEqualGUID(ConnectionPoint.FIID, iid) then
    begin
      cp := ConnectionPoint;
      Result := S_OK;
      Exit;
    end;
  end;
  Result := CONNECT_E_NOCONNECTION;
end;

{ TReflectorWindow }

type
  TReflectorWindow = class(TWinControl)
  private
    FControl: TControl;
    FInSize: Boolean;
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  public
  constructor Create(ParentWindow: HWND; Control: TControl);
  end;

constructor TReflectorWindow.Create(ParentWindow: HWND; Control: TControl);
begin
  inherited CreateParented(ParentWindow);
  FControl := Control;
  FInSize := True;
  try
  FControl.Parent := Self;
  FControl.SetBounds(0, 0, FControl.Width, FControl.Height);
  finally
    FInSize := False;
  end;
  SetBounds(Left, Top, FControl.Width, FControl.Height);
end;

procedure TReflectorWindow.WMGetDlgCode(var Message: TMessage);
begin
  TWinControlAccess(FControl).WndProc(Message);
end;

procedure TReflectorWindow.WMSetFocus(var Message: TWMSetFocus);
begin
  if FControl is TWinControl then
    Windows.SetFocus(TWinControl(FControl).Handle) else
    inherited;
end;

procedure TReflectorWindow.WMSize(var Message: TWMSize);
begin
  if not FInSize then
  begin
    FInSize := True;
    try
      FControl.SetBounds(0, 0, Message.Width, Message.Height);
      SetBounds(Left, Top, FControl.Width, FControl.Height);
    finally
      FInSize := False;
    end;
  end;
  inherited;
end;

{ TDispatchSilencer }

type
  TDispatchSilencer = class(TInterfacedObject, IUnknown, IDispatch)
  private
    Dispatch: IDispatch;
    DispIntfIID: TGUID;
  public
    constructor Create(ADispatch: IUnknown; const ADispIntfIID: TGUID);
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): Integer; stdcall;
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): Integer; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): Integer; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): Integer; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): Integer; stdcall;
  end;

constructor TDispatchSilencer.Create(ADispatch: IUnknown;
  const ADispIntfIID: TGUID);
begin
  inherited Create;
  DispIntfIID := ADispIntfIID;
  OleCheck(ADispatch.QueryInterface(ADispIntfIID, Dispatch));
end;

function TDispatchSilencer.QueryInterface(const IID: TGUID; out Obj): Integer;
begin
  Result := inherited QueryInterface(IID, Obj);
  if Result = E_NOINTERFACE then
    if IsEqualGUID(IID, DispIntfIID) then
    begin
      IDispatch(Obj) := Self;
      Result := S_OK;
    end
    else
      Result := Dispatch.QueryInterface(IID, Obj);
end;

function TDispatchSilencer.GetTypeInfoCount(out Count: Integer): Integer;
begin
  Result := Dispatch.GetTypeInfoCount(Count);
end;

function TDispatchSilencer.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): Integer;
begin
  Result := Dispatch.GetTypeInfo(Index, LocaleID, TypeInfo);
end;

function TDispatchSilencer.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): Integer;
begin
  Result := Dispatch.GetIDsOfNames(IID, Names, NameCount, LocaleID, DispIDs);
end;

function TDispatchSilencer.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): Integer;
begin
  { Ignore error since some containers, such as Internet Explorer 3.0x, will
    return error when the method was not handled, or scripting errors occur }
  Dispatch.Invoke(DispID, IID, LocaleID, Flags, Params, VarResult, ExcepInfo,
    ArgErr);
  Result := S_OK;
end;

{ TOleLinkStub }
type
  TOleLinkStub = class(TInterfacedObject, IUnknown, IOleLink)
  private
    Controller: IUnknown;
  public
    constructor Create(AController: IUnknown);
    destructor Destroy; override;
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): Integer; stdcall;
    { IOleLink }
    function SetUpdateOptions(dwUpdateOpt: Longint): HResult;
      stdcall;
    function GetUpdateOptions(out dwUpdateOpt: Longint): HResult; stdcall;
    function SetSourceMoniker(const mk: IMoniker; const clsid: TCLSID): HResult;
      stdcall;
    function GetSourceMoniker(out mk: IMoniker): HResult; stdcall;
    function SetSourceDisplayName(pszDisplayName: POleStr): HResult;
      stdcall;
    function GetSourceDisplayName(out pszDisplayName: POleStr): HResult;
      stdcall;
    function BindToSource(bindflags: Longint; const bc: IBindCtx): HResult;
      stdcall;
    function BindIfRunning: HResult; stdcall;
    function GetBoundSource(out unk: IUnknown): HResult; stdcall;
    function UnbindSource: HResult; stdcall;
    function Update(const bc: IBindCtx): HResult; stdcall;
  end;

constructor TOleLinkStub.Create(AController: IUnknown);
begin
  inherited Create;
  Controller := AController;
end;

destructor TOleLinkStub.Destroy;
begin
  inherited;
end;

{ TOleLinkStub.IUnknown }

function TOleLinkStub.QueryInterface(const IID: TGUID; out Obj): Integer;
begin
  Result := Controller.QueryInterface(IID, Obj);
end;

{ TOleLinkStub.IOleLink }

function TOleLinkStub.SetUpdateOptions(dwUpdateOpt: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub.GetUpdateOptions(out dwUpdateOpt: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub.SetSourceMoniker(const mk: IMoniker; const clsid: TCLSID): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub.GetSourceMoniker(out mk: IMoniker): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub.SetSourceDisplayName(pszDisplayName: POleStr): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub.GetSourceDisplayName(out pszDisplayName: POleStr): HResult;
begin
  pszDisplayName := nil;
  Result := E_FAIL;
end;

function TOleLinkStub.BindToSource(bindflags: Longint; const bc: IBindCtx): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub.BindIfRunning: HResult;
begin
  Result := S_OK;
end;

function TOleLinkStub.GetBoundSource(out unk: IUnknown): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub.UnbindSource: HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleLinkStub.Update(const bc: IBindCtx): HResult;
begin
  Result := E_NOTIMPL;
end;

{ TActiveXControl }

procedure TActiveXControl.Initialize;
begin
  FConnectionPoints := TConnectionPoints.Create(Self);
  FControlFactory := TActiveXControlFactory(Factory);
  if FControlFactory.FEventTypeInfo <> nil then
    FConnectionPoints.CreateConnectionPoint(FControlFactory.FEventIID,
      ckSingle, EventConnect);
  FPropertySinks := FConnectionPoints.CreateConnectionPoint(IPropertyNotifySink,
    ckMulti, nil);
  FControl := FControlFactory.WinControlClass.CreateParented(ParkingWindow);
  if csReflector in FControl.ControlStyle then
    FWinControl := TReflectorWindow.Create(ParkingWindow, FControl) else
    FWinControl := FControl;
  FControlWndProc := FControl.WindowProc;
  FControl.WindowProc := WndProc;
  InitializeControl;
end;

destructor TActiveXControl.Destroy;
begin
  if Assigned(FControlWndProc) then FControl.WindowProc := FControlWndProc;
  FControl.Free;
  if FWinControl <> FControl then FWinControl.Free;
  FConnectionPoints.Free;
  inherited Destroy;
end;

function TActiveXControl.CreateAdviseHolder: HResult;
begin
  if FOleAdviseHolder = nil then
    Result := CreateOleAdviseHolder(FOleAdviseHolder) else
    Result := S_OK;
end;

procedure TActiveXControl.DefinePropertyPages(
  DefinePropertyPage: TDefinePropertyPage);
begin
end;

procedure TActiveXControl.EventConnect(const Sink: IUnknown;
  Connecting: Boolean);
begin
  if Connecting then
  begin
    OleCheck(Sink.QueryInterface(FControlFactory.FEventIID, FEventSink));
    EventSinkChanged(TDispatchSilencer.Create(Sink, FControlFactory.FEventIID));
  end
  else
  begin
    FEventSink := nil;
    EventSinkChanged(nil);
  end;
end;

procedure TActiveXControl.EventSinkChanged(const EventSink: IUnknown);
begin
end;

function TActiveXControl.GetPropertyString(DispID: Integer;
  var S: string): Boolean;
begin
  Result := False;
end;

function TActiveXControl.GetPropertyStrings(DispID: Integer;
  Strings: TStrings): Boolean;
begin
  Result := False;
end;

procedure TActiveXControl.GetPropertyValue(DispID, Cookie: Integer;
  var Value: OleVariant);
begin
end;

procedure TActiveXControl.InitializeControl;
begin
end;

function TActiveXControl.InPlaceActivate(ActivateUI: Boolean): HResult;
var
  InPlaceActivateSent: Boolean;
  ParentWindow: HWND;
  PosRect, ClipRect: TRect;
  FrameInfo: TOleInPlaceFrameInfo;
begin
  Result := S_OK;
  FWinControl.Visible := True;
  InPlaceActivateSent := False;
  if not FInPlaceActive then
    try
      if FOleClientSite = nil then OleError(E_FAIL);
      OleCheck(FOleClientSite.QueryInterface(IOleInPlaceSite, FOleInPlaceSite));
      if FOleInPlaceSite.CanInPlaceActivate <> S_OK then OleError(E_FAIL);
      OleCheck(FOleInPlaceSite.OnInPlaceActivate);
      InPlaceActivateSent := True;
      OleCheck(FOleInPlaceSite.GetWindow(ParentWindow));
      FrameInfo.cb := SizeOf(FrameInfo);
      OleCheck(FOleInPlaceSite.GetWindowContext(FOleInPlaceFrame,
        FOleInPlaceUIWindow, PosRect, ClipRect, FrameInfo));
      if FOleInPlaceFrame = nil then OleError(E_FAIL);
      with PosRect do
        FWinControl.SetBounds(Left, Top, Right - Left, Bottom - Top);
      FWinControl.ParentWindow := ParentWindow;
      FWinControl.Visible := True;
      FInPlaceActive := True;
      FOleClientSite.ShowObject;
    except
      FInPlaceActive := False;
      FOleInPlaceUIWindow := nil;
      FOleInPlaceFrame := nil;
      if InPlaceActivateSent then FOleInPlaceSite.OnInPlaceDeactivate;
      FOleInPlaceSite := nil;
      Result := HandleException;
      Exit;
    end;
  if ActivateUI and not FUIActive then
  begin
    FUIActive := True;
    FOleInPlaceSite.OnUIActivate;
    SetFocus(FWinControl.Handle);
    FOleInPlaceFrame.SetActiveObject(Self, nil);
    if FOleInPlaceUIWindow <> nil then
      FOleInPlaceUIWindow.SetActiveObject(Self, nil);
    FOleInPlaceFrame.SetBorderSpace(nil);
    if FOleInPlaceUIWindow <> nil then
      FOleInPlaceUIWindow.SetBorderSpace(nil);
  end;
end;

procedure TActiveXControl.LoadFromStream(const Stream: IStream);
var
  OleStream: TOleStream;
begin
  OleStream := TOleStream.Create(Stream);
  try
    OleStream.ReadComponent(FControl);
  finally
    OleStream.Free;
  end;
end;

function TActiveXControl.ObjQueryInterface(const IID: TGUID; out Obj): Integer;
begin
  if IsEqualGuid(IID, ISimpleFrameSite) and
    ((FControlFactory.MiscStatus and OLEMISC_SIMPLEFRAME) = 0) then
    Result := E_NOINTERFACE
  else
  begin
    Result := inherited ObjQueryInterface(IID, Obj);
    if Result <> 0 then
      if IsEqualGuid(IID, IOleLink) then
      begin
        // Work around for an MS Access 97 bug that requires IOleLink
        // to be stubbed.
        Pointer(Obj) := nil;
        IOleLink(Obj) := TOleLinkStub.Create(Self);
      end
      else
      if FConnectionPoints.GetInterface(IID, Obj) then Result := S_OK;
  end;
end;

procedure TActiveXControl.PerformVerb(Verb: Integer);
begin
end;

function TActiveXControl.GetPropertyID(const PropertyName: WideString): Integer;
var
  PName: ^PWideChar;
begin
  PName := @PropertyName;
  if PropertyName = '' then
    Result := DISPID_UNKNOWN else
    OleCheck(GetIDsOfNames(GUID_NULL, @PName, 1, GetThreadLocale,
      @Result));
end;

function TActiveXControl.PropRequestEdit(const PropertyName: WideString): Boolean;
var
  PropID: Integer;
  Enum: IEnumConnections;
  ConnectData: TConnectData;
  Fetched: Longint;
begin
  Result := True;
  PropID := GetPropertyID(PropertyName);
  OleCheck(FPropertySinks.EnumConnections(Enum));
  while Enum.Next(1, ConnectData, @Fetched) = S_OK do
  begin
    Result := (ConnectData.pUnk as IPropertyNotifySink).OnRequestEdit(PropID) = S_OK;
    ConnectData.pUnk := nil;
    if not Result then Exit;
  end;
end;

procedure TActiveXControl.PropChanged(const PropertyName: WideString);
var
  PropID: Integer;
  Enum: IEnumConnections;
  ConnectData: TConnectData;
  Fetched: Longint;
begin
  PropID := GetPropertyID(PropertyName);
  OleCheck(FPropertySinks.EnumConnections(Enum));
  while Enum.Next(1, ConnectData, @Fetched) = S_OK do
  begin
    (ConnectData.pUnk as IPropertyNotifySink).OnChanged(PropID);
    ConnectData.pUnk := nil;
  end;
end;

procedure TActiveXControl.RecreateWnd;
var
  WasUIActive: Boolean;
  PrevWnd: HWND;
begin
  if FWinControl.HandleAllocated then
  begin
    WasUIActive := FUIActive;
    PrevWnd := Windows.GetWindow(FWinControl.Handle, GW_HWNDPREV);
    InPlaceDeactivate;
    TWinControlAccess(FWinControl).DestroyHandle;
    if InPlaceActivate(WasUIActive) = S_OK then
      SetWindowPos(FWinControl.Handle, PrevWnd, 0, 0, 0, 0,
        SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE);
  end;
end;

procedure TActiveXControl.SaveToStream(const Stream: IStream);
var
  OleStream: TOleStream;
  Writer: TWriter;
begin
  OleStream := TOleStream.Create(Stream);
  try
    Writer := TWriter.Create(OleStream, 4096);
    try
      Writer.IgnoreChildren := True;
      Writer.WriteDescendent(FControl, nil);
    finally
      Writer.Free;
    end;
  finally
    OleStream.Free;
  end;
end;

procedure TActiveXControl.ShowPropertyDialog;
var
  Unknown: IUnknown;
  Pages: TCAGUID;
begin
  if (FOleControlSite <> nil) and
    (FOleControlSite.ShowPropertyFrame = S_OK) then Exit;
  OleCheck(GetPages(Pages));
  try
    if Pages.cElems > 0 then
    begin
      if FOleInPlaceFrame <> nil then
        FOleInPlaceFrame.EnableModeless(False);
      try
        Unknown := Self;
        OleCheck(OleCreatePropertyFrame(GetActiveWindow, 16, 16,
          PWideChar(FAmbientDispatch.DisplayName), {!!!}
          1, @Unknown, Pages.cElems, Pages.pElems,
          GetSystemDefaultLCID, 0, nil));
      finally
        if FOleInPlaceFrame <> nil then
          FOleInPlaceFrame.EnableModeless(True);
      end;
    end;
  finally
    CoFreeMem(pages.pElems);
  end;
end;

procedure TActiveXControl.StdClickEvent(Sender: TObject);
begin
  if FEventSink <> nil then IStdEvents(FEventSink).Click;
end;

procedure TActiveXControl.StdDblClickEvent(Sender: TObject);
begin
  if FEventSink <> nil then IStdEvents(FEventSink).DblClick;
end;

procedure TActiveXControl.StdKeyDownEvent(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FEventSink <> nil then
    IStdEvents(FEventSink).KeyDown(Smallint(Key), GetEventShift(Shift));
end;

procedure TActiveXControl.StdKeyPressEvent(Sender: TObject; var Key: Char);
var
  KeyAscii: Smallint;
begin
  if FEventSink <> nil then
  begin
    KeyAscii := Ord(Key);
    IStdEvents(FEventSink).KeyPress(KeyAscii);
    Key := Chr(KeyAscii);
  end;
end;

procedure TActiveXControl.StdKeyUpEvent(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FEventSink <> nil then
    IStdEvents(FEventSink).KeyUp(Smallint(Key), GetEventShift(Shift));
end;

procedure TActiveXControl.StdMouseDownEvent(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FEventSink <> nil then
    IStdEvents(FEventSink).MouseDown(GetEventButton(Button),
      GetEventShift(Shift), X, Y);
end;

procedure TActiveXControl.StdMouseMoveEvent(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if FEventSink <> nil then
    IStdEvents(FEventSink).MouseMove((Byte(Shift) shr 3) and 7,
      GetEventShift(Shift), X, Y);
end;

procedure TActiveXControl.StdMouseUpEvent(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FEventSink <> nil then
    IStdEvents(FEventSink).MouseUp(GetEventButton(Button),
      GetEventShift(Shift), X, Y);
end;

procedure TActiveXControl.ViewChanged;
begin
  if FAdviseSink <> nil then
  begin
    FAdviseSink.OnViewChange(DVASPECT_CONTENT, -1);
    if FAdviseFlags and ADVF_ONLYONCE <> 0 then FAdviseSink := nil;
  end;
end;

procedure TActiveXControl.WndProc(var Message: TMessage);
var
  Handle: HWnd;
  FilterMessage: Boolean;
  Cookie: Longint;

  procedure ControlWndProc;
  begin
    with Message do
      if (Msg >= OCM_BASE) and (Msg < OCM_BASE + WM_USER) then
        Msg := Msg + (CN_BASE - OCM_BASE);
    FControlWndProc(Message);
    with Message do
      if (Msg >= CN_BASE) and (Msg < CN_BASE + WM_USER) then
        Msg := Msg - (CN_BASE - OCM_BASE);
  end;

begin
  with Message do
  begin
    Handle := TWinControlAccess(FControl).WindowHandle;
    FilterMessage := ((Msg < CM_BASE) or (Msg >= $C000)) and
      (FSimpleFrameSite <> nil) and FInPlaceActive;
    if FilterMessage then
      if FSimpleFrameSite.PreMessageFilter(Handle, Msg, WParam, LParam,
        Integer(Result), Cookie) = S_FALSE then Exit;
    case Msg of
      WM_SETFOCUS, WM_KILLFOCUS:
        begin
          ControlWndProc;
          if FOleControlSite <> nil then
            FOleControlSite.OnFocus(Msg = WM_SETFOCUS);
        end;
      CM_VISIBLECHANGED:
        begin
          if FControl <> FWinControl then FWinControl.Visible := FControl.Visible;
          if not FWinControl.Visible then UIDeactivate;
          ControlWndProc;
        end;
      CM_RECREATEWND:
        if FInPlaceActive and (FControl = FWinControl) then
          RecreateWnd
        else
        begin
          ControlWndProc;
          ViewChanged;
        end;
      CM_INVALIDATE,
      WM_SETTEXT:
        begin
          ControlWndProc;
          if not FInPlaceActive then ViewChanged;
        end;
      WM_NCHITTEST:
        begin
          ControlWndProc;
          if Message.Result = HTTRANSPARENT then Message.Result := HTCLIENT;
        end;
    else
      ControlWndProc;
    end;
    if FilterMessage then
      FSimpleFrameSite.PostMessageFilter(Handle, Msg, WParam, LParam,
        Integer(Result), Cookie);
  end;
end;

{ TActiveXControl standard properties }

function TActiveXControl.Get_BackColor: Integer;
begin
  Result := TWinControlAccess(FControl).Color;
end;

function TActiveXControl.Get_Caption: WideString;
begin
  Result := TWinControlAccess(FControl).Caption;
end;

function TActiveXControl.Get_Enabled: WordBool;
begin
  Result := FControl.Enabled;
end;

function TActiveXControl.Get_Font: Font;
begin
  GetOleFont(TWinControlAccess(FControl).Font, Result);
end;

function TActiveXControl.Get_ForeColor: Integer;
begin
  Result := TWinControlAccess(FControl).Font.Color;
end;

function TActiveXControl.Get_HWnd: Integer;
begin
  Result := FControl.Handle;
end;

function TActiveXControl.Get_TabStop: WordBool;
begin
  Result := FControl.TabStop;
end;

function TActiveXControl.Get_Text: WideString;
begin
  Result := TWinControlAccess(FControl).Text;
end;

procedure TActiveXControl.Set_BackColor(Value: Integer);
begin
  TWinControlAccess(FControl).Color := Value;
end;

procedure TActiveXControl.Set_Caption(const Value: WideString);
begin
  TWinControlAccess(FControl).Caption := Value;
end;

procedure TActiveXControl.Set_Enabled(Value: WordBool);
begin
  FControl.Enabled := Value;
end;

procedure TActiveXControl.Set_Font(const Value: Font);
begin
  SetOleFont(TWinControlAccess(FControl).Font, Value);
end;

procedure TActiveXControl.Set_ForeColor(Value: Integer);
begin
  TWinControlAccess(FControl).Font.Color := Value;
end;

procedure TActiveXControl.Set_TabStop(Value: WordBool);
begin
  FControl.TabStop := Value;
end;

procedure TActiveXControl.Set_Text(const Value: WideString);
begin
  TWinControlAccess(FControl).Text := Value;
end;

{ TActiveXControl.IPersist }

function TActiveXControl.GetClassID(out classID: TCLSID): HResult;
begin
  classID := Factory.ClassID;
  Result := S_OK;
end;

{ TActiveXControl.IPersistStreamInit }

function TActiveXControl.IsDirty: HResult;
begin
  if FIsDirty then Result := S_OK else Result := S_FALSE;
end;

function TActiveXControl.PersistStreamLoad(const stm: IStream): HResult;
begin
  try
    LoadFromStream(stm);
    FIsDirty := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl.PersistStreamSave(const stm: IStream;
  fClearDirty: BOOL): HResult;
begin
  try
    SaveToStream(stm);
    if fClearDirty then FIsDirty := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl.GetSizeMax(out cbSize: Largeint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl.InitNew: HResult;
begin
  try
    FIsDirty := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

{ TActiveXControl.IPersistStorage }

function TActiveXControl.PersistStorageInitNew(const stg: IStorage): HResult;
begin
  Result := InitNew;
end;

function TActiveXControl.PersistStorageLoad(const stg: IStorage): HResult;
var
  Stream: IStream;
begin
  try
    OleCheck(stg.OpenStream('CONTROLSAVESTREAM'#0, nil, STGM_READ +
      STGM_SHARE_EXCLUSIVE, 0, Stream));
    LoadFromStream(Stream);
    FIsDirty := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl.PersistStorageSave(const stgSave: IStorage;
  fSameAsLoad: BOOL): HResult;
var
  Stream: IStream;
begin
  try
    OleCheck(stgSave.CreateStream('CONTROLSAVESTREAM'#0, STGM_WRITE +
      STGM_SHARE_EXCLUSIVE + STGM_CREATE, 0, 0, Stream));
    SaveToStream(Stream);
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl.SaveCompleted(const stgNew: IStorage): HResult;
begin
  FIsDirty := False;
  Result := S_OK;
end;

function TActiveXControl.HandsOffStorage: HResult;
begin
  Result := S_OK;
end;

{ TActiveXControl.IOleObject }

function TActiveXControl.SetClientSite(const ClientSite: IOleClientSite): HResult;
begin
  if ClientSite <> nil then
  begin
    if FOleClientSite <> nil then
    begin
      Result := E_FAIL;
      Exit;
    end;
    FOleClientSite := ClientSite;
    ClientSite.QueryInterface(IOleControlSite, FOleControlSite);
    if FControlFactory.MiscStatus and OLEMISC_SIMPLEFRAME <> 0 then
      ClientSite.QueryInterface(ISimpleFrameSite, FSimpleFrameSite);
    ClientSite.QueryInterface(IDispatch, FAmbientDispatch);
    OnAmbientPropertyChange(0);
  end else
  begin
    FAmbientDispatch := nil;
    FSimpleFrameSite := nil;
    FOleControlSite := nil;
    FOleClientSite := nil;
  end;
  Result := S_OK;
end;

function TActiveXControl.GetClientSite(out clientSite: IOleClientSite): HResult;
begin
  ClientSite := FOleClientSite;
  Result := S_OK;
end;

function TActiveXControl.SetHostNames(szContainerApp: POleStr;
  szContainerObj: POleStr): HResult;
begin
  Result := S_OK;
end;

function TActiveXControl.Close(dwSaveOption: Longint): HResult;
begin
  if (dwSaveOption <> OLECLOSE_NOSAVE) and FIsDirty and
    (FOleClientSite <> nil) then FOleClientSite.SaveObject;
  Result := InPlaceDeactivate;
end;

function TActiveXControl.SetMoniker(dwWhichMoniker: Longint; const mk: IMoniker): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl.GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
  out mk: IMoniker): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl.InitFromData(const dataObject: IDataObject; fCreation: BOOL;
  dwReserved: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl.GetClipboardData(dwReserved: Longint;
  out dataObject: IDataObject): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl.DoVerb(iVerb: Longint; msg: PMsg; const activeSite: IOleClientSite;
  lindex: Longint; hwndParent: HWND; const posRect: TRect): HResult;
begin
  try
    case iVerb of
      OLEIVERB_SHOW,
      OLEIVERB_UIACTIVATE:
        Result := InPlaceActivate(True);
      OLEIVERB_INPLACEACTIVATE:
        Result := InPlaceActivate(False);
      OLEIVERB_HIDE:
        begin
          FWinControl.Visible := False;
          Result := S_OK;
        end;
      OLEIVERB_PRIMARY,
      OLEIVERB_PROPERTIES:
        begin
          ShowPropertyDialog;
          Result := S_OK;
        end;
    else
      if FControlFactory.FVerbs.IndexOfObject(TObject(iVerb)) >= 0 then
      begin
        PerformVerb(iVerb);
        Result := S_OK;
      end else
        Result := OLEOBJ_S_INVALIDVERB;
    end;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl.EnumVerbs(out enumOleVerb: IEnumOleVerb): HResult;
begin
  Result := OleRegEnumVerbs(Factory.ClassID, enumOleVerb);
end;

function TActiveXControl.Update: HResult;
begin
  Result := S_OK;
end;

function TActiveXControl.IsUpToDate: HResult;
begin
  Result := S_OK;
end;

function TActiveXControl.GetUserClassID(out clsid: TCLSID): HResult;
begin
  clsid := Factory.ClassID;
  Result := S_OK;
end;

function TActiveXControl.GetUserType(dwFormOfType: Longint; out pszUserType: POleStr): HResult;
begin
  Result := OleRegGetUserType(Factory.ClassID, dwFormOfType, pszUserType);
end;

function TActiveXControl.SetExtent(dwDrawAspect: Longint; const size: TPoint): HResult;
var
  W, H: Integer;
begin
  try
    if dwDrawAspect <> DVASPECT_CONTENT then OleError(DV_E_DVASPECT);
    W := MulDiv(Size.X, Screen.PixelsPerInch, 2540);
    H := MulDiv(Size.Y, Screen.PixelsPerInch, 2540);
    with FWinControl do SetBounds(Left, Top, W, H);
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl.GetExtent(dwDrawAspect: Longint; out size: TPoint): HResult;
begin
  if dwDrawAspect <> DVASPECT_CONTENT then
  begin
    Result := DV_E_DVASPECT;
    Exit;
  end;
  Size.X := MulDiv(FWinControl.Width, 2540, Screen.PixelsPerInch);
  Size.Y := MulDiv(FWinControl.Height, 2540, Screen.PixelsPerInch);
  Result := S_OK;
end;

function TActiveXControl.Advise(const advSink: IAdviseSink; out dwConnection: Longint): HResult;
begin
  Result := CreateAdviseHolder;
  if Result = S_OK then
    Result := FOleAdviseHolder.Advise(advSink, dwConnection);
end;

function TActiveXControl.Unadvise(dwConnection: Longint): HResult;
begin
  Result := CreateAdviseHolder;
  if Result = S_OK then
    Result := FOleAdviseHolder.Unadvise(dwConnection);
end;

function TActiveXControl.EnumAdvise(out enumAdvise: IEnumStatData): HResult;
begin
  Result := CreateAdviseHolder;
  if Result = S_OK then
    Result := FOleAdviseHolder.EnumAdvise(enumAdvise);
end;

function TActiveXControl.GetMiscStatus(dwAspect: Longint; out dwStatus: Longint): HResult;
begin
  if dwAspect <> DVASPECT_CONTENT then
  begin
    Result := DV_E_DVASPECT;
    Exit;
  end;
  dwStatus := FControlFactory.FMiscStatus;
  Result := S_OK;
end;

function TActiveXControl.SetColorScheme(const logpal: TLogPalette): HResult;
begin
  Result := E_NOTIMPL;
end;

{ TActiveXControl.IOleControl }

function TActiveXControl.GetControlInfo(var ci: TControlInfo): HResult;
begin
  with ci do
  begin
    cb := SizeOf(ci);
    hAccel := 0;
    cAccel := 0;
    dwFlags := 0;
  end;
  Result := S_OK;
end;

function TActiveXControl.OnMnemonic(msg: PMsg): HResult;
begin
  Result := InPlaceActivate(True);
end;

function TActiveXControl.OnAmbientPropertyChange(dispid: TDispID): HResult;
var
  Font: TFont;
begin
  if (FWinControl <> nil) and (FAmbientDispatch <> nil) then
  begin
    FWinControl.Perform(CM_PARENTCOLORCHANGED, 1, FAmbientDispatch.BackColor);
    FWinControl.Perform(CM_PARENTCTL3DCHANGED, 1, 1);
    Font := TFont.Create;
    try
      try
        Font.Color := FAmbientDispatch.ForeColor;
        SetOleFont(Font, FAmbientDispatch.Font);
        FWinControl.Perform(CM_PARENTFONTCHANGED, 1, Integer(Font));
      except
      end;
    finally
      Font.Free;
    end;
  end;
  Result := S_OK;
end;

function TActiveXControl.FreezeEvents(bFreeze: BOOL): HResult;
begin
  FEventsFrozen := bFreeze;
  Result := S_OK;
end;

{ TActiveXControl.IOleWindow }

function TActiveXControl.GetWindow(out wnd: HWnd): HResult;
begin
  if FWinControl.HandleAllocated then
  begin
    wnd := FWinControl.Handle;
    Result := S_OK;
  end else
    Result := E_FAIL;
end;

function TActiveXControl.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

{ TActiveXControl.IOleInPlaceObject }

function TActiveXControl.InPlaceDeactivate: HResult;
begin
  if FInPlaceActive then
  begin
    UIDeactivate;
    FInPlaceActive := False;
    FWinControl.Visible := False;
    FWinControl.ParentWindow := ParkingWindow;
    FOleInPlaceUIWindow := nil;
    FOleInPlaceFrame := nil;
    FOleInPlaceSite.OnInPlaceDeactivate;
    FOleInPlaceSite := nil;
  end;
  FWinControl.Visible := False;
  Result := S_OK;
end;

function TActiveXControl.UIDeactivate: HResult;
begin
  if FUIActive then
  begin
    if FOleInPlaceUIWindow <> nil then
      FOleInPlaceUIWindow.SetActiveObject(nil, nil);
    FOleInPlaceFrame.SetActiveObject(nil, nil);
    FOleInPlaceSite.OnUIDeactivate(False);
    FUIActive := False;
  end;
  Result := S_OK;
end;

function TActiveXControl.SetObjectRects(const rcPosRect: TRect;
  const rcClipRect: TRect): HResult;
begin
  try
    FWinControl.BoundsRect := rcPosRect;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl.ReactivateAndUndo: HResult;
begin
  Result := E_NOTIMPL;
end;

{ TActiveXControl.IOleInPlaceActiveObject }

function TActiveXControl.TranslateAccelerator(var msg: TMsg): HResult;
var
  Control: TWinControl;
  Form: TCustomForm;
  HWindow: THandle;
  Mask: Integer;
begin
  with Msg do
    if (Message >= WM_KEYFIRST) and (Message <= WM_KEYLAST) then
    begin
      Control := FindControl(HWnd);
      if Control = nil then
      begin
        HWindow := HWnd;
        repeat
          HWindow := GetParent(HWindow);
          if HWindow <> 0 then Control := FindControl(HWindow);
        until (HWindow = 0) or (Control <> nil);
      end;
      if Control <> nil then
      begin
        Result := S_OK;
        if Control.Perform(CM_CHILDKEY, wParam, Integer(Control)) <> 0 then Exit;
        Mask := 0;
        case wParam of
          VK_TAB:
            Mask := DLGC_WANTTAB;
          VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_HOME, VK_END:
            Mask := DLGC_WANTARROWS;
          VK_RETURN, VK_EXECUTE, VK_ESCAPE, VK_CANCEL:
            Mask := DLGC_WANTALLKEYS;
        end;
        if (Mask <> 0) and
          ((Control.Perform(CM_WANTSPECIALKEY, wParam, 0) <> 0) or
          (Control.Perform(WM_GETDLGCODE, 0, 0) and Mask <> 0)) then
        begin
          TranslateMessage(msg);
          DispatchMessage(msg);
          Exit;
        end;
        if (Message = WM_KEYDOWN) and (Control.Parent <> nil) then
          Form := GetParentForm(Control)
        else
          Form := nil;
        if (Form <> nil) and (Form.Perform(CM_DIALOGKEY, wParam, lParam) = 1) then
          Exit; 
      end;
    end;
  if FOleControlSite <> nil then
    Result := FOleControlSite.TranslateAccelerator(@msg, GetKeyModifiers)
  else
    Result := S_FALSE;
end;

function TActiveXControl.OnFrameWindowActivate(fActivate: BOOL): HResult;
begin
  Result := InPlaceActivate(True);
end;

function TActiveXControl.OnDocWindowActivate(fActivate: BOOL): HResult;
begin
  Result := InPlaceActivate(True);
end;

function TActiveXControl.ResizeBorder(const rcBorder: TRect; const uiWindow: IOleInPlaceUIWindow;
  fFrameWindow: BOOL): HResult;
begin
  Result := S_OK;
end;

function TActiveXControl.EnableModeless(fEnable: BOOL): HResult;
begin
  Result := S_OK;
end;

{ TActiveXControl.IViewObject }

function TActiveXControl.Draw(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
  ptd: PDVTargetDevice; hicTargetDev: HDC; hdcDraw: HDC;
  prcBounds: PRect; prcWBounds: PRect; fnContinue: TContinueFunc;
  dwContinue: Longint): HResult;
var
  R: TRect;
  SaveIndex: Integer;
  WasVisible: Boolean;
begin
  try
    if dwDrawAspect <> DVASPECT_CONTENT then OleError(DV_E_DVASPECT);
    WasVisible := FControl.Visible;
    try
      FControl.Visible := True;
      ShowWindow(FWinControl.Handle, 1);
      R := prcBounds^;
      LPToDP(hdcDraw, R, 2);
      SaveIndex := SaveDC(hdcDraw);
      try
        SetViewportOrgEx(hdcDraw, 0, 0, nil);
        SetWindowOrgEx(hdcDraw, 0, 0, nil);
        SetMapMode(hdcDraw, MM_TEXT);
        FControl.PaintTo(hdcDraw, R.Left, R.Top);
      finally
        RestoreDC(hdcDraw, SaveIndex);
      end;
    finally
      FControl.Visible := WasVisible;
    end;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl.GetColorSet(dwDrawAspect: Longint; lindex: Longint;
  pvAspect: Pointer; ptd: PDVTargetDevice; hicTargetDev: HDC;
  out colorSet: PLogPalette): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl.Freeze(dwDrawAspect: Longint; lindex: Longint; pvAspect: Pointer;
  out dwFreeze: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl.Unfreeze(dwFreeze: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl.SetAdvise(aspects: Longint; advf: Longint;
  const advSink: IAdviseSink): HResult;
begin
  if aspects and DVASPECT_CONTENT = 0 then
  begin
    Result := DV_E_DVASPECT;
    Exit;
  end;
  FAdviseFlags := advf;
  FAdviseSink := advSink;
  if FAdviseFlags and ADVF_PRIMEFIRST <> 0 then ViewChanged;
  Result := S_OK;
end;

function TActiveXControl.GetAdvise(pAspects: PLongint; pAdvf: PLongint;
  out advSink: IAdviseSink): HResult;
begin
  if pAspects <> nil then pAspects^ := DVASPECT_CONTENT;
  if pAdvf <> nil then pAdvf^ := FAdviseFlags;
  if @advSink <> nil then advSink := FAdviseSink;
  Result := S_OK;
end;

{ TActiveXControl.IViewObject2 }

function TActiveXControl.ViewObjectGetExtent(dwDrawAspect: Longint; lindex: Longint;
  ptd: PDVTargetDevice; out size: TPoint): HResult;
begin
  Result := GetExtent(dwDrawAspect, size);
end;

{ TActiveXControl.IPerPropertyBrowsing }

function TActiveXControl.GetDisplayString(dispid: TDispID;
  out bstr: WideString): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXControl.MapPropertyToPage(dispid: TDispID;
  out clsid: TCLSID): HResult;
begin
  if @clsid <> nil then clsid := GUID_NULL;
  Result := E_NOTIMPL; {!!!}
end;

function TActiveXControl.GetPredefinedStrings(dispid: TDispID;
  out caStringsOut: TCAPOleStr; out caCookiesOut: TCALongint): HResult;
var
  StringList: POleStrList;
  CookieList: PLongintList;
  Strings: TStringList;
  Count, I: Integer;
begin
  StringList := nil;
  CookieList := nil;
  Count := 0;
  if (@CaStringsOut = nil) or (@CaCookiesOut = nil) then
  begin
    Result := E_POINTER;
    Exit;
  end;
  caStringsOut.cElems := 0;
  caStringsOut.pElems := nil;
  caCookiesOut.cElems := 0;
  caCookiesOut.pElems := nil;
  
  try
    Strings := TStringList.Create;
    try
      if GetPropertyStrings(dispid, Strings) then
      begin
        Count := Strings.Count;
        StringList := CoAllocMem(Count * SizeOf(Pointer));
        CookieList := CoAllocMem(Count * SizeOf(Longint));
        for I := 0 to Count - 1 do
        begin
          StringList[I] := CoAllocString(Strings[I]);
          CookieList[I] := Longint(Strings.Objects[I]);
        end;
        caStringsOut.cElems := Count;
        caStringsOut.pElems := StringList;
        caCookiesOut.cElems := Count;
        caCookiesOut.pElems := CookieList;
        Result := S_OK;
      end else
        Result := E_NOTIMPL;
    finally
      Strings.Free;
    end;
  except
    if StringList <> nil then
      for I := 0 to Count - 1 do CoFreeMem(StringList[I]);
    CoFreeMem(CookieList);
    CoFreeMem(StringList);
    Result := HandleException;
  end;
end;

function TActiveXControl.GetPredefinedValue(dispid: TDispID;
  dwCookie: Longint; out varOut: OleVariant): HResult;
var
  Temp: OleVariant;
begin
  GetPropertyValue(dispid, dwCookie, Temp);
  varOut := Temp;
  Result := S_OK;
end;

{ TActiveXControl.ISpecifyPropertyPages }

type
  TPropPages = class
  private
    FGUIDList: PGUIDList;
    FCount: Integer;
    procedure ProcessPage(const GUID: TGUID);
  end;

procedure TPropPages.ProcessPage(const GUID: TGUID);
begin
  if FGUIDList <> nil then FGUIDList[FCount] := GUID;
  Inc(FCount);
end;

function TActiveXControl.GetPages(out pages: TCAGUID): HResult;
var
  PropPages: TPropPages;
begin
  try
    PropPages := TPropPages.Create;
    try
      DefinePropertyPages(PropPages.ProcessPage);
      PropPages.FGUIDList := CoAllocMem(PropPages.FCount * SizeOf(TGUID));
      PropPages.FCount := 0;
      DefinePropertyPages(PropPages.ProcessPage);
      pages.cElems := PropPages.FCount;
      pages.pElems := PropPages.FGUIDList;
      PropPages.FGUIDList := nil;
    finally
      if PropPages.FGUIDList <> nil then CoFreeMem(PropPages.FGUIDList);
      PropPages.Free;
    end;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXControl.PreMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
 out res: Integer; out Cookie: Longint): HResult;
begin
  if FSimpleFrameSite <> nil then
    Result := FSimpleFrameSite.PreMessageFilter(wnd, msg, wp, lp, res, Cookie)
  else
    Result := S_OK;
end;

function TActiveXControl.PostMessageFilter(wnd: HWnd; msg, wp, lp: Integer;
  out res: Integer; Cookie: Longint): HResult;
begin
  if FSimpleFrameSite <> nil then
    Result := FSimpleFrameSite.PostMessageFilter(wnd, msg, wp, lp, res, Cookie)
  else
    Result := S_OK;
end;


{ TActiveXControlFactory }

constructor TActiveXControlFactory.Create(ComServer: TComServerObject;
  ActiveXControlClass: TActiveXControlClass;
  WinControlClass: TWinControlClass; const ClassID: TGUID;
  ToolboxBitmapID: Integer; const LicStr: string; MiscStatus: Integer);
var
  TypeAttr: PTypeAttr;
begin
  FWinControlClass := WinControlClass;
  inherited Create(ComServer, ActiveXControlClass, ClassID, ciMultiInstance);
  FMiscStatus := MiscStatus or
    OLEMISC_RECOMPOSEONRESIZE or
    OLEMISC_CANTLINKINSIDE or
    OLEMISC_INSIDEOUT or
    OLEMISC_ACTIVATEWHENVISIBLE or
    OLEMISC_SETCLIENTSITEFIRST;
  FToolboxBitmapID := ToolboxBitmapID;
  FEventTypeInfo := GetInterfaceTypeInfo(IMPLTYPEFLAG_FDEFAULT or
    IMPLTYPEFLAG_FSOURCE);
  if FEventTypeInfo <> nil then
  begin
    OleCheck(FEventTypeInfo.GetTypeAttr(TypeAttr));
    FEventIID := TypeAttr.guid;
    FEventTypeInfo.ReleaseTypeAttr(TypeAttr);
  end;
  FVerbs := TStringList.Create;
  AddVerb(OLEIVERB_PRIMARY, 'Properties');
  LicString := LicStr;
  SupportsLicensing := LicStr <> '';
  FLicFileStrings := TStringList.Create;
end;

destructor TActiveXControlFactory.Destroy;
begin
  FVerbs.Free;
  FLicFileStrings.Free;
  inherited Destroy;
end;

procedure TActiveXControlFactory.AddVerb(Verb: Integer;
  const VerbName: string);
begin
  FVerbs.AddObject(VerbName, TObject(Verb));
end;

function TActiveXControlFactory.GetLicenseFileName: string;
begin
  Result := ChangeFileExt(ComServer.ServerFileName, '.lic');
end;

function TActiveXControlFactory.HasMachineLicense: Boolean;
var
  i: Integer;
begin
  Result := True;
  if not SupportsLicensing then Exit;
  if not FLicenseFileRead then
  begin
    try
      FLicFileStrings.LoadFromFile(GetLicenseFileName);
      FLicenseFileRead := True;
    except
      Result := False;
    end;
  end;
  if Result then
  begin
    i := 0;
    Result := False;
    while (i < FLicFileStrings.Count) and (not Result) do
    begin
      Result := ValidateUserLicense(FLicFileStrings[i]);
      inc(i);
    end;
  end;
end;

procedure TActiveXControlFactory.UpdateRegistry(Register: Boolean);
var
  ClassKey: string;
  I: Integer;
begin
  ClassKey := 'CLSID\' + GUIDToString(ClassID);
  if Register then
  begin
    inherited UpdateRegistry(Register);
    CreateRegKey(ClassKey + '\MiscStatus', '', '0');
    CreateRegKey(ClassKey + '\MiscStatus\1', '', IntToStr(FMiscStatus));
    CreateRegKey(ClassKey + '\ToolboxBitmap32', '',
      ComServer.ServerFileName + ',' + IntToStr(FToolboxBitmapID));
    CreateRegKey(ClassKey + '\Control', '', '');
    CreateRegKey(ClassKey + '\Verb', '', '');
    for I := 0 to FVerbs.Count - 1 do
      CreateRegKey(ClassKey + '\Verb\' + IntToStr(Integer(FVerbs.Objects[I])),
        '', FVerbs[I] + ',0,2');
  end else
  begin
    for I := 0 to FVerbs.Count - 1 do
      DeleteRegKey(ClassKey + '\Verb\' + IntToStr(Integer(FVerbs.Objects[I])));
    DeleteRegKey(ClassKey + '\Verb');
    DeleteRegKey(ClassKey + '\Control');
    DeleteRegKey(ClassKey + '\ToolboxBitmap32');
    DeleteRegKey(ClassKey + '\MiscStatus\1');
    DeleteRegKey(ClassKey + '\MiscStatus');
    inherited UpdateRegistry(Register);
  end;
end;

{ TActiveFormControl }

procedure TActiveFormControl.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  if FControl is TActiveForm then
    TActiveForm(FControl).DefinePropertyPages(DefinePropertyPage);
end;

procedure TActiveFormControl.FreeOnRelease;
begin
end;

procedure TActiveFormControl.InitializeControl;
begin
  inherited InitializeControl;
  Control.VCLComObject := Pointer(Self as IVCLComObject);
  (Control as TActiveForm).Initialize;
end;

function TActiveFormControl.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
const
  INVOKE_PROPERTYSET = INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF;
begin
  if Flags and INVOKE_PROPERTYSET <> 0 then Flags := INVOKE_PROPERTYSET;
  Result := TAutoObjectFactory(Factory).DispTypeInfo.Invoke(Pointer(
    Integer(Control) + TAutoObjectFactory(Factory).DispIntfEntry.IOffset),
    DispID, Flags, TDispParams(Params), VarResult, ExcepInfo, ArgErr);
end;

function TActiveFormControl.ObjQueryInterface(const IID: TGUID; out Obj): Integer;
begin
  Result := S_OK;
  if not Control.GetInterface(IID, Obj) then
    Result := inherited ObjQueryInterface(IID, Obj);
end;

procedure TActiveFormControl.EventSinkChanged(const EventSink: IUnknown);
begin
  if (Control is TActiveForm) then
    TActiveForm(Control).EventSinkChanged(EventSink);
end;

{ TActiveForm }

constructor TActiveForm.Create(AOwner: TComponent);
begin
  FAxBorderStyle := afbSingle;
  inherited Create(AOwner);
  BorderStyle := bsNone;
  BorderIcons := [];
  TabStop := True;
end;

procedure TActiveForm.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
end;

procedure TActiveForm.SetAxBorderStyle(Value: TActiveFormBorderStyle);
begin
  if FAxBorderStyle <> Value then
  begin
    FAxBorderStyle := Value;
    if not (csDesigning in ComponentState) then RecreateWnd;
  end;
end;

procedure TActiveForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if not (csDesigning in ComponentState) then
    with Params do
    begin
      Style := Style and not WS_CAPTION;
      case FAxBorderStyle of
        afbNone: ;// do nothing
        afbSingle: Style := Style or WS_BORDER;
        afbSunken: ExStyle := ExStyle or WS_EX_CLIENTEDGE;
        afbRaised:
          begin
            Style := Style or WS_DLGFRAME;
            ExStyle := ExStyle or WS_EX_WINDOWEDGE;
          end;
      end;
    end;
end;

procedure TActiveForm.EventSinkChanged(const EventSink: IUnknown);
begin
end;

procedure TActiveForm.Initialize;
begin
end;

function TActiveForm.WantChildKey(Child: TControl; var Message: TMessage): Boolean;
begin
  Result := ((Message.Msg = WM_CHAR) and (Message.WParam = VK_TAB)) or
    (Child.Perform(CN_BASE + Message.Msg, Message.WParam,
      Message.LParam) <> 0);
end;

{ TActiveFormFactory }

function TActiveFormFactory.GetIntfEntry(Guid: TGUID): PInterfaceEntry;
begin
  Result := WinControlClass.GetInterfaceEntry(Guid);
end;

{ TPropertyPage }

procedure TPropertyPage.CMChanged(var Msg: TCMChanged);
begin
  Modified;
end;

procedure TPropertyPage.Modified;
begin
  if Assigned(FActiveXPropertyPage) then FActiveXPropertyPage.Modified;
end;

procedure TPropertyPage.UpdateObject;
begin
end;

procedure TPropertyPage.EnumCtlProps(PropType: TGUID; PropNames: TStrings);
const
  INVOKE_PROPERTYSET = INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF;
var
  I: Integer;
  TypeInfo: ITypeInfo;
  Dispatch: IDispatch;
  TypeAttr: PTypeAttr;
  FuncDesc: PFuncDesc;
  VarDesc: PVarDesc;

  procedure SaveName(Id: Integer);
  var
    Name: WideString;
  begin
    OleCheck(TypeInfo.GetDocumentation(Id, @Name, nil, nil, nil));
    if PropNames.IndexOfObject(TObject(Id)) = -1 then
      PropNames.AddObject(Name, TObject(Id));
  end;

  function IsPropType(const TypeInfo: ITypeInfo; TypeDesc: PTypeDesc): Boolean;
  var
    RefInfo: ITypeInfo;
    RefAttr: PTypeAttr;
  begin
    Result := False;
    case TypeDesc.vt of
    VT_PTR: Result := IsPropType(TypeInfo, TypeDesc.ptdesc);
    VT_USERDEFINED:
      begin
        OleCheck(TypeInfo.GetRefTypeInfo(TypeDesc.hreftype, RefInfo));
        OleCheck(RefInfo.GetTypeAttr(RefAttr));
        try
          Result := IsEqualGUID(RefAttr.guid, PropType);
          if (not Boolean(Result)) and (RefAttr.typekind = TKIND_ALIAS) then
            Result := IsPropType(RefInfo, @RefAttr.tdescAlias);
        finally
          RefInfo.ReleaseTypeAttr(RefAttr);
        end;
      end;
    end;
  end;

  function HasMember(const TypeInfo: ITypeInfo; Cnt, MemID, InvKind: Integer): Boolean;
  var
    I: Integer;
    FuncDesc: PFuncDesc;
  begin
    for I := 0 to Cnt - 1 do
    begin
      OleCheck(TypeInfo.GetFuncDesc(I, FuncDesc));
      try
        if (FuncDesc.memid = MemID) and (FuncDesc.invkind and InvKind <> 0) then
        begin
          Result := True;
          Exit;
        end;
      finally
        TypeInfo.ReleaseFuncDesc(FuncDesc);
      end;
    end;
    Result := False;
  end;

begin
  Dispatch := IUnknown(FOleObject) as IDispatch;
  OleCheck(Dispatch.GetTypeInfo(0,0,TypeInfo));
  if TypeInfo = nil then Exit;
  OleCheck(TypeInfo.GetTypeAttr(TypeAttr));
  try
    for I := 0 to TypeAttr.cVars - 1 do
    begin
      OleCheck(TypeInfo.GetVarDesc(I, VarDesc));
      try
        if (VarDesc.wVarFlags and VARFLAG_FREADONLY <> 0) and
          IsPropType(TypeInfo, @VarDesc.elemdescVar.tdesc) then
          SaveName(VarDesc.memid);
      finally
        TypeInfo.ReleaseVarDesc(VarDesc);
      end;
    end;
    for I := 0 to TypeAttr.cFuncs - 1 do
    begin
      OleCheck(TypeInfo.GetFuncDesc(I, FuncDesc));
      try
        if ((FuncDesc.invkind = INVOKE_PROPERTYGET) and
          HasMember(TypeInfo, TypeAttr.cFuncs, FuncDesc.memid, INVOKE_PROPERTYSET) and
          IsPropType(TypeInfo, @FuncDesc.elemdescFunc.tdesc)) or
          ((FuncDesc.invkind and INVOKE_PROPERTYSET <> 0) and
          HasMember(TypeInfo, TypeAttr.cFuncs, FuncDesc.memid, INVOKE_PROPERTYGET) and
          IsPropType(TypeInfo,
            @FuncDesc.lprgelemdescParam[FuncDesc.cParams - 1].tdesc)) then
            SaveName(FuncDesc.memid);
      finally
        TypeInfo.ReleaseFuncDesc(FuncDesc);
      end;
    end;
  finally
    TypeInfo.ReleaseTypeAttr(TypeAttr);
  end;
end;

procedure TPropertyPage.UpdatePropertyPage;
begin
end;

{ TActiveXPropertyPage }

procedure TActiveXPropertyPage.Initialize;
begin
  FPropertyPage := TPropertyPageClass(Factory.ComClass).Create(nil);
  FPropertyPage.FActiveXPropertyPage := Self;
  FPropertyPage.BorderStyle := bsNone;
  FPropertyPage.Position := poDesigned;
end;

destructor TActiveXPropertyPage.Destroy;
begin
  FPropertyPage.Free;
end;

procedure TActiveXPropertyPage.Modified;
begin
  if FActive then
  begin
    FModified := True;
    if FPageSite <> nil then
      FPageSite.OnStatusChange(PROPPAGESTATUS_DIRTY or PROPPAGESTATUS_VALIDATE);
  end;
end;

{ TActiveXPropertyPage.IPropertyPage }

function TActiveXPropertyPage.SetPageSite(
  const pageSite: IPropertyPageSite): HResult;
begin
  FPageSite := pageSite;
  Result := S_OK;
end;

function TActiveXPropertyPage.Activate(hwndParent: HWnd;
  const rc: TRect; bModal: BOOL): HResult;
begin
  try
    FPropertyPage.BoundsRect := rc;
    FPropertyPage.ParentWindow := hwndParent;
    if not VarIsNull(FPropertyPage.FOleObject) then
      FPropertyPage.UpdatePropertyPage;
    FActive:= True;
    FModified := False;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXPropertyPage.Deactivate: HResult;
begin
  try
    FActive := False;
    FPropertyPage.Hide;
    FPropertyPage.ParentWindow := 0;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXPropertyPage.GetPageInfo(
  out pageInfo: TPropPageInfo): HResult;
begin
  try
    FillChar(pageInfo.pszTitle, SizeOf(pageInfo) - 4, 0);
    pageInfo.pszTitle := CoAllocString(FPropertyPage.Caption);
    pageInfo.size.cx := FPropertyPage.Width;
    pageInfo.size.cy := FPropertyPage.Height;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXPropertyPage.SetObjects(cObjects: Longint;
  pUnkList: PUnknownList): HResult;
begin
  try
    FPropertyPage.FOleObject := Null;
    if cObjects > 0 then
      FPropertyPage.FOleObject := pUnkList[0] as IDispatch;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXPropertyPage.Show(nCmdShow: Integer): HResult;
begin
  try
    FPropertyPage.Visible := nCmdShow <> SW_HIDE;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXPropertyPage.Move(const rect: TRect): HResult;
begin
  try
    FPropertyPage.BoundsRect := rect;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXPropertyPage.IsPageDirty: HResult;
begin
  if FModified then Result := S_OK else Result := S_FALSE;
end;

function TActiveXPropertyPage.Apply: HResult;

  procedure NotifyContainerOfApply;
  var
    OleObject: IUnknown;
    Connections: IConnectionPointContainer;
    Connection: IConnectionPoint;
    Enum: IEnumConnections;
    ConnectData: TConnectData;
    Fetched: Longint;
  begin
    { VB seems to wait for an OnChange call along a IPropetyNotifySink before
      it will update its property inspector. }
    OleObject := IUnknown(FPropertyPage.FOleObject);
    if OleObject.QueryInterface(IConnectionPointContainer, Connections) = S_OK then
      if Connections.FindConnectionPoint(IPropertyNotifySink, Connection) = S_OK then
      begin
        OleCheck(Connection.EnumConnections(Enum));
        while Enum.Next(1, ConnectData, @Fetched) = S_OK do
        begin
          (ConnectData.pUnk as IPropertyNotifySink).OnChanged(DISPID_UNKNOWN);
          ConnectData.pUnk := nil;
        end;
      end;
  end;

begin
  try
    FPropertyPage.UpdateObject;
    FModified := False;
    NotifyContainerOfApply;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TActiveXPropertyPage.Help(pszHelpDir: POleStr): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXPropertyPage.TranslateAccelerator(msg: PMsg): HResult;
begin
  try
    { For some reason VB bashes WS_EX_CONTROLPARENT, set it back }
    if FPropertyPage.WindowHandle <> 0 then
      SetWindowLong(FPropertyPage.Handle, GWL_EXSTYLE,
        GetWindowLong(FPropertyPage.Handle, GWL_EXSTYLE) or
        WS_EX_CONTROLPARENT);
    {!!!}
    Result := S_FALSE;
  except
    Result := HandleException;
  end;
end;

{ TActiveXPropertyPage.IPropertyPage2 }

function TActiveXPropertyPage.EditProperty(dispid: TDispID): HResult;
begin
  Result := E_NOTIMPL; {!!!}
end;

{ TActiveXPropertyPageFactory }

constructor TActiveXPropertyPageFactory.Create(ComServer: TComServerObject;
  PropertyPageClass: TPropertyPageClass; const ClassID: TGUID);
begin
  inherited Create(ComServer, TComClass(PropertyPageClass), ClassID,
    '', Format('%s property page', [PropertyPageClass.ClassName]),
    ciMultiInstance);
end;

function TActiveXPropertyPageFactory.CreateComObject(
  const Controller: IUnknown): TComObject;
begin
  Result := TActiveXPropertyPage.CreateFromFactory(Self, Controller);
end;

{ TCustomAdapter }

constructor TCustomAdapter.Create;
begin
  FNotifier := TAdapterNotifier.Create(Self);
end;

destructor TCustomAdapter.Destroy;
begin
  ReleaseOleObject;
end;

procedure TCustomAdapter.Changed;
begin
  if not Updating then ReleaseOleObject;
end;

procedure TCustomAdapter.ConnectOleObject(OleObject: IUnknown);
begin
  if FOleObject <> nil then ReleaseOleObject;
  if OleObject <> nil then
    InterfaceConnect(OleObject, IPropertyNotifySink, FNotifier, FConnection);
  FOleObject := OleObject;
end;

procedure TCustomAdapter.ReleaseOleObject;
begin
  InterfaceDisconnect(FOleObject, IPropertyNotifySink, FConnection);
  FOleObject := nil;
end;

{ TAdapterNotifier }

constructor TAdapterNotifier.Create(Adapter: TCustomAdapter);
begin
  FAdapter := Adapter;
end;

{ TAdapterNotifier.IPropertyNotifySink }

function TAdapterNotifier.OnChanged(dispid: TDispID): HResult;
begin
  try
    FAdapter.Update;
    Result := S_OK;
  except
    Result := HandleException;
  end;
end;

function TAdapterNotifier.OnRequestEdit(dispid: TDispID): HResult;
begin
  Result := S_OK;
end;

{ TFontAdapter }

constructor TFontAdapter.Create(Font: TFont);
begin
  inherited Create;
  FFont := Font;
end;

procedure TFontAdapter.Update;
var
  TempFont: TFont;
  Name: WideString;
  Size: Currency;
  Temp: Longbool;
  Charset: Smallint;
  Style: TFontStyles;
  FOleFont: IFont;
begin
  if Updating then Exit;
  FOleFont := FOleObject as IFont;
  FOleFont.get_Name(Name);
  FOleFont.get_Size(Size);

  Style := [];
  FOleFont.get_Bold(Temp);
  if Temp then Include(Style, fsBold);
  FOleFont.get_Italic(Temp);
  if Temp then Include(Style, fsItalic);
  FOleFont.get_Underline(Temp);
  if Temp then Include(Style, fsUnderline);
  FOleFont.get_Strikethrough(Temp);
  if Temp then Include(Style, fsStrikeout);
  FOleFont.get_Charset(Charset);

  TempFont := TFont.Create;
  Updating := True;
  try
    TempFont.Assign(FFont);
    TempFont.Name := Name;
    TempFont.Size := Round(Size);
    TempFont.Style := Style;
    TempFont.Charset := Charset;
    FFont.Assign(TempFont);
  finally
    Updating := False;
    TempFont.Free;
  end;
end;

procedure TFontAdapter.Changed;
begin  // TFont has changed.  Need to update IFont
  if Updating then Exit;
  Updating := True;
  try
    with FOleObject as IFont do
    begin
      Put_Name(FFont.Name);
      Put_Size(FFont.Size);
      Put_Bold(fsBold in FFont.Style);
      Put_Italic(fsItalic in FFont.Style);
      Put_Underline(fsUnderline in FFont.Style);
      Put_Strikethrough(fsStrikeout in FFont.Style);
      Put_Charset(FFont.Charset);
    end;
  finally
    Updating := False;
  end;
end;

{ TFontAdapter.IFontAccess }

procedure TFontAdapter.GetOleFont(var OleFont: IFontDisp);
var
  FontDesc: TFontDesc;
  FontName: WideString;
  Temp: IFont;
begin
  if FOleObject = nil then
  begin
    FontName := FFont.Name;
    with FontDesc do
    begin
      cbSizeOfStruct := SizeOf(FontDesc);
      lpstrName := PWideChar(FontName);
      cySize := FFont.Size;
      if fsBold in FFont.Style then sWeight := 700 else sWeight := 400;
      sCharset := FFont.Charset;
      fItalic := fsItalic in FFont.Style;
      fUnderline := fsUnderline in FFont.Style;
      fStrikethrough := fsStrikeout in FFont.Style;
    end;
    OleCheck(OleCreateFontIndirect(FontDesc, IFont, Temp));
    ConnectOleObject(Temp);
  end;
  OleFont := FOleObject as IFontDisp;
end;

procedure TFontAdapter.SetOleFont(const OleFont: IFontDisp);
begin
  ConnectOleObject(OleFont as IFont);
  Update;
end;

{ TPictureAdapter }

constructor TPictureAdapter.Create(Picture: TPicture);
begin
  inherited Create;
  FPicture := Picture;
end;

procedure TPictureAdapter.Update;
var
  Temp: TOleGraphic;
begin
  Updating := True;
  Temp := TOleGraphic.Create;
  try
    Temp.Picture := FOleObject as IPicture;
    FPicture.Graphic := Temp;
  finally
    Updating := False;
    Temp.Free;
  end;
end;

{ TPictureAdapter.IPictureAccess }

procedure TPictureAdapter.GetOlePicture(var OlePicture: IPictureDisp);
var
  PictureDesc: TPictDesc;
  OwnHandle: Boolean;
  TempM: TMetafile;
  TempB: TBitmap;
begin
  if FOleObject = nil then
  begin
    OwnHandle := False;
    with PictureDesc do
    begin
      cbSizeOfStruct := SizeOf(PictureDesc);
      if FPicture.Graphic is TBitmap then
      begin
        picType := PICTYPE_BITMAP;
        TempB := TBitmap.Create;
        try
          TempB.Assign(FPicture.Graphic);
          hbitmap := TempB.ReleaseHandle;
          hpal := TempB.ReleasePalette;
          OwnHandle := True;
        finally
          TempB.Free;
        end;
      end
      else if FPicture.Graphic is TIcon then
      begin
        picType := PICTYPE_ICON;
        hicon := FPicture.Icon.Handle;
      end
      else
      begin
        picType := PICTYPE_ENHMETAFILE;
        if not (FPicture.Graphic is TMetafile) then
        begin
          TempM := TMetafile.Create;
          try
            TempM.Width := FPicture.Width;
            TempM.Height := FPicture.Height;
            with TMetafileCanvas.Create(TempM,0) do
            try
              Draw(0,0,FPicture.Graphic);
            finally
              Free;
            end;
            hemf := TempM.ReleaseHandle;
            OwnHandle := True;   // IPicture destroys temp metafile when released
          finally
            TempM.Free;
          end;
        end
        else
          hemf := FPicture.Metafile.Handle;
      end;
    end;
    OleCheck(OleCreatePictureIndirect(PictureDesc, IPicture, OwnHandle, OlePicture));
    ConnectOleObject(OlePicture);
  end;
  OlePicture := FOleObject as IPictureDisp;
end;

procedure TPictureAdapter.SetOlePicture(const OlePicture: IPictureDisp);
begin
  ConnectOleObject(OlePicture);
  Update;
end;

{ TOleGraphic }

procedure TOleGraphic.Assign(Source: TPersistent);
begin
  if Source is TOleGraphic then
    FPicture := TOleGraphic(Source).Picture
  else
    inherited Assign(Source);
end;

procedure TOleGraphic.Changed(Sender: TObject);
begin
  //!!
end;

procedure TOleGraphic.Draw(ACanvas: TCanvas; const Rect: TRect);
var
  DC: HDC;
  Pal: HPalette;
  RestorePalette: Boolean;
  PicType: SmallInt;
  hemf: HENHMETAFILE;
begin
  if FPicture = nil then Exit;
  ACanvas.Lock;  // OLE calls might cycle the message loop
  try
    DC := ACanvas.Handle;
    Pal := Palette;
    RestorePalette := False;
    if Pal <> 0 then
    begin
      Pal := SelectPalette(DC, Pal, True);
      RealizePalette(DC);
      RestorePalette := True;
    end;
    FPicture.get_Type(PicType);
    if PicType = PICTYPE_ENHMETAFILE then
    begin
      FPicture.get_Handle(hemf);
      PlayEnhMetafile(DC, hemf, Rect);
    end
    else
      OleCheck(FPicture.Render(DC, Rect.Left, Rect.Top, Rect.Right,
        Rect.Bottom, 0, MMHeight, MMWidth, -MMHeight, Rect));
    if RestorePalette then
      SelectPalette(DC, Pal, True);
  finally
    ACanvas.Unlock;
  end;
end;

function TOleGraphic.GetEmpty: Boolean;
var
  PicType: Smallint;
begin
  Result := (FPicture = nil) or (FPicture.get_Type(PicType) <> 0) or (PicType <= 0);
end;

function HIMETRICtoDP(P: TPoint): TPoint;
var
  DC: HDC;
begin
  DC := GetDC(0);
  SetMapMode(DC, MM_HIMETRIC);
  Result := P;
  Result.Y := -Result.Y;
  LPTODP(DC, Result, 1);
  ReleaseDC(0,DC);
end;

function TOleGraphic.GetHeight: Integer;
begin
  Result := HIMETRICtoDP(Point(0, MMHeight)).Y;
end;

function TOleGraphic.GetMMHeight: Integer;
begin
  Result := 0;
  if FPicture <> nil then FPicture.get_Height(Result);
end;

function TOleGraphic.GetMMWidth: Integer;
begin
  Result := 0;
  if FPicture <> nil then FPicture.get_Width(Result);
end;

function TOleGraphic.GetPalette: HPALETTE;
var
  Handle: OLE_HANDLE;
begin
  Result := 0;
  if FPicture <> nil then
  begin
    FPicture.Get_HPal(Handle);
    Result := HPALETTE(Handle);
  end;
end;

function TOleGraphic.GetTransparent: Boolean;
var
  Attr: Integer;
begin
  Result := False;
  if FPicture <> nil then
  begin
    FPicture.Get_Attributes(Attr);
    Result := (Attr and PICTURE_TRANSPARENT) <> 0;
  end;
end;

function TOleGraphic.GetWidth: Integer;
begin
  Result := HIMETRICtoDP(Point(MMWidth,0)).X;
end;

procedure InvalidOperation(const Str: string);
begin
  raise EInvalidGraphicOperation.Create(Str);
end;

procedure TOleGraphic.SetHeight(Value: Integer);
begin
  InvalidOperation(sOleGraphic);
end;

procedure TOleGraphic.SetPalette(Value: HPALETTE);
begin
  if FPicture <> nil then OleCheck(FPicture.Set_hpal(Value));
end;

procedure TOleGraphic.SetWidth(Value: Integer);
begin
  InvalidOperation(sOleGraphic);
end;

procedure TOleGraphic.LoadFromFile(const Filename: string);
begin
  //!!
end;

procedure TOleGraphic.LoadFromStream(Stream: TStream);
begin
  OleCheck(OleLoadPicture(TStreamAdapter.Create(Stream), 0, True, IPicture,
    FPicture));
end;

procedure TOleGraphic.SaveToStream(Stream: TStream);
begin
  OleCheck((FPicture as IPersistStream).Save(TStreamAdapter.Create(Stream), True));
end;

procedure TOleGraphic.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
  APalette: HPALETTE);
begin
  InvalidOperation(sOleGraphic);
end;

procedure TOleGraphic.SaveToClipboardFormat(var AFormat: Word;
  var AData: THandle; var APalette: HPALETTE);
begin
  InvalidOperation(sOleGraphic);
end;


type
  TStringsEnumerator = class(TContainedObject, IEnumString)
  private
    FIndex: Integer;  // index of next unread string
    FStrings: IStrings;
  public
    constructor Create(const Strings: IStrings);
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumString): HResult; stdcall;
  end;

constructor TStringsEnumerator.Create(const Strings: IStrings);
begin
  inherited Create(Strings);
  FStrings := Strings;
end;

function TStringsEnumerator.Next(celt: Longint; out elt; pceltFetched: PLongint): HResult;
var
  I: Integer;
begin
  I := 0;
  while (I < celt) and (FIndex < FStrings.Count) do
  begin
    TPointerList(elt)[I] := PWideChar(WideString(FStrings.Item[I]));
    Inc(I);
    Inc(FIndex);
  end;
  if pceltFetched <> nil then pceltFetched^ := I;
  if I = celt then Result := S_OK else Result := S_FALSE;
end;

function TStringsEnumerator.Skip(celt: Longint): HResult;
begin
  if (FIndex + celt) <= FStrings.Count then
  begin
    Inc(FIndex, celt);
    Result := S_OK;
  end
  else
  begin
    FIndex := FStrings.Count;
    Result := S_FALSE;
  end;
end;

function TStringsEnumerator.Reset: HResult;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TStringsEnumerator.Clone(out enm: IEnumString): HResult;
begin
  enm := Self.Create(FStrings);
  Result := S_OK;
end;

{ TStringsAdapter }

constructor TStringsAdapter.Create(Strings: TStrings);
var
  StdVcl: ITypeLib;
begin
  OleCheck(LoadRegTypeLib(LIBID_STDVCL, 1, 0, 0, StdVcl));
  inherited Create(StdVcl, IStrings);
  FStrings := Strings;
end;

procedure TStringsAdapter.ReferenceStrings(S: TStrings);
begin
  FStrings := S;
end;

procedure TStringsAdapter.ReleaseStrings;
begin
  FStrings := nil;
end;

function TStringsAdapter.Get_ControlDefault(Index: Integer): OleVariant;
begin
  Result := Get_Item(Index);
end;

procedure TStringsAdapter.Set_ControlDefault(Index: Integer; Value: OleVariant);
begin
  Set_Item(Index, Value);
end;

function TStringsAdapter.Count: Integer;
begin
  Result := 0;
  if FStrings <> nil then Result := FStrings.Count;
end;

function TStringsAdapter.Get_Item(Index: Integer): OleVariant;
begin
  Result := NULL;
  if (FStrings <> nil) then Result := WideString(FStrings[Index]);
end;

procedure TStringsAdapter.Set_Item(Index: Integer; Value: OleVariant);
begin
  if (FStrings <> nil) then FStrings[Index] := Value;
end;

procedure TStringsAdapter.Remove(Index: Integer);
begin
  if FStrings <> nil then FStrings.Delete(Index);
end;

procedure TStringsAdapter.Clear;
begin
  if FStrings <> nil then FStrings.Clear;
end;

function TStringsAdapter.Add(Item: OleVariant): Integer;
begin
  Result := -1;
  if FStrings <> nil then Result := FStrings.Add(Item);
end;

function TStringsAdapter._NewEnum: IUnknown;
begin
  Result := TStringsEnumerator.Create(Self);
end;

procedure GetOleStrings(Strings: TStrings; var OleStrings: IStrings);
begin
  OleStrings := nil;
  if Strings = nil then Exit;
  if Strings.StringsAdapter = nil then
    Strings.StringsAdapter := TStringsAdapter.Create(Strings);
  OleStrings := Strings.StringsAdapter as IStrings;
end;

procedure SetOleStrings(Strings: TStrings; const OleStrings: IStrings);
var
  I: Integer;
begin
  if Strings = nil then Exit;
  Strings.Clear;
  for I := 0 to OleStrings.Count-1 do
    Strings.Add(OleStrings.Item[I]);
end;

{ Dynamically load functions used in OLEPRO32.DLL }

var
  OlePro32DLL: THandle;
  _OleCreatePropertyFrame: function(hwndOwner: HWnd; x, y: Integer;
    lpszCaption: POleStr; cObjects: Integer; pObjects: Pointer; cPages: Integer;
    pPageCLSIDs: Pointer; lcid: TLCID; dwReserved: Longint;
    pvReserved: Pointer): HResult stdcall;
  _OleCreateFontIndirect: function(const FontDesc: TFontDesc; const iid: TIID;
    out vObject): HResult stdcall;
  _OleCreatePictureIndirect: function(const PictDesc: TPictDesc; const iid: TIID;
    fOwn: BOOL; out vObject): HResult stdcall;
  _OleLoadPicture: function(stream: IStream; lSize: Longint; fRunmode: BOOL;
    const iid: TIID; out vObject): HResult; stdcall;

procedure InitOlePro32;
var
  OldError: Longint;
begin
  OldError := SetErrorMode(SEM_NOOPENFILEERRORBOX);
  try
    if OlePro32DLL = 0 then
    begin
      OlePro32DLL := LoadLibrary('olepro32.dll');
      if OlePro32DLL <> 0 then
      begin
        @_OleCreatePropertyFrame := GetProcAddress(OlePro32DLL, 'OleCreatePropertyFrame');
        @_OleCreateFontIndirect := GetProcAddress(OlePro32DLL, 'OleCreateFontIndirect');
        @_OleCreatePictureIndirect := GetProcAddress(OlePro32DLL, 'OleCreatePictureIndirect');
        @_OleLoadPicture := GetProcAddress(OlePro32DLL, 'OleLoadPicture');
      end;
    end;
  finally
    SetErrorMode(OldError);
  end;
end;

function OleCreatePropertyFrame(hwndOwner: HWnd; x, y: Integer;
  lpszCaption: POleStr; cObjects: Integer; pObjects: Pointer; cPages: Integer;
  pPageCLSIDs: Pointer; lcid: TLCID; dwReserved: Longint;
  pvReserved: Pointer): HResult;
begin
  if Assigned(_OleCreatePropertyFrame) then
    Result := _OleCreatePropertyFrame(hwndOwner, x, y, lpszCaption, cObjects,
      pObjects, cPages, pPageCLSIDs, lcid, dwReserved, pvReserved)
  else
    Result := E_UNEXPECTED;
end;

function OleCreateFontIndirect(const FontDesc: TFontDesc; const iid: TIID;
  out vObject): HResult;
begin
  if Assigned(_OleCreateFontIndirect) then
    Result := _OleCreateFontIndirect(FontDesc, iid, vObject)
  else
    Result := E_UNEXPECTED;
end;

function OleCreatePictureIndirect(const PictDesc: TPictDesc; const iid: TIID;
  fOwn: BOOL; out vObject): HResult;
begin
  if Assigned(_OleCreatePictureIndirect) then
    Result := _OleCreatePictureIndirect(PictDesc, iid, fOwn, vObject)
  else
    Result := E_UNEXPECTED;
end;

function OleLoadPicture(stream: IStream; lSize: Longint; fRunmode: BOOL;
  const iid: TIID; out vObject): HResult;
begin
  if Assigned(_OleLoadPicture) then
    Result := _OleLoadPicture(stream, lSize, fRunmode, iid, vObject)
  else
    Result := E_UNEXPECTED;
end;

initialization
  TPicture.RegisterFileFormat('', '', TOleGraphic);
  InitOlePro32;

finalization
  if xParkingWindow <> 0 then DestroyWindow(xParkingWindow);
  if OlePro32DLL <> 0 then FreeLibrary(OlePro32DLL);

end.
