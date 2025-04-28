unit XML.FlatParser.Types;

interface

type

  TAddress = record
  X: Double;
  Y: Double;
  HouseNumber: string;
  StreetNameId: Integer;
  MunicipalityId: Integer;
  PostalInfoId: Integer;

  constructor Create(const XY: string;
                     const HouseNumber: string;
                     const StreetNameId: string;
                     const MunicipalityId: string;
                     const PostalInfoId: string);
  end;

implementation

uses
  System.SysUtils;

{ TAddress }

constructor TAddress.Create(const XY, HouseNumber, StreetNameId, MunicipalityId, PostalInfoId: string);
begin
  var XYArr := XY.Split([' ']);
  Self.X := StrToFloat(XYArr[0]);
  Self.Y := StrToFloat(XYArr[1]);

  Self.HouseNumber := HouseNumber;
  Self.StreetNameId := StrToInt(StreetNameId);
  Self.MunicipalityId := strToInt(MunicipalityId);
  Self.PostalInfoId := StrToInt(PostalInfoId);
end;

end.
