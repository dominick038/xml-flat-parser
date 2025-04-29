program xml_flat_parser;

uses
  Vcl.Forms,
  fmMain in 'fmMain.pas' {fm_Main},
  fmProgressPopUp in 'fmProgressPopUp.pas' {fm_ProgressPopUp},
  XML.FlatParser in 'XML.FlatParser.pas',
  XML.FlatParser.Interfaces in 'XML.FlatParser.Interfaces.pas',
  XML.FlatParser.Types in 'XML.FlatParser.Types.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tfm_Main, fm_Main);
  Application.Run;
end.
