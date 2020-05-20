unit Orion.Data.Rtti;

interface

uses
//  Orion.Interfaces,
  Orion.Data.Interfaces,

  System.JSON,
  System.Classes,
  System.Generics.Collections;
type
  TOrionDataRtti<T:class, constructor> = class(TInterfacedObject, iOrionDataRtti<T>)
  private
    FInstance :T;
    function RetornarNomeCampoSemNomeTabela(aValue : string) : string;
  public
    constructor Create(aInstance :T);
    destructor Destroy; override;
    class function New(aInstance :T) :iOrionDataRtti<T>;

    function GetTableName(aClass :TClass) : string;
    function GetFieldsNames(aClass :TClass) : string;
    function GetTableFieldsNames(aClass :TClass) : string;
    function GetJoins(aClass :TClass) : string;
    function CriarCamposDataSet(var aDataSet :iDataSet) : iOrionDataRtti<T>;
    function SetarConfiguracoesCampos(var aDataSet :iDataSet) : iOrionDataRtti<T>;
    function ObjectToDataSet(aClass :T; aDataSet :iDataSet) : iOrionDataRtti<T>;
    function ObjectToDataSetEquals(aObject :T; aDataSet :iDataSet) : iOrionDataRtti<T>;
    function ObjectListToDataSet(aList :TObjectList<T>; aDataSet :iDataSet) : iOrionDataRtti<T>;
    function DataSetSelectedRecordToClass(aDataSet :iDataSet; aClass :T) : iOrionDataRtti<T>;
    function DataSetSelectedRecordToObject(aDataSet : iDataSet; aClass : T) : iOrionDataRtti<T>;
    function DataSetToClassList(aDataSet :iDataSet; aList: TObjectList<T>) : iOrionDataRtti<T>;
    function GetPrimaryKeys(aClass :T) : TDictionary<string, Variant>;
    function GetKeysFieldValues(aClass :T; aKeyFieldNames : array of string) : TDictionary<string, Variant>;
    function GetFieldsOnJoins : Tlist<string>;
  end;
implementation

uses
  System.Rtti,
  System.TypInfo,
  System.StrUtils,
  System.SysUtils,

  Orion.Attributes,

  Data.DB;

{ TOrionDataRtti }

function TOrionDataRtti<T>.ObjectListToDataSet(aList: TObjectList<T>; aDataSet: iDataSet): iOrionDataRtti<T>;
var
  LObject: T;
  I :integer;
begin
  if not Assigned(aDataSet) then
    Exit;

  if not Assigned(aList) then
    Exit;

  try
    aDataSet.Close;
    aDataSet.CreateDataSet;
    SetarConfiguracoesCampos(aDataSet);

    aDataSet.DisableControls;
//    for LObject in aList.List do
    for I := 0 to Pred(aList.Count) do
    begin
      LObject := aList[I];

      aDataSet.Append;
      ObjectToDataSetEquals(LObject, aDataSet);
      aDataSet.Post;
    end;
  finally
    aDataSet.EnableControls;
  end;
end;

