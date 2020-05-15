unit Orion.Data.Factory.FireDAC;

interface

uses
  Orion.Data.Interfaces;
type
  TOrionDataFactoryFireDAC = class(TInterfacedObject, iFactoryFireDAC)
  private

  public
    constructor Create;
    destructor Destroy; override;
    class function New :iFactoryFireDAC;

    function Conexao(aTipoBanco : TTipoBanco) :iConexao;
    function Query(aConexao :iConexao) :iDataSet;
    function MemTable :iDataSet;
  end;
implementation

uses
  Orion.Data.Conexoes.FireDAC.Firebird30,
  Orion.Data.DataSets.FireDAC.MemTable,
  Orion.Data.DataSets.FireDAC.Query;

{ TOrionDataFactoryFireDAC }

function TOrionDataFactoryFireDAC.Conexao(aTipoBanco : TTipoBanco) : iConexao;
begin
  case aTipoBanco of
    tpFirebird30: Result := TOrionConexaoFireDACFirebird30.New;
    tpFirebird25: Result := TOrionConexaoFireDACFirebird30.New;
  end;
end;

constructor TOrionDataFactoryFireDAC.Create;
begin

end;

destructor TOrionDataFactoryFireDAC.Destroy;
begin

  inherited;
end;

function TOrionDataFactoryFireDAC.MemTable: iDataSet;
begin
  Result := TOrionDataSetFireDACMemTable.New;
end;

class function TOrionDataFactoryFireDAC.New: iFactoryFireDAC;
begin
  Result := Self.Create;
end;

function TOrionDataFactoryFireDAC.Query(aConexao: iConexao): iDataSet;
begin
  Result := TOrionDataSetFireDACQuery.New(aConexao);
end;

end.
