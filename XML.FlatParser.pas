unit XML.FlatParser;

interface

uses
  XML.FlatParser.Interfaces,
  System.SysUtils,
  Xml.XMLIntf;

type
  TXMLFlatParser = class(TInterfacedObject, IXMLFlatParser)
  private
    FOnParsedBlock: TProc<IXMLDocument>;

    procedure SetOnParsedBlock(const OnParsedBlock: TProc<IXMLDocument>);

    procedure InternalFlatParseXML(const Path: string; const BlockName: string; const IsAsync: Boolean);
  public
    procedure FlatParseXML(const Path: string; const BlockName: string);
    procedure FlatParseXMLAsync(const Path: string; const BlockName: string);

    property OnParsedBlock: TProc<IXMLDocument> write SetOnParsedBlock;
  end;

implementation

uses
  Vcl.Dialogs,
  System.Classes,
  System.UITypes,
  System.Threading;

{ TXMLFlatParser }

procedure TXMLFlatParser.InternalFlatParseXML(const Path, BlockName: string; const IsAsync: Boolean);
const
  BUFF_SIZE = 64 * 1024;
begin
  if not Assigned(FOnParsedBlock) then
  begin
    MessageDlg('No OnParsedBlock function assigned, nothing will happen with the output!', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  var Delim := '</' + BlockName + '>';

  var RawBuff: TBytes;
  SetLength(RawBuff, BUFF_SIZE);

  var Buffer := '';
  var FileStream := TFileStream.Create(Path, fmOpenRead or fmShareDenyWrite);
  try
    while FileStream.Position < FileStream.Size do
    begin
      var ReadCount := FileStream.Read(RawBuff[0], BUFF_SIZE);
      if ReadCount = 0 then
        Break;

      Buffer := Buffer + TEncoding.UTF8.GetString(RawBuff, 0, ReadCount);

      var Position: Integer;
      repeat
        Position := Pos(Delim, Buffer);
        if Position > 0 then
        begin
          var Block := Copy(Buffer, 1, Position + Length(Delim) - 1);
          Delete(Buffer, 1, Position + Length(Delim) - 1);

          var XMLDoc: IXMLDocument;
          XMLDoc.LoadFromXML(Block);
          FOnParsedBlock(XMLDoc);
        end;
      until Position = 0;

    end;

  finally
    FileStream.Free;
  end;
end;

procedure TXMLFlatParser.FlatParseXML(const Path: string; const BlockName: string);
begin
  InternalFlatParseXML(Path, BlockName, False);
end;

procedure TXMLFlatParser.FlatParseXMLAsync(const Path, BlockName: string);
begin
  TTask.Run(
    procedure
    begin
      InternalFlatParseXML(Path, BlockName, True);
    end)
end;

procedure TXMLFlatParser.SetOnParsedBlock(const OnParsedBlock: TProc<IXMLDocument>);
begin
  FOnParsedBlock := OnParsedBlock;
end;

end.