function TOrionDataRtti<T>.ObjectToDataSet(aClass: T; aDataSet: iDataSet): iOrionDataRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
  LInfo :pTypeInfo;
  LIsAutoInc, lUpdateField :Boolean;
  lStream : TStream;
  Flag: TProviderFlag;
  lIgnoreCRUD : boolean;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LInfo    := System.TypeInfo(T);
    LTypRtti := LCtxRtti.GetType(LInfo);

    for LpropRtti in LTypRtti.GetProperties do
    begin
      LNomeCampo  := '';
      LIsAutoInc := False;
      lIgnoreCRUD := False;

      for LAttribRtti in LpropRtti.GetAttributes do
      begin
        if (LAttribRtti is Campo) then
          LNomeCampo := RetornarNomeCampoSemNomeTabela(Campo(LAttribRtti).Nome);

        if (LAttribRtti is AutoInc) then
          LIsAutoInc := True;

        if (LAttribRtti) is IgnorarCRUD then
          lIgnoreCRUD := True;
      end;

      if LIsAutoInc then
      begin
        aDataSet.Fields.FieldByName(LNomeCampo).Required := False;
        aDataSet.Fields.FieldByName(LNomeCampo).AutoGenerateValue := arAutoInc;
        Continue;
      end;

      if lIgnoreCRUD then
        Continue;

      if LNomeCampo <> '' then
      begin
        lUpdateField := False;
        for Flag in aDataSet.Fields.FieldByName(LNomeCampo).ProviderFlags do
        begin
          if Flag = pfInUpdate then
            lUpdateField := True;
        end;

        if lUpdateField then
        begin
          case LpropRtti.PropertyType.TypeKind of
            tkUnknown: aDataSet.Fields.FieldByName(LNomeCampo).AsVariant  := LpropRtti.GetValue(Pointer(aClass)).AsVariant;
            tkString:  aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(Pointer(aClass)).AsString;
            tkChar:    aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(Pointer(aClass)).AsString;
            tkWChar:   aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(Pointer(aClass)).AsString;
            tkLString: aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(Pointer(aClass)).AsString;
            tkWString: aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(Pointer(aClass)).AsString;
            tkUString: aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(Pointer(aClass)).AsString;
            tkVariant: aDataSet.Fields.FieldByName(LNomeCampo).AsVariant  := LpropRtti.GetValue(Pointer(aClass)).AsVariant;
            tkFloat:   aDataSet.Fields.FieldByName(LNomeCampo).AsExtended := LpropRtti.GetValue(Pointer(aClass)).AsExtended;
            tkInteger: aDataSet.Fields.FieldByName(LNomeCampo).AsInteger  := LpropRtti.GetValue(Pointer(aClass)).AsInteger;
            tkClass :
              begin
                if (LpropRtti.GetValue(Pointer(aClass)).AsObject is TStream) then
                begin
                  (LpropRtti.GetValue(Pointer(aClass)).AsObject as TStream).Position := 0;
                  TBlobField(aDataSet.Fields.FieldByName(LpropRtti.Name)).LoadFromStream(TStream(LpropRtti.GetValue(Pointer(aClass)).AsObject));
                end;
              end;
          end;
        end;

      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.ObjectToDataSetEquals(aObject :T; aDataSet: iDataSet): iOrionDataRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LInfo :pTypeInfo;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LInfo    := System.TypeInfo(T);
    LTypRtti := LCtxRtti.GetType(LInfo);

    for LpropRtti in LTypRtti.GetProperties do
    begin
      if aDataSet.Fields.FindField(LpropRtti.Name) <> nil then
      begin
        case LpropRtti.PropertyType.TypeKind of
          tkUnknown: aDataSet.Fields.FieldByName(LpropRtti.Name).AsVariant  := LpropRtti.GetValue(Pointer(aObject)).AsVariant;
          tkString:  aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(aObject)).AsString;
          tkChar:    aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(aObject)).AsString;
          tkWChar:   aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(aObject)).AsString;
          tkLString: aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(aObject)).AsString;
          tkWString: aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(aObject)).AsString;
          tkUString: aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(aObject)).AsString;
          tkVariant: aDataSet.Fields.FieldByName(LpropRtti.Name).AsVariant  := LpropRtti.GetValue(Pointer(aObject)).AsVariant;
          tkFloat:   aDataSet.Fields.FieldByName(LpropRtti.Name).AsExtended := LpropRtti.GetValue(Pointer(aObject)).AsExtended;
          tkInteger: aDataSet.Fields.FieldByName(LpropRtti.Name).AsInteger  := LpropRtti.GetValue(Pointer(aObject)).AsInteger;
        end;
      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.RetornarNomeCampoSemNomeTabela(aValue: string): string;
begin
  if aValue.Contains('.') then
  begin
    Result := SplitString(aValue, '.')[1];
    Exit;
  end;

  Result := aValue;
end;

