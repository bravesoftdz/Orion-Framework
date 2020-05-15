unit Orion.Data.Interfaces;

interface

uses
  System.Classes, Data.DB, System.Generics.Collections;

type
  TTipoBanco = (tpFirebird30, tpFirebird25, tpMSSQL);
  TAfterScroll = procedure (Sender : TDataset) of object;
  iConexaoParametros = interface;

  iConexao = interface
    ['{6A05F816-26E2-4D8F-8DB0-627D9C60C8AF}']
    function Parametros :iConexaoParametros;
    function Conexao :iConexao;
    function Conectar :iConexao;
    function GetConnection :TComponent;
  end;

  iConexaoParametros = interface
    ['{135124B2-D8A9-4035-8CFB-694663B9373E}']
    function CaminhoBanco(aValue :string) :iConexaoParametros;
    function UserName(aValue :string) :iConexaoParametros;
    function Senha(aValue :string) :iConexaoParametros;
    function Porta(aValue :integer) :iConexaoParametros;
    function Server(aValue :string) :iConexaoParametros;
    function OSAuth : iConexaoParametros;
    function &EndParametros:iConexao;
  end;

  iDataSet = interface
    ['{8ECEC717-C90C-4C22-BDB4-4B48A128864C}']
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
    function RecordCount :integer;
    function Locate(const aKeyFields: string; const aKeyValues: Variant; aOptions: TLocateOptions): Boolean;
    function DataSource(aValue :TDataSource) :iDataSet;
    function Fields :TFields;
    function FieldDefs : TFieldDefs;
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

  iOrionDataRtti<T:class> = interface
    ['{A683CEA4-9D4B-4165-8DBC-6927D6A23FAB}']
    function GetTableName(aClass :TClass) : string;
    function GetFieldsNames(aClass :TClass) : string;
    function GetTableFieldsNames(aClass :TClass) : string;
    function GetJoins(aClass :TClass) : string;
    function GetPrimaryKeys(aClass :T) : TDictionary<string, Variant>;
    function CriarCamposDataSet(var aDataSet :iDataSet) : iOrionDataRtti<T>;
    function SetarConfiguracoesCampos(var aDataSet :iDataSet) : iOrionDataRtti<T>;
    function ObjectToDataSet(aClass :T; aDataSet :iDataSet) : iOrionDataRtti<T>;
    function ObjectToDataSetEquals(aObject :T; aDataSet :iDataSet) : iOrionDataRtti<T>;
    function ObjectListToDataSet(aList :TObjectList<T>; aDataSet :iDataSet) : iOrionDataRtti<T>;
    function DataSetSelectedRecordToClass(aDataSet :iDataSet; aClass :T) : iOrionDataRtti<T>;
    function DataSetSelectedRecordToObject(aDataSet : iDataSet; aClass : T) : iOrionDataRtti<T>;
    function GetFieldsOnJoins : Tlist<string>;
    function GetKeysFieldValues(aClass :T; aKeyFieldNames : array of string) : TDictionary<string, Variant>;
  end;

  iFactoryFireDAC = interface
    ['{A0879CD8-1194-4E0D-82B7-18F36FAD4F4F}']
    function Conexao(aTipoBanco : TTipoBanco) :iConexao;
    function Query(aConexao :iConexao) :iDataSet;
    function MemTable :iDataSet;
  end;

implementation

end.
