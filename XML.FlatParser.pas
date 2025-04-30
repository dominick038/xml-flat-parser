unit XML.FlatParser;

interface

uses
  XML.FlatParser.Interfaces,
  System.SysUtils,
  Xml.XMLIntf,
  XML.FlatParser.Types;

type
  TXMLFlatParser<T: class, constructor> = class
  private
    FOnParsedBlock: TProc<T>;

    procedure SetOnParsedBlock(const OnParsedBlock: TProc<T>);

    function  CreateAndPopulate(const Block: string): T;
    procedure PopulateFromXML(Obj: TObject; const Block: string);
    function  ParseBlock(const Block: string; const Tag: string): string;
    function  ParseBlockArray(const Block: string; const Tag: string): TArray<string>;
    procedure InternalFlatParseXML(const Path: string; const BlockName: string; const IsAsync: Boolean);
  public
    procedure FlatParseXML(const Path: string; const BlockName: string);
    procedure FlatParseXMLAsync(const Path: string; const BlockName: string);

    property OnParsedBlock: TProc<T> write SetOnParsedBlock;
  end;

implementation

uses
  Vcl.Dialogs,
  System.Classes,
  System.UITypes,
  System.Threading,
  System.StrUtils,
  System.Rtti,
  System.TypInfo;

{ TXMLFlatParser }

procedure TXMLFlatParser<T>.SetOnParsedBlock(const OnParsedBlock: TProc<T>);
begin
  FOnParsedBlock := OnParsedBlock;
end;

procedure TXMLFlatParser<T>.FlatParseXML(const Path: string; const BlockName: string);
begin
  if not Assigned(FOnParsedBlock) then
  begin
    MessageDlg('No OnParsedBlock function assigned, nothing will happen with the output!', TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    Exit;
  end;

  InternalFlatParseXML(Path, BlockName, False);
end;

procedure TXMLFlatParser<T>.FlatParseXMLAsync(const Path, BlockName: string);
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

procedure TXMLFlatParser<T>.InternalFlatParseXML(const Path, BlockName: string; const IsAsync: Boolean);
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

          var Obj := CreateAndPopulate(Block);
          try
            FOnParsedBlock(Obj);
          finally
            Obj.Free;
          end;
        end;
      until Position = 0;
    end;

  finally
    FileStream.Free;
  end;
end;

function TXMLFlatParser<T>.ParseBlock(const Block: string; const Tag: string): string;
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
end;

function TXMLFlatParser<T>.ParseBlockArray(const Block: string; const Tag: string): TArray<string>;
begin
  var StartTag := '<com:' + Tag + '>';
  var EndTag   := '</com:' + Tag + '>';
  var Blocks := TStringList.Create;
  try
    var PosStart := Pos(StartTag, Block);
    while PosStart > 0 do
    begin
      var PosEnd := PosEx(EndTag, Block, PosStart) + Length(EndTag) - 1;
      if PosEnd <= 0 then
        Break;

      var BlockXML := Copy(Block, PosStart, PosEnd - PosStart + 1);
      Blocks.Add(BlockXML);
      PosStart := PosEx(StartTag, Block, PosEnd);
    end;
    Result := Blocks.ToStringArray;
  finally
    Blocks.Free;
  end;
end;

function TXMLFlatParser<T>.CreateAndPopulate(const Block: string): T;
begin
  Result := T.Create;
  PopulateFromXML(Result, Block);
end;

procedure TXMLFlatParser<T>.PopulateFromXML(Obj: TObject; const Block: string);
begin
  var RttiContext: TRttiContext;
  var RttiType := RttiContext.GetType(Obj.ClassType);
  for var Prop in RttiType.GetProperties do
  begin
    for var Attr in Prop.GetAttributes do
    begin
      if Attr is ParseElementAttribute then
      begin
        var ParseElement := Attr as ParseElementAttribute;

        var PropType := Prop.PropertyType;
        var TypeData := GetTypeData(PropType.Handle);
        if (PropType.TypeKind = tkDynArray) and (TypeData^.elType^ = TypeInfo(TNameRecord)) then
        begin
          var Chunks := ParseBlockArray(Block, ParseElement.Chain[0]);
          var Arr: TArray<TNameRecord>;
          SetLength(Arr, Length(Chunks));
          for var i := 0 to High(Chunks) do
          begin
            Arr[i].Spelling := ParseBlock(Chunks[i], 'spelling');
            Arr[i].Language := ParseBlock(Chunks[i], 'language');
          end;

          Prop.SetValue(Obj, TValue.From<TArray<TNameRecord>>(Arr));
        end
        else
        begin
          var SubBlock := Block;
          for var i := Low(ParseElement.Chain) to High(ParseElement.Chain) do
            SubBlock := ParseBlock(SubBlock, ParseElement.Chain[i]);
          var Value := SubBlock;

          if (Prop.PropertyType.Handle = TypeInfo(string)) or (Prop.PropertyType.Handle = TypeInfo(ShortString)) then
            Prop.SetValue(Obj, Value)
          else if Prop.PropertyType.Handle = TypeInfo(Integer) then
            Prop.SetValue(Obj, StrToIntDef(Value, 0));
        end;
      end;
    end;
  end;
end;

end.
