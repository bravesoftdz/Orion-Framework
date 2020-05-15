unit Orion.DAO.Types;

interface

uses
  System.Generics.Collections, System.SysUtils;

type
  TOrionExpressions = (exprAND, exprOR, exprLIKE, exprEqual, exprNonEqual);

    JsonConversionException = class(Exception)
    constructor Create;
  end;

  TOrionParamValue = record
    Value : Variant;
    Expression : TOrionExpressions;
  end;

  TOrionParamsList = TDictionary<string, TOrionParamValue>;

  function ReturnExpressionString(aExpression : TOrionExpressions) : string;

implementation

function ReturnExpressionString(aExpression : TOrionExpressions) : string;
begin
  case aExpression of
    exprAND      : Result := ' AND ';
    exprOR       : Result := ' OR ';
    exprLIKE     : Result := ' LIKE ';
    exprEqual    : Result := ' = ';
    exprNonEqual : Result := ' <> ';
  end;
end;

{ JsonConversionException }

constructor JsonConversionException.Create;
begin
  Message := 'A estrutura dos dados é incompatível.';
end;

end.
