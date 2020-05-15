unit Orion.DAO.CORE;

interface

uses
  Orion.DAO.Types,
  Orion.Data.Interfaces,
  System.Generics.Collections,
  Orion.DAO.SQL, Data.DB, System.JSON;

type

  TOrionDAORequest = class;
  TOrionDAOResponse = class;
  TOrionDAOOperations = class;
  TOrionDAOChild = class;

  TOrionDAOCore = class
  private
    FRequest: TOrionDAORequest;
    FResponse: TOrionDAOResponse;
    FSQL : TOrionDAOSQLBuilder;
    FDataSet : iDataSet;
    FOperations: TOrionDAOOperations;
    FChild : TOrionDAOChild;
  public
    constructor Create(aDataSet : iDataSet);
    destructor Destroy; override;

    property Child: TOrionDAOChild read FChild write FChild;
    property Operations: TOrionDAOOperations read FOperations write FOperations;
    property Request: TOrionDAORequest read FRequest write FRequest;
    property Response: TOrionDAOResponse read FResponse write FResponse;
  end;

  TOrionDAOSQL = class;

  TOrionDAORequest = class
  private
    FParams : TOrionParamsList;
    FSQL : TOrionDAOSQL;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddParam(aFieldName : string; aExpression : TOrionExpressions; aValue : Variant);
    function Params : TOrionParamsList;
    function SQL : TOrionDAOSQL;
  end;

  TOrionDAOSQL = class
  private
    FFields : TList<string>;
    FFrom : string;
    FJoins : TList<string>;
    FWhere : TList<string>;
    FGroupBy : TList<string>;
    FOrderBy : string;
    function ReturnListAsString(aList : TList<string>) : string;
  public
    constructor Create;
    destructor Destroy; override;
    function Fields(aValue : string) : TOrionDAOSQL; overload;
    function Fields(aTableName, aFieldName : string) : TOrionDAOSQL; overload;
    function Fields : string; overload;
    function From(aValue : string) : TOrionDAOSQL; overload;
    function From : string; overload;
    function Joins(aValue : string) : TOrionDAOSQL; overload;
    function Joins : string; overload;
    function Where(aValue : string) : TOrionDAOSQL; overload;
    function Where : string; overload;
    function GroupBy(aValue : string) : TOrionDAOSQL; overload;
    function GroupBy : string; overload;
    function OrderBy(aValue : string) : TOrionDAOSQL; overload;
    function OrderBy : string; overload;
    function isSQL : Boolean;
    function BuildSQL : string;
  end;

  TOrionDAOOperations = class
  private
    FRequest : TOrionDAORequest;
    FResponse : TOrionDAOResponse;
    FSQLBuilder : TOrionDAOSQLBuilder;
    FListaRecNoDataSet :TDictionary<integer, Boolean>;

    procedure IgnoreJoinFieldsToUpdate<T:class, constructor>;
    procedure InternalRefreshObject<T:class, constructor>(aValue : T);
    procedure InternalInsert<T:class, constructor>(aValue : T);
    procedure InternalUpdate<T:class, constructor>(aValue : T);
    procedure InternalDelete<T:class, constructor>(aValue : T);
    procedure InternalApplyUpdates;
    procedure PrepareDataSet<T:class, constructor>;
    procedure PrepareListOfPossibleExclusions;
    procedure DoExclusions;
    procedure FindRegister<T:class, constructor>(aValue: T); overload;
    procedure FindRegister<T:class, constructor>(aValue: T; aKeyFieldNames : array of string); overload;
  public
    constructor Create(aRequest : TOrionDAORequest; aResponse : TOrionDAOResponse; aSQLBuilder : TOrionDAOSQLBuilder);
    destructor Destroy; override;

    procedure Find<T:class, constructor>;
    procedure Insert<T:class, constructor>(aValue : T); overload;
    procedure Insert<T:class, constructor>(aValue : TObjectList<T>); overload;
    procedure Update<T:class, constructor>(aValue : T); overload;
    procedure Update<T:class, constructor>(aValue : TObjectList<T>; aKeyFieldNames : array of string); overload;
    procedure Delete<T:class, constructor>(aValue : T);
  end;

  TOrionDAOResponse = class
  private
    FDataset : iDataSet;
  public
    constructor Create(aDataSet : iDataSet);
    destructor Destroy; override;
    function DataSet : iDataSet;
    function AsObject<T:class, constructor> : T;
    function AsObjectList<T:class, constructor> : TObjectList<T>;
  end;

  TOrionDAOChild = class
  private
    FOwns : Boolean;
    FOrionDAOCore : TOrionDAOCore;
  public
    constructor Create;
    destructor Destroy; override;

    procedure &Set(aValue : TOrionDAOCore; aOwns : Boolean = True);
    function Item : TOrionDAOCore;
  end;

