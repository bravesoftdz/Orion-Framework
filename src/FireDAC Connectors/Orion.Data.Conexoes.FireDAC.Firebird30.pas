unit Orion.Data.Conexoes.FireDAC.Firebird30;

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
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TOrionConexaoFireDACFirebird30 = class(TInterfacedObject, iConexao, iConexaoParametros)
  private
    FConexao :TFDConnection;
    FWaitCursor : TFDGUIxWaitCursor;
    FCaminhoBanco :string;
    FUserName :string;
    FSenha :string;
    FPorta :integer;
    FServer :string;
    FParams : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    class function New :iConexao;

    function Parametros :iConexaoParametros;
    function Conexao :iConexao;
    function Conectar :iConexao;
    function GetConnection :TComponent;
    function Dataset : iDataset;

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
  System.SysUtils, Orion.Data.DataSets.FireDAC.Query;

{ TOrionConexaoFireDACFirebird30 }

function TOrionConexaoFireDACFirebird30.CaminhoBanco(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FParams.Add('Database=' + aValue);
end;

function TOrionConexaoFireDACFirebird30.GetConnection: TComponent;
begin
  Result := FConexao;
end;

function TOrionConexaoFireDACFirebird30.Conectar: iConexao;
var
  lFDStanConnectionDef : IFDStanConnectionDef;
begin
  Result := Self;
  FConexao.Connected := True;
end;

function TOrionConexaoFireDACFirebird30.Conexao: iConexao;
begin
  Result := Self;
end;

constructor TOrionConexaoFireDACFirebird30.Create;
begin
  FParams := TStringList.Create;
  FConexao := TFDConnection.Create(nil);
  FWaitCursor := TFDGUIxWaitCursor.Create(nil);
end;

function TOrionConexaoFireDACFirebird30.Dataset: iDataset;
begin
  Result := TOrionDataSetFireDACQuery.New(Self);
end;

destructor TOrionConexaoFireDACFirebird30.Destroy;
begin
  FConexao.Connected := False;

  FreeAndNil(FConexao);
  FreeAndNil(FWaitCursor);
  FreeAndNil(FParams);
  inherited;
end;

function TOrionConexaoFireDACFirebird30.EndParametros: iConexao;
begin
  Result := Self;
  FParams.Add('Pooled=True');
  if not FDManager.IsConnectionDef('Conexao') then
  begin
    FParams.Add('POOL_MaximumItems=1000');
    FDManager.AddConnectionDef('Conexao', 'FB', FParams);
  end;

  FConexao.ConnectionDefName := 'Conexao';
end;

class function TOrionConexaoFireDACFirebird30.New: iConexao;
begin
  Result := Self.Create;
end;

function TOrionConexaoFireDACFirebird30.OSAuth: iConexaoParametros;
begin

end;

function TOrionConexaoFireDACFirebird30.Parametros: iConexaoParametros;
begin
  Result := Self;
end;

function TOrionConexaoFireDACFirebird30.Porta(aValue: integer): iConexaoParametros;
begin
  Result := Self;
  FPorta := aValue;
end;

function TOrionConexaoFireDACFirebird30.Senha(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FParams.Add('Password=' + aValue);
end;

function TOrionConexaoFireDACFirebird30.Server(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FServer := aValue;
end;

function TOrionConexaoFireDACFirebird30.UserName(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FParams.Add('User_Name=' + aValue);
end;

end.
