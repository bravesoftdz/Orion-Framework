unit Orion.Data.DataSets.FireDAC.Query;

interface

uses
  Orion.Data.Interfaces,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Classes, System.JSON;

type
  TOrionDataSetFireDACQuery = class(TInterfacedObject, iDataSet)
  private
    FConexao :iConexao;
    FDataSet :TFDQuery;
    procedure InternalSearchMode(aValue :boolean);
  public
    constructor Create(aConexao :iConexao);
    destructor Destroy; override;
    class function New(aConexao :iConexao) :iDataSet;

    function SQL(aValue :string) :iDataSet;
    function CreateDataSet : iDataSet;
    function Name(aValue :string) : IDataSet; overload;
    function Name :string; overload;
    function Assign(aValue :TPersistent):iDataSet;
    function Fields :TFields;
    function FieldDefs :TFieldDefs;
    function ExecSQL :iDataSet;
    function Append :iDataSet;
    function Insert :iDataSet;
    function Edit :iDataSet;
    function Post :iDataSet;
    function Cancel :iDataSet;
    function Delete :iDataSet;
    function First :iDataSet;
    function Next :iDataSet;
    function Last :iDataSet;
    function Prior :iDataSet;
    function RecordCount :integer;
    function DataSource(aValue :TDataSource) :iDataSet;
    function AsJSONObject :TJSONObject;
    function AsJSONArray :TJSONArray;
    function Filter(aValue :string) : iDataSet;
    function Filtered(aValue :boolean) : iDataSet;
    function DataSet : TDataSet;
    function DisableControls : iDataSet;
    function EnableControls : iDataSet;
    function EmptyDataSet : iDataSet;

    function Eof :Boolean;
    function Bof :Boolean;

    function ApplyUpdates(aMaxErrors :integer) :integer;
    function Close :iDataSet;
    function Open :iDataSet;
    function EmptyOpen :iDataSet;
    function SearchMode(aValue :Boolean) :iDataSet;
    function Locate(const aKeyFields: string; const aKeyValues: Variant; aOptions: TLocateOptions): Boolean;
    function Recno :integer;
    function Clone : IDataSet;
    procedure AfterScroll(aEvent : TAfterScroll);
  end;
implementation

uses
  System.SysUtils;

{ TOrionDataSetFireDACQuery }

procedure TOrionDataSetFireDACQuery.AfterScroll(aEvent: TAfterScroll);
begin
  FDataSet.AfterScroll := aEvent;
end;

function TOrionDataSetFireDACQuery.Append: iDataSet;
begin
  Result := Self;
  FDataSet.Append;
end;

function TOrionDataSetFireDACQuery.ApplyUpdates(aMaxErrors: integer): integer;
begin
  TFdConnection(FConexao.GetConnection).StartTransaction;
  try
    Result := FDataSet.ApplyUpdates(aMaxErrors);
    TFdConnection(FConexao.GetConnection).Commit;

  except on E: Exception do
    begin
      TFdConnection(FConexao.GetConnection).Rollback;
      raise Exception.Create('Falha na gravação dos dados no banco de dados.');
    end;
  end;
end;

function TOrionDataSetFireDACQuery.AsJSONArray: TJSONArray;
begin

end;

function TOrionDataSetFireDACQuery.AsJSONObject: TJSONObject;
begin

end;

function TOrionDataSetFireDACQuery.Assign(aValue: TPersistent): iDataSet;
begin
  Result := Self;
  FDataset.Assign(aValue);
end;

function TOrionDataSetFireDACQuery.Bof: Boolean;
begin

  Result := FDataSet.Bof;

end;

function TOrionDataSetFireDACQuery.Cancel: iDataSet;
begin
  Result := Self;
  FDataSet.Cancel;
end;

function TOrionDataSetFireDACQuery.Clone: IDataSet;
begin
  Result := New(FConexao);
end;

function TOrionDataSetFireDACQuery.Close: iDataSet;
begin
  Result := Self;
  FDataSet.Close;
end;

constructor TOrionDataSetFireDACQuery.Create(aConexao :iConexao);
begin
  FConexao := aConexao;
  FDataSet := TFDQuery.Create(nil);

  FDataSet.Connection        := TFDCustomConnection(FConexao.GetConnection);
  FDataSet.FetchOptions.Mode := fmAll;
  FDataSet.CachedUpdates     := True;
end;

function TOrionDataSetFireDACQuery.CreateDataSet: iDataSet;
begin
  Result := Self;
end;

function TOrionDataSetFireDACQuery.DataSet: TDataSet;
begin
  Result := FDataSet;
end;

function TOrionDataSetFireDACQuery.DataSource(aValue: TDataSource): iDataSet;
begin
  Result := Self;
  aValue.DataSet := FDataSet;
end;