implementation

{ TOrionDAOCore }

uses
  Orion.Data.Rtti,
  System.SysUtils,
  System.Variants;

constructor TOrionDAOCore.Create(aDataSet : iDataSet);
begin
  FRequest           := TOrionDAORequest.Create;
  FResponse          := TOrionDAOResponse.Create(aDataSet);
  FDataSet           := aDataSet.Clone;
  FSQL               := TOrionDAOSQLBuilder.Create(FRequest.Params);
  FOperations        := TOrionDAOOperations.Create(FRequest, FResponse, FSQL);
  FChild             := TOrionDAOChild.Create;
end;

destructor TOrionDAOCore.Destroy;
begin
  FRequest.DisposeOf;
  FResponse.DisposeOf;
  FSQL.DisposeOf;
  FOperations.DisposeOf;
  FChild.DisposeOf;
  inherited;
end;

{ TOrionDAORequest }

procedure TOrionDAORequest.AddParam(aFieldName: string; aExpression: TOrionExpressions; aValue: Variant);
var
  lParam : TOrionParamValue;
begin
  lParam.Value      := aValue;
  lParam.Expression := aExpression;
  FParams.AddOrSetValue(aFieldName, lParam);
end;

constructor TOrionDAORequest.Create;
begin
  FParams := TOrionParamsList.Create;
  FSQL    := TOrionDAOSQL.Create;
end;

destructor TOrionDAORequest.Destroy;
begin
  FParams.DisposeOf;
  FSQL.DisposeOf;
  inherited;
end;

function TOrionDAORequest.Params: TOrionParamsList;
begin
  Result := FParams;
end;

function TOrionDAORequest.SQL: TOrionDAOSQL;
begin
  Result := FSQL;
end;

{ TOrionDAOResponse }

function TOrionDAOResponse.AsObject<T>: T;
begin
  Result := T.Create;
  TOrionDataRtti<T>.New(nil).DataSetSelectedRecordToObject(FDataset, Result);
end;

function TOrionDAOResponse.AsObjectList<T>: TObjectList<T>;
var
  lObject : T;
begin
  Result := TObjectList<T>.Create;
  FDataset.First;
  while not FDataset.EOF do
  begin
    lObject := T.Create;
    TOrionDataRtti<T>.New(nil).DataSetSelectedRecordToObject(FDataset, lObject);
    Result.Add(lObject);
    FDataset.Next;
  end;
end;

constructor TOrionDAOResponse.Create(aDataSet: iDataSet);
begin
  FDataset    := aDataset;
end;

function TOrionDAOResponse.DataSet: iDataSet;
begin
  Result := FDataset;
end;

destructor TOrionDAOResponse.Destroy;
begin

  inherited;
end;

{ TOrionDAOSQL }

function TOrionDAOSQL.BuildSQL: string;
begin
  Result := '';
  Result := 'SELECT ' + ReturnListAsString(FFields);
  Result := Copy(Result, 0, Length(Result) - 2) + ' ';
  Result := Result + ' FROM ' + FFrom;
  Result := Result + ' ' + ReturnListAsString(FJoins);
  if FWhere.Count > 0 then
    Result := Result + ' WHERE ' + ReturnListAsString(FWhere);

  if FGroupBy.Count > 0 then
    Result := Result + ' GROUP BY ' + ReturnListAsString(FGroupBy);

  if FOrderBy.Trim <> '' then
    Result := Result + ' ORDER BY ' + FOrderBy;
