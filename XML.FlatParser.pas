unit XML.FlatParser;

interface

uses
  XML.FlatParser.Interfaces,
  System.SysUtils,
  Xml.XMLIntf,
  XML.FlatParser.Types;

type
  TXMLFlatParser = class(TInterfacedObject, IXMLFlatParser)
  private
    FOnParsedBlock: TProc<TAddress>;

    procedure SetOnParsedBlock(const OnParsedBlock: TProc<TAddress>);

    function  ParseBlock(const Block: string; const Tag: string; const InnerTag: string = ''): string;
    procedure InternalFlatParseXML(const Path: string; const BlockName: string; const IsAsync: Boolean);
  public
    procedure FlatParseXML(const Path: string; const BlockName: string);
    procedure FlatParseXMLAsync(const Path: string; const BlockName: string);

    property OnParsedBlock: TProc<TAddress> write SetOnParsedBlock;
  end;

implementation

uses
  Vcl.Dialogs,
  System.Classes,
  System.UITypes,
  System.Threading,
  System.StrUtils;

{ TXMLFlatParser }

procedure TXMLFlatParser.InternalFlatParseXML(const Path, BlockName: string; const IsAsync: Boolean);
const
  BUFF_SIZE = 64 * 1024;
begin
  var StartBlock := '<' + BlockName + ' ';
  var EndBlock := '</' + BlockName + '>';
  var StartBlockFound := False;

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

      if not StartBlockFound then
      begin
        var StartPos := Pos(StartBlock, Buffer);
        if StartPos > 0 then
        begin
          Delete(Buffer, 1, StartPos - 1);
          StartBlockFound := True;
        end;
      end;

      var Position: Integer;
      repeat
        Position := Pos(EndBlock, Buffer);
        if Position > 0 then
        begin
          var Block := Copy(Buffer, 1, Position + Length(EndBlock) - 1);
          Delete(Buffer, 1, Position + Length(EndBlock) - 1);

          var XY := ParseBlock(Block, 'pos ');
          var HouseNumber := ParseBlock(Block, 'houseNumber');
          var StreetNameId := ParseBlock(Block, 'hasStreetName', 'objectIdentifier');
          var MunicipalityId := ParseBlock(Block, 'hasMunicipality', 'objectIdentifier');
          var PostalInfoId := ParseBlock(Block, 'hasPostalInfo', 'objectIdentifier');

          var ParsedBlock := TAddress.Create(XY, HouseNumber, StreetNameId, MunicipalityId, PostalInfoId);
          FOnParsedBlock(ParsedBlock);
        end;
      until Position = 0;
    end;

  finally
    FileStream.Free;
  end;
end;

function TXMLFlatParser.ParseBlock(const Block: string; const Tag: string; const InnerTag: string): string;
begin
  var StartTag := '<com:' + Tag;
  var EndTag := '</com:' + Tag.Trim + '>';

  var SPos := Pos(StartTag, Block);
  if SPos = 0 then
    raise Exception.Create('Tag not found');

  SPos := PosEx('>', Block, SPos) + 1;
  if SPos = 1 then
    raise Exception.Create('Malformed opening tag');

  var EPos := Pos(EndTag, Block);
  if EPos = 0 then
    raise Exception.Create('Closing tag not found');

  Result := Copy(Block, SPos, EPos - SPos);

  if InnerTag <> string.Empty then
    Result := ParseBlock(Result, InnerTag);
end;

procedure TXMLFlatParser.FlatParseXML(const Path: string; const BlockName: string);
begin
  if not Assigned(FOnParsedBlock) then
  begin
    MessageDlg('No OnParsedBlock function assigned, nothing will happen with the output!', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  InternalFlatParseXML(Path, BlockName, False);
end;

procedure TXMLFlatParser.FlatParseXMLAsync(const Path, BlockName: string);
begin
  if not Assigned(FOnParsedBlock) then
  begin
    MessageDlg('No OnParsedBlock function assigned, nothing will happen with the output!', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  TTask.Run(
    procedure
    begin
      InternalFlatParseXML(Path, BlockName, True);
    end)
end;

procedure TXMLFlatParser.SetOnParsedBlock(const OnParsedBlock: TProc<TAddress>);
begin
  FOnParsedBlock := OnParsedBlock;
end;

end.
