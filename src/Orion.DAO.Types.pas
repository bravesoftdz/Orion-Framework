unit Orion.DAO.Types;

interface

uses
  System.Generics.Collections, System.SysUtils;

type
  TOrionExpressions = (exprAND, exprOR, exprLIKE, exprEqual, exprNonEqual, exprBetween);

  OrionDAOCoreException = class(Exception)

  end;

  JsonConversionException = class(OrionDAOCoreException)
    constructor Create;
  end;

  OrionDAOCoreFindException = class(OrionDAOCoreException)
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
    exprBetween  : Result := ' between ';
  end;
end;

{ JsonConversionException }

constructor JsonConversionException.Create;
begin
  Message := 'A estrutura dos dados é incompatível.';
end;

{ OrionDAOCoreFindException }

constructor OrionDAOCoreFindException.Create;
begin
  Message := 'Failed to search data on DB';
end;

end.
