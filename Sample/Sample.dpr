program Sample;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  CommerceServices.Connection.Factory in 'CommerceServices.Connection.Factory.pas',
  CommerceServices.Connection.Interfaces in 'CommerceServices.Connection.Interfaces.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
