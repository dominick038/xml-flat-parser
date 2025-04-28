unit fmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  Tfm_Main = class(TForm)
    redParserOutput: TRichEdit;
    pnlBody: TPanel;
    pnlFoot: TPanel;
    btnTryFlatParse: TButton;
    procedure btnTryFlatParseClick(Sender: TObject);
  private

  const FLANDERS_ADDRESS = '.\FlandersAddress.xml';
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fm_Main: Tfm_Main;

implementation

uses
  System.Diagnostics,
  XML.FlatParser,
  XML.FlatParser.Interfaces,
  Xml.XMLIntf,
  XML.FlatParser.Types;

{$R *.dfm}

procedure Tfm_Main.btnTryFlatParseClick(Sender: TObject);
const
  BUFF_SIZE = 64 * 1024;
  DELIM = '</tns:address>';
begin
  FormatSettings.DecimalSeparator := '.';

  var StopWatch := TStopwatch.StartNew;

  var XMLFlatParser: IXMLFlatParser := TXMLFlatParser.Create;

  XMLFlatParser.OnParsedBlock := (
    procedure(ParsedBlock: TAddress)
    begin
    end
  );

  XMLFlatParser.FlatParseXML(FLANDERS_ADDRESS, 'tns:address');

  StopWatch.Stop;
  ShowMessage('Elapsed total seconds: ' + StopWatch.Elapsed.TotalSeconds.ToString);
end;

end.
