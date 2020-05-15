unit Orion.Attributes;

interface

type
  TTipoCampo = (tcString, tcInteger, tcFloat, tcDateTime, tcBoolean, tcBlob);
  Tabela = class(TCustomAttribute)
  private
    FNome :string;
    procedure SetNome(const Value: string);
  public
    constructor Create(aNome :string);
    property Nome :string read FNome write SetNome;
  end;

  Campo = class(TCustomAttribute)
  private
    FNome :string;
    FFieldType: TTipoCampo;
    FTamanho: integer;
    FDisplayWidth: integer;
    FDisplayLabel: string;
    procedure SetNome(const Value: string);
    procedure SetFieldType(const Value: TTipoCampo);
    procedure SetTamanho(const Value: integer);
    procedure SetDisplayWidth(const Value: integer);
    procedure SetDisplayLabel(const Value: string);
  public
    constructor Create(aNome, aDisplayLabel :string; aFieldType :TTipoCampo; aTamanho :integer = 0; aDisplayWidth :integer = 0);
    property Nome :string read FNome write SetNome;
    property TipoCampo :TTipoCampo read FFieldType write SetFieldType;
    property Tamanho :integer read FTamanho write SetTamanho;
    property DisplayWidth :integer read FDisplayWidth write SetDisplayWidth;
    property DisplayLabel :string read FDisplayLabel write SetDisplayLabel;
  end;

  Join = class(TCustomAttribute)
  private
    FJoin :string;
    FTableName: string;
    procedure SetJoin(const Value: string);
    procedure SetTableName(const Value: string);
  public
    constructor Create(aTableName, aJoin :string);
    property TableName :string read FTableName write SetTableName;
    property Join :string read FJoin write SetJoin;
  end;

  PK = class(TCustomAttribute)
  end;

  Ignorar = class(TCustomAttribute)
  end;

  IgnorarCRUD = class(TCustomAttribute)
  end;

  AutoInc = class(TCustomAttribute)
  end;

  ID = class(TCustomAttribute)
  end;
  TParametros = array of string;

  RestResource = class(TCustomAttribute)
  private
    FResource: string;
    procedure SetResource(const Value: string);
  public
    constructor Create(aResource :string);
    property Resource :string read FResource write SetResource;
  end;

  ForeignLink = class(TCustomAttribute)
  end;

implementation

{ Tabela }

constructor Tabela.Create(aNome: string);
begin
  FNome := aNome;
end;

procedure Tabela.SetNome(const Value: string);
begin
  FNome := Value;
end;

{ Campo }

constructor Campo.Create(aNome, aDisplayLabel :string; aFieldType :TTipoCampo; aTamanho :integer = 0; aDisplayWidth :integer = 0);
begin
  FNome         := aNome;
  FFieldType    := aFieldType;
  FTamanho      := aTamanho;
  FDisplayWidth := aDisplayWidth;
  FDisplayLabel := aDisplayLabel;
end;

procedure Campo.SetDisplayLabel(const Value: string);
begin
  FDisplayLabel := Value;
end;

procedure Campo.SetDisplayWidth(const Value: integer);
begin
  FDisplayWidth := Value;
end;

procedure Campo.SetFieldType(const Value: TTipoCampo);
begin
  FFieldType := Value;
end;

procedure Campo.SetNome(const Value: string);
begin
  FNome := Value;
end;

procedure Campo.SetTamanho(const Value: integer);
begin
  FTamanho := Value;
end;

{ RestResource }

constructor RestResource.Create(aResource :string);
begin
  FResource := aResource;
end;
procedure RestResource.SetResource(const Value: string);
begin
  FResource := Value;
end;

{ Join }

constructor Join.Create(aTableName, aJoin :string);
begin
  FJoin := aJoin;
  FTableName := aTableName;
end;

procedure Join.SetJoin(const Value: string);
begin
  FJoin := Value;
end;

procedure Join.SetTableName(const Value: string);
begin
  FTableName := Value;
end;

end.