constructor TOrionDataRtti<T>.Create(aInstance :T);
begin
  FInstance := aInstance;
end;

function TOrionDataRtti<T>.CriarCamposDataSet(var aDataSet :iDataSet): iOrionDataRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
  LDisplayLabel :string;
  LTipoCampo :TTipoCampo;
  LTamanhoCampo :integer;
  LDisplayWidth :integer;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    aDataSet.FieldDefs.Clear;
    for LpropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LpropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
        begin
          LNomeCampo    := LpropRtti.Name;
          LTipoCampo    := Campo(LAttribRtti).TipoCampo;
          LTamanhoCampo := Campo(LAttribRtti).Tamanho;
          LDisplayWidth := Campo(LAttribRtti).DisplayWidth;
          Break;
        end;
      end;
      case LTipoCampo of
        tcString:   aDataSet.FieldDefs.Add( UpperCase(LNomeCampo), ftString,   LTamanhoCampo );
        tcInteger:  aDataSet.FieldDefs.Add( UpperCase(LNomeCampo), ftInteger,  LTamanhoCampo );
        tcFloat:    aDataSet.FieldDefs.Add( UpperCase(LNomeCampo), ftFloat,    LTamanhoCampo );
        tcDateTime: aDataSet.FieldDefs.Add( UpperCase(LNomeCampo), ftDateTime, LTamanhoCampo );
        tcBoolean:  aDataSet.FieldDefs.Add( UpperCase(LNomeCampo), ftBoolean,  LTamanhoCampo );
        tcBlob:     aDataSet.FieldDefs.Add( UpperCase(LNomeCampo), ftBlob,     LTamanhoCampo );
      end;
    end;

    aDataSet.Close;
    aDataSet.CreateDataSet;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.DataSetSelectedRecordToClass(aDataSet: iDataSet; aClass: T): iOrionDataRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
  LValue :TValue;
  LField: TField;
begin
  if not Assigned(aDataSet) then
    Exit;

  if not Assigned(aClass) then
    Exit;

  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(aClass.ClassInfo);

    for LField in aDataSet.Fields do
    begin
      for LPropRtti in LTypRtti.GetProperties do
      begin
        for LAttribRtti in LpropRtti.GetAttributes do
        begin
          if LAttribRtti is Campo then
          begin
            LNomeCampo := Campo(LAttribRtti).Nome;
            Break;
          end;
        end;
        if LField.FieldName = UpperCase(LpropRtti.Name) then
        begin
          case LpropRtti.PropertyType.TypeKind of
            tkInteger: LValue := LField.AsInteger;
            tkChar:    LValue := LField.AsWideString;
            tkFloat:   LValue := LField.AsFloat;
            tkString:  LValue := LField.AsWideString;
            tkWChar:   LValue := LField.AsWideString;
            tkLString: LValue := LField.AsWideString;
            tkWString: LValue := LField.AsWideString;
  //          tkVariant: LValue := LField.AsVariant;
            tkInt64:   LValue := LField.AsLargeInt;
            tkUString: LValue := LField.AsWideString;
          end;
          LpropRtti.SetValue(Pointer(aClass), LValue);
        end;
      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.DataSetSelectedRecordToObject(aDataSet: iDataSet;
  aClass: T): iOrionDataRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
  LValue :TValue;
  LField: TField;
  lStream : TMemoryStream;
  lIgnorarCRUD : boolean;
begin
  if not Assigned(aDataSet) then
    Exit;

  if not Assigned(aClass) then
    Exit;

  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(aClass.ClassInfo);

    for LField in aDataSet.Fields do
    begin
      for LPropRtti in LTypRtti.GetProperties do
      begin
        lIgnorarCRUD := False;
        for LAttribRtti in LpropRtti.GetAttributes do
        begin
          if LAttribRtti is IgnorarCRUD then
            lIgnorarCRUD := True;

          if LAttribRtti is Campo then
          begin
            LNomeCampo := RetornarNomeCampoSemNomeTabela(Campo(LAttribRtti).Nome);
            Break;
          end;
        end;