end;

constructor TOrionDAOSQL.Create;
begin
  FFields  := TList<string>.Create;
  FJoins   := TList<string>.Create;
  FWhere   := TList<string>.Create;
  FGroupBy := TList<string>.Create;
end;

destructor TOrionDAOSQL.Destroy;
begin
  FFields.DisposeOf;
  FJoins.DisposeOf;
  FWhere.DisposeOf;
  FGroupBy.DisposeOf;
  inherited;
end;

function TOrionDAOSQL.Fields(aValue: string): TOrionDAOSQL;
begin
  Result := Self;
  if not aValue.Contains(',') then
    aValue := aValue + ', ';

  if not FFields.Contains(aValue) then
  begin

    FFields.Add(aValue);
  end;
end;

function TOrionDAOSQL.Fields: string;
begin
  Result := ReturnListAsString(FJoins);
end;

function TOrionDAOSQL.From(aValue: string): TOrionDAOSQL;
begin
  Result := Self;
  FFrom := aValue;
end;

function TOrionDAOSQL.Fields(aTableName, aFieldName: string): TOrionDAOSQL;
var
  lField : string;
begin
  Result := Self;
  lField := aTableName + '.' + aFieldName;
  if not lField.Contains(',') then
    lField := lField + ', ';

  if not FFields.Contains(lField) then
    FFields.Add(lField);
end;

function TOrionDAOSQL.From: string;
begin
  Result := FFrom;
end;

function TOrionDAOSQL.GroupBy: string;
begin
  Result := ReturnListAsString(FGroupBy);
end;

function TOrionDAOSQL.isSQL: Boolean;
begin
  Result := FFields.Count > 0;
end;

function TOrionDAOSQL.Joins: string;
begin
  Result := ReturnListAsString(FJoins);
end;

function TOrionDAOSQL.Joins(aValue: string): TOrionDAOSQL;
begin
  Result := Self;
  if not FJoins.Contains(aValue) then
    FJoins.Add(aValue);
end;

function TOrionDAOSQL.GroupBy(aValue: string): TOrionDAOSQL;
begin
  Result := Self;
  if not FGroupBy.Contains(aValue) then
    FGroupBy.Add(aValue);
end;

function TOrionDAOSQL.OrderBy: string;
begin
  Result := FOrderBy;
end;

function TOrionDAOSQL.ReturnListAsString(aList: TList<string>): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(aList.Count) do
    Result := Result + ' ' + aList[I];
end;

function TOrionDAOSQL.OrderBy(aValue: string): TOrionDAOSQL;
begin
  Result := Self;
  FOrderBy := aValue;
end;

function TOrionDAOSQL.Where(aValue: string): TOrionDAOSQL;
begin
  Result := Self;
  if not FWhere.Contains(aValue) then
    FWhere.Add(aValue);
end;

function TOrionDAOSQL.Where: string;
begin
  Result := ReturnListAsString(FWhere);
end;

{ TOrionDAOOperations }

constructor TOrionDAOOperations.Create(aRequest : TOrionDAORequest; aResponse : TOrionDAOResponse; aSQLBuilder : TOrionDAOSQLBuilder);
begin
  FRequest           := aRequest;
  FResponse          := aResponse;
  FSQLBuilder        := aSQLBuilder;
  FListaRecNoDataSet := TDictionary<integer, Boolean>.Create;
end;

procedure TOrionDAOOperations.Delete<T>(aValue: T);
begin
  FindRegister(aValue);
  InternalDelete(aValue);
  InternalApplyUpdates;
end;

destructor TOrionDAOOperations.Destroy;
begin
  FListaRecNoDataSet.DisposeOf;
  inherited;
end;

procedure TOrionDAOOperations.DoExclusions;
var
  Key :integer;
