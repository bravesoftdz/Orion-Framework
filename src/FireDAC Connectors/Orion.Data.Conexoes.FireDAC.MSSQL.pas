unit Orion.Data.Conexoes.FireDAC.MSSQL;

interface

uses
  Orion.Data.Interfaces,
  System.Classes,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,

  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Phys.ODBCBase,
  FireDAC.Comp.Client;

type
  TOrionConexaoFireDACMSSQL = class(TInterfacedObject, iConexao, iConexaoParametros)
  private
    FConexao :TFDConnection;

    FCaminhoBanco :string;
    FUserName :string;
    FSenha :string;
    FPorta :integer;
    FServer :string;
    FOSAuth : string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New :iConexao;

    function Parametros :iConexaoParametros;
    function Conexao :iConexao;
    function Conectar :iConexao;
    function GetConnection :TComponent;

    function CaminhoBanco(aValue :string) :iConexaoParametros;
    function UserName(aValue :string) :iConexaoParametros;
    function Senha(aValue :string) :iConexaoParametros;
    function Porta(aValue :integer) :iConexaoParametros;
    function Server(aValue :string) :iConexaoParametros;
    function OSAuth : iConexaoParametros;
    function &EndParametros:iConexao;
  end;
implementation

uses
  System.SysUtils;

{ TOrionConexaoFireDACMSSQL }

function TOrionConexaoFireDACMSSQL.CaminhoBanco(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FCaminhoBanco := aValue;
end;

function TOrionConexaoFireDACMSSQL.GetConnection: TComponent;
begin
  Result := FConexao;
end;

function TOrionConexaoFireDACMSSQL.Conectar: iConexao;
begin
  Result := Self;
  FConexao.DriverName                 := 'MSSQL';
  FConexao.Params.Database            := FCaminhoBanco;
  FConexao.Params.UserName            := FUserName;
  FConexao.Params.Password            := FSenha;
  FConexao.Params.DriverID            := 'MSSQL';
  FConexao.Params.Values['Server']    := FServer;
  FConexao.Params.Values['OsAuthent'] := FOSAuth;
  FConexao.Connected := True;
end;

function TOrionConexaoFireDACMSSQL.Conexao: iConexao;
begin
  Result := Self;
end;

constructor TOrionConexaoFireDACMSSQL.Create;
begin
  FConexao := TFDConnection.Create(nil);
  FOSAuth := 'No';
end;

destructor TOrionConexaoFireDACMSSQL.Destroy;
begin
  FConexao.Connected := False;
  FConexao.ResourceOptions.KeepConnection := False;

  FreeAndNil(FConexao);
  inherited;
end;

function TOrionConexaoFireDACMSSQL.EndParametros: iConexao;
begin
  Result := Self;
end;

class function TOrionConexaoFireDACMSSQL.New: iConexao;
begin
  Result := Self.Create;
end;

function TOrionConexaoFireDACMSSQL.OSAuth: iConexaoParametros;
begin
  Result := Self;
  FOSAuth := 'Yes';
end;

function TOrionConexaoFireDACMSSQL.Parametros: iConexaoParametros;
begin
  Result := Self;
end;

function TOrionConexaoFireDACMSSQL.Porta(aValue: integer): iConexaoParametros;
begin
  Result := Self;
  FPorta := aValue;
end;

function TOrionConexaoFireDACMSSQL.Senha(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FSenha := aValue;
end;

function TOrionConexaoFireDACMSSQL.Server(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FServer := aValue;
end;

function TOrionConexaoFireDACMSSQL.UserName(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FUserName := aValue;
end;

end.