//        if lIgnorarCRUD then
//          Continue;

        if LField.FieldName = LNomeCampo then
        begin
          case LpropRtti.PropertyType.TypeKind of
            tkInteger: LValue := LField.AsInteger;
            tkChar:    LValue := LField.AsWideString;
            tkFloat:   LValue := LField.AsFloat;
            tkString:  LValue := LField.AsWideString;
            tkWChar:   LValue := LField.AsWideString;
            tkLString: LValue := LField.AsWideString;
            tkWString: LValue := LField.AsWideString;
  //          tkVariant: LValue := LField.AsVariant;
            tkInt64:   LValue := LField.AsLargeInt;
            tkUString: LValue := LField.AsWideString;
            tkClass :
            begin
              lStream := TMemoryStream.Create;
              try
                TBlobField(LField).SaveToStream(lStream);
                LValue := lStream;
                LpropRtti.SetValue(Pointer(aClass), LValue);
                Continue;
              finally
                lStream.Clear;
                lStream.DisposeOf;
              end;
            end;
          end;
          LpropRtti.SetValue(Pointer(aClass), LValue);
        end;
      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.DataSetToClassList(aDataSet: iDataSet; aList: TObjectList<T>): iOrionDataRtti<T>;
var
  LObject :T;
begin
  if not Assigned(aDataSet) then
    Exit;

  if not Assigned(aList) then
    Exit;

  aDataSet.First;
  while not aDataSet.EOF do
  begin
    LObject := T.Create;
    DataSetSelectedRecordToClass(aDataSet, LObject);
    aList.Add(LObject);
    aDataSet.Next;
  end;
end;

destructor TOrionDataRtti<T>.Destroy;
begin

  inherited;
end;

class function TOrionDataRtti<T>.New(aInstance :T): iOrionDataRtti<T>;
begin
  Result := Self.Create(aInstance);
end;

function TOrionDataRtti<T>.SetarConfiguracoesCampos(var aDataSet: iDataSet): iOrionDataRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LDisplayWidth :integer;
  LDisplayLabel :string;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    for LpropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LpropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
        begin
          LDisplayWidth := Campo(LAttribRtti).DisplayWidth;
          LDisplayLabel := Campo(LAttribRtti).DisplayLabel;
          Break;
        end;

      end;
      aDataSet.Fields.FieldByName(LpropRtti.Name).DisplayWidth := LDisplayWidth;
      aDataSet.Fields.FieldByName(LpropRtti.Name).DisplayLabel := LDisplayLabel;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.GetTableFieldsNames(aClass: TClass): string;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
  lTableName : string;

begin
  Result := '';

  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(aClass.ClassInfo);
    lTableName := GetTableName(aClass);
    for LPropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LPropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
          LNomeCampo := lTableName + '.' + Campo(LAttribRtti).Nome;

      end;
      Result := Result + LNomeCampo+', ';
    end;
    Result := Copy(Result, 0, Length(Result) - 2) + ' ';
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.GetTableName(aClass :TClass): string;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(aClass.ClassInfo);
    for LAttribRtti in LTypRtti.GetAttributes do
    begin
      if LAttribRtti is Tabela then
      begin
        Result := Tabela(LAttribRtti).Nome;
        Break
      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.GetFieldsNames(aClass :TClass): string;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
  lignorarCRUD : boolean;
begin
  Result := '';

  LCtxRtti := TRttiContext.Create;
  try
//    LTypRtti := LCtxRtti.GetType(aClass.ClassInfo);
    LTypRtti := LCtxRtti.GetType(T);
    for LPropRtti in LTypRtti.GetProperties do
    begin
      lignorarCRUD := False;
      for LAttribRtti in LPropRtti.GetAttributes do
      begin
        if LAttribRtti is IgnorarCRUD then
          lignorarCRUD := True;

        if LAttribRtti is Campo then
        begin
          LNomeCampo := Campo(LAttribRtti).Nome;
          Break
        end;
      end;

      if not (lignorarCRUD) then
        Result := Result + LNomeCampo + ', ';
    end;
    Result := Copy(Result, 0, Length(Result) - 2) + ' ';
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.GetFieldsOnJoins: Tlist<string>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo  : string;
  isJoinField : Boolean;
