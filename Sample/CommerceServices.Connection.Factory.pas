unit CommerceServices.Connection.Factory;

interface

uses
  Orion.Data.Interfaces,

  CommerceServices.Connection.Interfaces;

type
  TConnectionFactory = class(TInterfacedObject, iConnectionFactory)
  private

  public
    constructor Create;
    destructor Destroy; override;
    class function New : iConnectionFactory;

    function Connection : iConexao;
    function DataSet : iDataSet; overload;
    function DataSet(aConexao : iConexao) : iDataSet; overload;
  end;
implementation

uses
  Orion.Data.Conexoes.FireDAC.Firebird30,
  Orion.Data.Datasets.FireDAC.Query,
  Orion.Data.Datasets.FireDAC.MemTable;

{ TConnectionFactory }

function TConnectionFactory.Connection: iConexao;
begin
  Result := TOrionConexaoFireDACFirebird30.New
              .Parametros
                .CaminhoBanco('E:\Projetos\Andromeda\BancoDados\DB.FDB')
                .UserName('SYSDBA')
                .Senha('r2d2c3p0')
                .Porta(3050)
                .Server('localhost')
              .EndParametros
              .Conectar;
end;

constructor TConnectionFactory.Create;
begin

end;

function TConnectionFactory.DataSet: iDataSet;
begin
  Result := TOrionDataSetFireDACMemTable.New;
end;

function TConnectionFactory.DataSet(aConexao: iConexao): iDataSet;
begin
  Result := TOrionDataSetFireDACQuery.New(aConexao);
end;

destructor TConnectionFactory.Destroy;
begin

  inherited;
end;

class function TConnectionFactory.New: iConnectionFactory;
begin
  Result := Self.Create;
end;

end.
