unit XML.FlatParser.Types;

interface

type
  ParseElementAttribute = class(TCustomAttribute)
  private
    FChain: TArray<string>;
  public
    constructor Create(const Chain: string);
    property Chain: TArray<string> read FChain;
  end;

  TAddress = class
  private
    FXY: string;
    FHouseNumber: ShortString;
    FStreetNameId: Integer;
    FMunicipalityId: Integer;
    FPostalInfoId: Integer;
  public

    [ParseElement('pos ')]
    property XY: string read FXY write FXY;

    [ParseElement('houseNumber')]
    property HouseNumber: ShortString read FHouseNumber write FHouseNumber;

    [ParseElement('hasStreetName->objectIdentifier')]
    property StreetNameId: Integer read FStreetNameId write FStreetNameId;

    [ParseElement('hasMunicipality->objectIdentifier')]
    property MunicipalityId: Integer read FMunicipalityId write FMunicipalityId;

    [ParseElement('hasPostalInfo->objectIdentifier')]
    property PostalInfoId: Integer read FPostalInfoId write FPostalInfoId;
  end;

  TPostalInfo = class
  private
    FId: integer;
    FSpelling: string;
    FLanguage: string;
  public
    [ParseElement('code->objectIdentifier')]
    property Id: Integer read FId write FId;

    [ParseElement('name->spelling')]
    property Spelling: string read FSpelling write FSpelling;

    [ParseElement('name->language')]
    property Language: string read FLanguage write FLanguage;
  end;

  TMunicipality = class
  private
    FId: integer;
    FSpelling: string;
    FLanguage: string;
  public
    [ParseElement('code->objectIdentifier')]
    property Id: Integer read FId write FId;

    [ParseElement('name->spelling')]
    property Spelling: string read FSpelling write FSpelling;

    [ParseElement('name->language')]
    property Language: string read FLanguage write FLanguage;
  end;

  TStreetName = class
  private
    FId: integer;
    FSpelling: string;
    FLanguage: string;
  public
    [ParseElement('code->objectIdentifier')]
    property Id: Integer read FId write FId;

    [ParseElement('name->spelling')]
    property Spelling: string read FSpelling write FSpelling;

    [ParseElement('name->language')]
    property Language: string read FLanguage write FLanguage;
  end;

implementation

uses
  System.SysUtils;

{ ParseElementAttribute }

constructor ParseElementAttribute.Create(const Chain: string);
begin
  FChain := Chain.Split(['->']);
end;

end.