function TOrionDataSetFireDACQuery.Delete: iDataSet;
begin
  Result := Self;
  FDataSet.Delete;
end;

destructor TOrionDataSetFireDACQuery.Destroy;
begin
  FreeAndNil(FDataSet);
  inherited;
end;

function TOrionDataSetFireDACQuery.DisableControls: iDataSet;
begin
  Result := Self;
  FDataSet.DisableControls;
end;

function TOrionDataSetFireDACQuery.Edit: iDataSet;
begin
  Result := Self;
  FDataSet.Edit;
end;

function TOrionDataSetFireDACQuery.EmptyDataSet: iDataSet;
begin
  Result := Self;
  FDataset.EmptyDataSet;
end;

function TOrionDataSetFireDACQuery.EmptyOpen: iDataSet;
begin
  if FDataSet.SQL.Count > 0 then
  begin
    FDataSet.SQL.Add(' where 1 = 2');
    FConexao.Conectar;
    FDataSet.Open;
  end;
end;

function TOrionDataSetFireDACQuery.EnableControls: iDataSet;
begin
  Result := Self;
  FDataSet.EnableControls;
end;

function TOrionDataSetFireDACQuery.Eof: Boolean;
begin
  Result := FDataSet.Eof;
end;

function TOrionDataSetFireDACQuery.ExecSQL: iDataSet;
begin
  Result := Self;
  FDataSet.ExecSQL;
end;

function TOrionDataSetFireDACQuery.FieldDefs: TFieldDefs;
begin
  Result := FDataSet.FieldDefs;
end;

function TOrionDataSetFireDACQuery.Fields: TFields;
begin
  Result := FDataSet.Fields;
end;

function TOrionDataSetFireDACQuery.Filter(aValue: string): iDataSet;
begin
  Result := Self;
  FDataset.Filter := aValue;
end;

function TOrionDataSetFireDACQuery.Filtered(aValue: boolean): iDataSet;
begin
  Result := Self;
  FDataset.Filtered := aValue;
end;

function TOrionDataSetFireDACQuery.First: iDataSet;
begin
  Result := Self;
  FDataSet.First;
end;

function TOrionDataSetFireDACQuery.Insert: iDataSet;
begin
  Result := Self;
  FDataSet.Insert;
end;

procedure TOrionDataSetFireDACQuery.InternalSearchMode(aValue: boolean);
begin
  if aValue then
  begin
    FDataSet.FetchOptions.CursorKind := ckForwardOnly;
    FDataSet.FetchOptions.Unidirectional := True;
    FDataSet.FetchOptions.Cache := [];
  end
  else
  begin
    FDataSet.FetchOptions.CursorKind := ckAutomatic;
    FDataSet.FetchOptions.Unidirectional := False;
    FDataSet.FetchOptions.Cache := [fiBlobs, fiDetails, fiMeta];
  end;
end;

function TOrionDataSetFireDACQuery.Last: iDataSet;
begin
  Result := Self;
  FDataSet.Last;
end;

function TOrionDataSetFireDACQuery.Locate(const aKeyFields: string; const aKeyValues: Variant; aOptions: TLocateOptions): Boolean;
begin
  Result := FDataSet.Locate(aKeyFields, aKeyValues, aOptions);
end;

function TOrionDataSetFireDACQuery.Name: string;
begin
  Result := FDataset.Name;
end;

function TOrionDataSetFireDACQuery.Name(aValue: string): IDataSet;
begin
  Result := Self;
  FDataset.Name := aValue;
end;

class function TOrionDataSetFireDACQuery.New(aConexao :iConexao) : iDataSet;
begin
  Result := Self.Create(aConexao);
end;

function TOrionDataSetFireDACQuery.Next: iDataSet;
begin
  Result := Self;
  FDataSet.Next;
end;

function TOrionDataSetFireDACQuery.Open: iDataSet;
begin
  Result := Self;
  FConexao.Conectar;
  FDataSet.Open;
end;

function TOrionDataSetFireDACQuery.Post: iDataSet;
begin
  Result := Self;
  FDataSet.Post;
end;

function TOrionDataSetFireDACQuery.Prior: iDataSet;
begin
  Result := Self;
  FDataSet.Prior;
end;

function TOrionDataSetFireDACQuery.Recno: integer;
begin
  Result := FDataSet.RecNo;
end;

function TOrionDataSetFireDACQuery.RecordCount: integer;
begin
  Result := FDataSet.RecordCount;
end;

function TOrionDataSetFireDACQuery.SearchMode(aValue :Boolean) : iDataSet;
begin
  Result := Self;
  InternalSearchMode(aValue);
end;

function TOrionDataSetFireDACQuery.SQL(aValue: string): iDataSet;
begin
  Result := Self;
  FDataSet.SQL.Clear;
  FDataSet.SQL.Add(aValue);
end;

end.
