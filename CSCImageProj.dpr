library CSCImageProj;

uses
  ComServ,
  CSCImageProj_TLB in 'CSCImageProj_TLB.pas',
  CSCImageImpl1 in 'CSCImageImpl1.pas' {CSCImageX: TActiveForm} {CSCImageX: CoClass},
  About1 in 'About1.pas' {CSCImageXAbout},
  AxCtrls in 'm:\dbl\axctrls.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

{$E ocx}

begin
end.