begin
  for Key in FListaRecNoDataSet.Keys do
  begin
    if FListaRecNoDataSet[Key] = False then
    begin
      FResponse.DataSet.First;
      while not FResponse.DataSet.Eof do
      begin
        if Key = FResponse.DataSet.RecNo then
          FResponse.DataSet.Delete;

        FResponse.DataSet.Next;
      end;
    end;
  end;
end;

procedure TOrionDAOOperations.Find<T>;
begin
  if FRequest.SQL.isSQL then
  begin
    FResponse.DataSet.Close.SQL(FRequest.SQL.BuildSQL).Open;
    Exit;
  end;

  FResponse.DataSet.Close.SQL(FSQLBuilder.BuildSQL<T>).Open;
end;

procedure TOrionDAOOperations.FindRegister<T>(aValue: T; aKeyFieldNames: array of string);
var
  lPKFieldsList: System.Generics.Collections.TDictionary<string, Variant>;
  Key: string;
  lFirstReg: Boolean;
  lWhere: string;
begin
  lFirstReg     := True;
  lPKFieldsList := TOrionDataRtti<T>.New(nil).GetKeysFieldValues(aValue, aKeyFieldNames);
  try
    for Key in lPKFieldsList.Keys do
    begin
      if lFirstReg then
        lWhere := Key + ' = ' + VarToStr(lPKFieldsList[Key])
      else
        lWhere := lWhere + ' and ' + Key + ' = ' + VarToStr(lPKFieldsList[Key]);
    end;

    FResponse.DataSet.Close.SQL(FSQLBuilder.BuildSQL<T>(lWhere)).Open;
  finally
    lPKFieldsList.DisposeOf;
  end;
end;

procedure TOrionDAOOperations.FindRegister<T>(aValue: T);
var
  lPKFieldsList: System.Generics.Collections.TDictionary<string, Variant>;
  Key: string;
  lFirstReg: Boolean;
  lWhere: string;
begin
  lFirstReg     := True;
  lPKFieldsList := TOrionDataRtti<T>.New(nil).GetPrimaryKeys(aValue);
  try
    if lPKFieldsList.Count > 0 then
    begin
      for Key in lPKFieldsList.Keys do
      begin
        if lFirstReg then
          lWhere := Key + ' = ' + VarToStr(lPKFieldsList[Key])
        else
          lWhere := lWhere + ' and ' + Key + ' = ' + VarToStr(lPKFieldsList[Key]);
      end;
      FResponse.DataSet.Close.SQL(FSQLBuilder.BuildSQL<T>(lWhere)).Open;
    end;
  finally
    lPKFieldsList.DisposeOf;
  end;
end;

procedure TOrionDAOOperations.Insert<T>(aValue: T);
begin
  PrepareDataSet<T>;
  IgnoreJoinFieldsToUpdate<T>;
  InternalInsert<T>(aValue);
  InternalApplyUpdates;
  InternalRefreshObject<T>(aValue);
end;

procedure TOrionDAOOperations.IgnoreJoinFieldsToUpdate<T>;
var
  lFieldName : string;
  lFieldJoinsList : TList<string>;
begin
  try
    lFieldJoinsList := TOrionDataRtti<T>.New(nil).GetFieldsOnJoins;
    if lFieldJoinsList.Count > 0 then
    begin
      for lFieldName in lFieldJoinsList do
        FResponse.DataSet.Fields.FieldByName(lFieldName).ProviderFlags := [];
    end;
  finally
    lFieldJoinsList.DisposeOf;
  end;
end;

procedure TOrionDAOOperations.Insert<T>(aValue: TObjectList<T>);
var
  I : integer;
begin
  FResponse.DataSet.Close.SQL(FSQLBuilder.BuildSQL<T>).EmptyOpen;
  IgnoreJoinFieldsToUpdate<T>;
  for I := 0 to Pred(aValue.Count) do
  begin
    InternalInsert<T>(aValue[i]);
    InternalRefreshObject<T>(aValue[i]);
  end;

  InternalApplyUpdates;
end;

