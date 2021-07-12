unit Orion.Data.DataSets.FireDAC.MemTable;

interface

uses
  Data.DB,

  Orion.Data.Interfaces,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,

  System.Classes,
  System.JSON,

  REST.Client,
  REST.Response.Adapter,
  REST.Types;

type
  TOrionDataSetFireDACMemTable = class(TInterfacedObject, iDataSet)
  private
    FDataset :TFDMEmTable;
    procedure MelhorarDesempenho;
  public
    constructor Create;
    destructor Destroy; override;
    class function New :iDataSet;

    {iDataSet}
    function CreateDataSet : iDataSet;
    function Name(aValue :string) : IDataSet; overload;
    function Name :string; overload;
    function SQL(aValue :string) :iDataSet;
    function Assign(aValue :TPersistent):iDataSet;
    function Open :iDataSet;
    function Close :iDataSet;
    function Append :iDataSet;
    function Insert :iDataSet;
    function Edit :iDataSet;
    function Cancel :iDataSet;
    function Post :iDataSet;
    function Delete :iDataSet;
    function Next :iDataSet;
    function Last :iDataSet;
    function Prior :iDataSet;
    function First :iDataSet;
    function EOF :boolean;
    function BOF :boolean;
    function ApplyUpdates(aMaxErrors:integer): integer;
    function RecordCount : integer;
    function Locate(const aKeyFields: string; const aKeyValues: Variant; aOptions: TLocateOptions): Boolean;
    function DataSource(aValue :TDataSource) :iDataSet;
    function Fields :TFields;
    function FieldDefs :TFieldDefs;
    function Filter(aValue :string) : iDataSet;
    function Filtered(aValue :boolean) : iDataSet;
    function DataSet : TDataSet;
    function ExecSQL : iDataSet;
    function DisableControls : iDataSet;
    function EnableControls : iDataSet;
    function EmptyDataSet : iDataSet;
    function EmptyOpen :iDataSet;
    function RecNo : integer;
    function Clone : IDataSet;
    procedure AfterScroll(aEvent : TAfterScroll);
  end;
implementation

uses
  System.SysUtils;
{ TOrionDataSetFireDACMemTable }

procedure TOrionDataSetFireDACMemTable.AfterScroll(aEvent: TAfterScroll);
begin
  FDataset.AfterScroll := aEvent;
end;

function TOrionDataSetFireDACMemTable.Append: iDataSet;
begin
  Result := Self;
  FDataset.Append;
end;

function TOrionDataSetFireDACMemTable.ApplyUpdates(aMaxErrors: integer): integer;
begin
  Result := 0;
  FDataset.ApplyUpdates;
end;

function TOrionDataSetFireDACMemTable.Assign(aValue: TPersistent): iDataSet;
begin
  Result := Self;
  FDataset.Assign(aValue);
end;

function TOrionDataSetFireDACMemTable.BOF: boolean;
begin
  Result := FDataset.Bof;
end;

function TOrionDataSetFireDACMemTable.Cancel: iDataSet;
begin
  Result := Self;
  FDataset.Cancel;
end;

function TOrionDataSetFireDACMemTable.Clone: IDataSet;
begin
  Result := New;
end;

function TOrionDataSetFireDACMemTable.Close: iDataSet;
begin
  Result := Self;
  FDataset.Close;
end;

constructor TOrionDataSetFireDACMemTable.Create;
begin
  FDataset := TFDMemTable.Create(nil);
  FDataset.CachedUpdates := True;
  MelhorarDesempenho;
end;

function TOrionDataSetFireDACMemTable.CreateDataSet: iDataSet;
begin
  Result := Self;
  FDataset.CreateDataSet;
end;

function TOrionDataSetFireDACMemTable.DataSet: TDataSet;
begin
  Result := FDataset;
end;

function TOrionDataSetFireDACMemTable.DataSource(aValue: TDataSource): iDataSet;
begin
  Result := Self;
  aValue.DataSet := FDataset;
end;

function TOrionDataSetFireDACMemTable.Delete: iDataSet;
begin
  Result := Self;
  FDataset.Delete;
end;

destructor TOrionDataSetFireDACMemTable.Destroy;
begin
  FreeAndNil(FDataSet);

  inherited;
