unit About1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TCSCImageXAbout = class(TForm)
    CtlImage: TSpeedButton;
    NameLbl: TLabel;
    OkBtn: TButton;
    CopyrightLbl: TLabel;
    DescLbl: TLabel;
    Label1: TLabel;
    Label2: TLabel;
  end;

procedure ShowCSCImageXAbout;

implementation

{$R *.DFM}

procedure ShowCSCImageXAbout;
begin
  with TCSCImageXAbout.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

end.