procedure TOrionDAOOperations.InternalApplyUpdates;
begin
  FResponse.DataSet.ApplyUpdates(0);
end;

procedure TOrionDAOOperations.InternalDelete<T>(aValue: T);
begin
  FResponse.DataSet.First;
  while not FResponse.DataSet.Eof do
    FResponse.DataSet.Delete;
end;

procedure TOrionDAOOperations.InternalInsert<T>(aValue: T);
begin
  FResponse.DataSet.Append;
  TOrionDataRtti<T>.New(nil).ObjectToDataSet(aValue, FResponse.DataSet);
  FResponse.DataSet.Post;
end;

procedure TOrionDAOOperations.InternalRefreshObject<T>(aValue: T);
begin
  TOrionDataRtti<T>.New(nil).DataSetSelectedRecordToObject(FResponse.DataSet, aValue);
end;

procedure TOrionDAOOperations.InternalUpdate<T>(aValue: T);
var
  CamposPK :string;
  ValoresPK :array of Variant;
  Key: string;
  LListaCamposPK :TDictionary<string, Variant>;
begin
  CamposPK := '';
  LListaCamposPK := TOrionDataRtti<T>.New(nil).GetPrimaryKeys(aValue);
  try
    for Key in LListaCamposPK.Keys do
    begin
      if CamposPK = '' then
        CamposPK := Key
      else
        CamposPK := CamposPK + ';' + Key;

      SetLength(ValoresPK, (Length(ValoresPK)+1));
      ValoresPK[Pred(Length(ValoresPK))] := LListaCamposPK[Key];
    end;

    if CamposPK = '' then
      raise  Exception.Create('Nenhuma Chave Primária foi definida na classe ' + aValue.ClassName);

    if FResponse.DataSet.Locate(CamposPK, ValoresPK, []) then
    begin
      FResponse.DataSet.Edit;
      FListaRecNoDataSet.AddOrSetValue(FResponse.DataSet.RecNo, True);
    end
    else
      FResponse.DataSet.Append;

    TOrionDataRtti<T>.New(nil).ObjectToDataSet(aValue, FResponse.DataSet);

    FResponse.DataSet.Post;
  finally
    if Assigned(LListaCamposPK) then
      FreeAndNil(LListaCamposPK);
  end;
end;

procedure TOrionDAOOperations.PrepareDataSet<T>;
begin
  FResponse.DataSet.Close.SQL(FSQLBuilder.BuildSQL<T>).EmptyOpen;
end;

procedure TOrionDAOOperations.PrepareListOfPossibleExclusions;
begin
  FResponse.DataSet.First;
  while not FResponse.DataSet.EOF do
  begin
    FListaRecNoDataSet.Add(FResponse.DataSet.RecNo, False);
    FResponse.DataSet.Next;
  end;
  FResponse.DataSet.First;
end;

procedure TOrionDAOOperations.Update<T>(aValue: T);
begin
  FindRegister(aValue);
  InternalUpdate(aValue);
  InternalApplyUpdates;
end;

procedure TOrionDAOOperations.Update<T>(aValue: TObjectList<T>; aKeyFieldNames: array of string);
var
  I: Integer;
begin
  if aValue.Count > 0 then
  begin
    FindRegister(aValue[0], aKeyFieldNames);
    PrepareListOfPossibleExclusions;
    for I := 0 to Pred(aValue.Count) do
      InternalUpdate(aValue[i]);

    DoExclusions;
    InternalApplyUpdates;
  end;
end;

{ TOrionDAOChild }

constructor TOrionDAOChild.Create;
begin

end;

destructor TOrionDAOChild.Destroy;
begin
  if FOwns then
    if Assigned(FOrionDAOCore) then
      FOrionDAOCore.DisposeOf;
  inherited;
end;

function TOrionDAOChild.Item: TOrionDAOCore;
begin
  Result := FOrionDAOCore;
end;

procedure TOrionDAOChild.&Set(aValue : TOrionDAOCore; aOwns : Boolean = True);
begin
  FOwns := aOwns;
  FOrionDAOCore := aValue;
end;

end.
