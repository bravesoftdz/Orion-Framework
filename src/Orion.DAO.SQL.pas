unit Orion.DAO.SQL;

interface

uses
  Orion.DAO.Types;

type
  TOrionDAOSQLBuilder = class
  private
    FParams : TOrionParamsList;
    function InternalBuildSQL<T:class, constructor>(aWhere : string = '') : string;
  public
    function BuildSQL<T:class, constructor> : string; overload;
    function BuildSQL<T:class, constructor>(aWhere : string) : string; overload;
    constructor Create(aDAOParams : TOrionParamsList);
    destructor Destroy; override;
  end;
implementation

{ TOrionDAOSQLBuilder<T> }

uses
  Orion.Data.Rtti,
  System.SysUtils,
  System.Variants;

function TOrionDAOSQLBuilder.BuildSQL<T>: string;
begin
  Result := InternalBuildSQL<T>;
end;

function TOrionDAOSQLBuilder.InternalBuildSQL<T>(aWhere : string = '') : string;
var
  FirstRegister : Boolean;
  Key: string;
begin
  Result := 'select ' + TOrionDataRtti<T>.New(nil).GetFieldsNames(T);
  Result := Result + ' from ' + TOrionDataRtti<T>.New(nil).GetTableName(T);
  Result := Result + ' ' + TOrionDataRtti<T>.New(nil).GetJoins(T);

  if aWhere <> '' then
  begin
    Result := Result + ' where ' + aWhere;
    Exit;
  end;

  FirstRegister := True;
  for Key in FParams.Keys do
  begin
    if FirstRegister then
    begin
      Result := Result + ' where ' + Key + ReturnExpressionString(FParams.Items[Key].Expression) + QuotedStr(VarToStr(FParams.Items[Key].Value));
      FirstRegister := False;
      Continue;
    end;
    Result := Result + ' and ' + Key + ReturnExpressionString(FParams.Items[Key].Expression) + QuotedStr(VarToStr(FParams.Items[Key].Value));
  end;
end;

function TOrionDAOSQLBuilder.BuildSQL<T>(aWhere: string): string;
begin
  Result := InternalBuildSQL<T>(aWhere);
end;

constructor TOrionDAOSQLBuilder.Create(aDAOParams : TOrionParamsList);
begin
  FParams := aDAOParams;
end;

destructor TOrionDAOSQLBuilder.Destroy;
begin

  inherited;
end;

end.
