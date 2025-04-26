unit XML.FlatParser.Interfaces;

interface

uses
  System.SysUtils,
  Xml.XMLIntf;

type
  IXMLFlatParser = interface
  ['{6C140403-CE6D-4780-BC9B-A9C47BFB6749}']

  /// <summary>
  /// Flatly parses XML, this only works for highly predictable XML anything complex will fail
  /// </summary>
  procedure FlatParseXML(const Path: string; const BlockName: string);

  procedure SetOnParsedBlock(const OnParsedBlock: TProc<IXMLDocument>);

  property OnParsedBlock: TProc<IXMLDocument> write SetOnParsedBlock;
  end;

implementation

end.