begin
  Result      := TList<string>.Create;
  LCtxRtti    := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    for LPropRtti in LTypRtti.GetProperties do
    begin
      isJoinField := False;
      for LAttribRtti in LPropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
          LNomeCampo := RetornarNomeCampoSemNomeTabela(Campo(LAttribRtti).Nome);

        if LAttribRtti is Join then
          isJoinField := True;
      end;

      if isJoinField then
      begin
        if not Result.Contains(LNomeCampo) then
          Result.Add(LNomeCampo)
      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionDataRtti<T>.GetJoins(aClass :TClass): string;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LListaJoins :TDictionary<string, string>;
  Key: string;
begin
  Result      := '';
  LCtxRtti    := TRttiContext.Create;
  LListaJoins := TDictionary<string, string>.Create;
  try
    LTypRtti := LCtxRtti.GetType(aClass.ClassInfo);
    for LPropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LPropRtti.GetAttributes do
        if LAttribRtti is Join then
        begin
          LListaJoins.Add(Join(LAttribRtti).TableName, Join(LAttribRtti).Join);
          Break;
        end;
    end;

    if LListaJoins.Count > 0 then
    begin
      for Key in LListaJoins.Keys do
        Result := Result + LListaJoins[Key] + ' '
    end;

  finally
    LCtxRtti.Free;
    FreeAndNil(LListaJoins);
  end;
end;

function TOrionDataRtti<T>.GetKeysFieldValues(aClass: T; aKeyFieldNames : array of string): TDictionary<string, Variant>;
var
  LCtx :TRttiContext;
  LType :TRttiType;
  LProp :TRttiProperty;
  LAttrib :TCustomAttribute;
  LNomeCampo :string;
  Passou :Boolean;
  I: Integer;
begin
  LCtx := TRttiContext.Create;
  Result := TDictionary<string, Variant>.Create;
  try
    LType := LCtx.GetType(AClass.ClassInfo);
    for LProp in LType.GetProperties do
    begin
      LNomeCampo := '';
      Passou     := False;
      for LAttrib in LProp.GetAttributes do
      begin
        if (LAttrib is Campo) then
          LNomeCampo := RetornarNomeCampoSemNomeTabela(Campo(LAttrib).Nome);

        if LNomeCampo <> '' then
        begin
          for I := 0 to Pred(Length(aKeyFieldNames)) do
          begin
            if LNomeCampo = aKeyFieldNames[I] then
              Result.Add(LNomeCampo, LProp.GetValue(Pointer(aClass)).AsVariant);
          end;
        end;
      end;
    end;
  finally
    LCtx.Free;
  end;
end;

function TOrionDataRtti<T>.GetPrimaryKeys(aClass: T): TDictionary<string, Variant>;
var
  LCtx :TRttiContext;
  LType :TRttiType;
  LProp :TRttiProperty;
  LAttrib :TCustomAttribute;
  LNomeCampo :string;
  Passou :Boolean;
begin
  LCtx := TRttiContext.Create;
  Result := TDictionary<string, Variant>.Create;
  try
    LType := LCtx.GetType(AClass.ClassInfo);
    for LProp in LType.GetProperties do
    begin
      LNomeCampo := '';
      Passou     := False;
      for LAttrib in LProp.GetAttributes do
      begin
        if (LAttrib is Campo) then
          LNomeCampo := RetornarNomeCampoSemNomeTabela(Campo(LAttrib).Nome);

        if (LAttrib is PK) then
          Passou := True;
      end;
      if Passou then
        Result.Add(LNomeCampo, LProp.GetValue(Pointer(aClass)).AsVariant);
    end;
  finally
    LCtx.Free;
  end;
end;

end.
