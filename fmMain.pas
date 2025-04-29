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
  const FLANDERS_STREETNAME = '.\FlandersStreetName.xml';
  const FLANDERS_POSTAL_INFO = '.\FlandersPostalInfo.xml';
  const FLANDERS_MUNICIPALITY = '.\FlandersMunicipality.xml';
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
begin
  FormatSettings.DecimalSeparator := '.';

  var StopWatch := TStopwatch.StartNew;

  var XMLPostalInfoParser := TXMLFlatParser<TPostalInfo>.Create;
  try
    XMLPostalInfoParser.OnParsedBlock := (
      procedure(ParsedBlock: TPostalInfo)
      begin
        var X := ParsedBlock.Id;
      end
    );
    XMLPostalInfoParser.FlatParseXML(FLANDERS_POSTAL_INFO, 'tns:postalInfo');
  finally
    XMLPostalInfoParser.Free;
  end;

  var XMLStreetNameParser := TXMLFlatParser<TPostalInfo>.Create;
  try
    XMLStreetNameParser.OnParsedBlock := (
      procedure(ParsedBlock: TPostalInfo)
      begin
        var X := ParsedBlock.Id;
      end
    );
    XMLStreetNameParser.FlatParseXML(FLANDERS_STREETNAME, 'tns:streetName');
  finally
    XMLStreetNameParser.Free;
  end;

  var XMLMunicipalityParser := TXMLFlatParser<TPostalInfo>.Create;
  try
    XMLMunicipalityParser.OnParsedBlock := (
      procedure(ParsedBlock: TPostalInfo)
      begin
        var X := ParsedBlock.Id;
      end
    );
    XMLMunicipalityParser.FlatParseXML(FLANDERS_MUNICIPALITY, 'tns:municipality');
  finally
    XMLMunicipalityParser.Free;
  end;

  var XMLAddressParser := TXMLFlatParser<TAddress>.Create;
  try
    XMLAddressParser.OnParsedBlock := (
      procedure(ParsedBlock: TAddress)
      begin
        var X := ParsedBlock.HouseNumber;
      end
    );
    XMLAddressParser.FlatParseXML(FLANDERS_ADDRESS, 'tns:address');
  finally
    XMLAddressParser.Free;
  end;

  StopWatch.Stop;
  ShowMessage('Elapsed total seconds: ' + StopWatch.Elapsed.TotalSeconds.ToString);
end;

end.
