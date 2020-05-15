unit CommerceServices.Connection.Interfaces;

interface

uses
  Orion.Data.Interfaces;

type
  iConnectionFactory = interface
    ['{258FDAD4-6907-4983-976A-7CA06C853E55}']
    function Connection : iConexao;
    function DataSet : iDataSet; overload;
    function DataSet(aConexao : iConexao) : iDataSet; overload;
  end;
implementation

end.