end;

function TOrionDataSetFireDACMemTable.DisableControls: iDataSet;
begin
  Result := Self;
  FDataset.DisableControls;
end;

function TOrionDataSetFireDACMemTable.Edit: iDataSet;
begin
  Result := Self;
  FDataset.Edit;
end;

function TOrionDataSetFireDACMemTable.EmptyDataSet: iDataSet;
begin
  Result := Self;
  FDataset.EmptyDataSet;
end;

function TOrionDataSetFireDACMemTable.EmptyOpen: iDataSet;
begin

end;

function TOrionDataSetFireDACMemTable.EnableControls: iDataSet;
begin
  Result := Self;
  FDataset.EnableControls;
end;

function TOrionDataSetFireDACMemTable.EOF: boolean;
begin
  Result := FDataset.Eof;
end;

function TOrionDataSetFireDACMemTable.ExecSQL: iDataSet;
begin
  Result := Self;
  raise Exception.Create(FDataset.ClassName + ' Este tipo de DataSet não possui este método.');
end;

function TOrionDataSetFireDACMemTable.FieldDefs: TFieldDefs;
begin
  Result := FDataset.FieldDefs;
end;

function TOrionDataSetFireDACMemTable.Fields: TFields;
begin
  Result := FDataset.Fields;
end;

function TOrionDataSetFireDACMemTable.Filter(aValue: string): iDataSet;
begin
  Result := Self;
  FDataset.Filter := aValue;
end;

function TOrionDataSetFireDACMemTable.Filtered(aValue: boolean): iDataSet;
begin
  Result := Self;
  FDataset.Filtered := aValue;
end;

function TOrionDataSetFireDACMemTable.First: iDataSet;
begin
  Result := Self;
  FDataset.First;
end;

function TOrionDataSetFireDACMemTable.Insert: iDataSet;
begin
  Result := Self;
  FDataset.Insert;
end;

function TOrionDataSetFireDACMemTable.Last: iDataSet;
begin
  Result := Self;
  FDataset.Last;
end;

function TOrionDataSetFireDACMemTable.Locate(const aKeyFields: string;
  const aKeyValues: Variant; aOptions: TLocateOptions): Boolean;
begin
  Result := FDataset.Locate(aKeyFields, aKeyValues, aOptions);
end;

procedure TOrionDataSetFireDACMemTable.MelhorarDesempenho;
begin
  FDataset.LogChanges := False;
  FDataset.FetchOptions.RecsMax := 300000;
  FDataset.ResourceOptions.SilentMode := True;
  FDataset.UpdateOptions.LockMode := lmNone;
  FDataset.UpdateOptions.LockPoint := lpDeferred;
  FDataset.UpdateOptions.FetchGeneratorsPoint := gpImmediate;
end;

function TOrionDataSetFireDACMemTable.Name(aValue: string): IDataSet;
begin
  Result := Self;
  FDataset.Name := aValue;
end;

function TOrionDataSetFireDACMemTable.Name: string;
begin
  Result := FDataset.Name;
end;

class function TOrionDataSetFireDACMemTable.New: iDataSet;
begin
  Result := Self.Create;
end;

function TOrionDataSetFireDACMemTable.Next: iDataSet;
begin
  Result := Self;
  FDataset.Next;
end;

function TOrionDataSetFireDACMemTable.Open: iDataSet;
begin
  Result := Self;
  MelhorarDesempenho;
  FDataset.Open;
end;

function TOrionDataSetFireDACMemTable.Post: iDataSet;
begin
  Result := Self;
  FDataset.Post;
end;

function TOrionDataSetFireDACMemTable.Prior: iDataSet;
begin
  Result := Self;
  FDataset.Prior;
end;

function TOrionDataSetFireDACMemTable.RecNo: integer;
begin
  Result := FDataset.RecNo;
end;

function TOrionDataSetFireDACMemTable.RecordCount: integer;
begin
  Result := FDataset.RecordCount;
end;

function TOrionDataSetFireDACMemTable.SQL(aValue: string): iDataSet;
begin
  Result := Self;
  FDataset.CommandText := aValue;
end;

end.
