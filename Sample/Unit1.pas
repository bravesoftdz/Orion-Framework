unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Orion.DAO.Core, Orion.DAO.Types,
  Entity.Commerce, Entity.Commerce.Types, Data.DB, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids;

type
  TForm1 = class(TForm)
    DBGrid1: TDBGrid;
    Button1: TButton;
    Edit1: TEdit;
    DataSource1: TDataSource;
    edtIDExterno: TEdit;
    edtRazaoSocial: TEdit;
    edtFantasia: TEdit;
    Button2: TButton;
    Button3: TButton;
    edtID: TEdit;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    FDAO : TOrionDAOCore;
  end;

var
  Form1: TForm1;

implementation

uses
  CommerceServices.Connection.Factory, System.Generics.Collections;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  FDAO.Request.Params.Clear;
  if Edit1.Text <> '' then
    FDAO.Request.AddParam(COMERCIO_ID, exprEqual, Edit1.Text);
  FDAO.Operations.Find<TComercio>;
  FDAO.Response.DataSet.Fields.FieldByName(COMERCIO_ID).ProviderFlags := [];
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  lComercio : TComercio;
begin
  lComercio := TComercio.Create;
  try
    lComercio.IdExterno    := edtIDExterno.Text;
    lComercio.RazaoSocial  := edtRazaoSocial.Text;
    lComercio.NomeFantasia := edtFantasia.Text;

    FDAO.Operations.Insert<TComercio>(lComercio);
    FDAO.Operations.Find<TComercio>;
  finally
    lComercio.Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  lComercio : TComercio;
begin
  lComercio := TComercio.Create;
  try
    lComercio.ID           := StrToInt(edtID.Text);
    lComercio.IdExterno    := edtIDExterno.Text;
    lComercio.RazaoSocial  := edtRazaoSocial.Text;
    lComercio.NomeFantasia := edtFantasia.Text;

    FDAO.Operations.Update<TComercio>(lComercio);
  finally
    lComercio.Free;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  lLista : TObjectList<TComercio>;
  lComercio : TComercio;
begin
  lLista := TObjectList<TComercio>.Create;
  try
    FDAO.Response.DataSet.First;
    while not FDAO.Response.DataSet.EOF do
    begin
      lComercio              := TComercio.Create;                                  
      lComercio.ID           := FDAO.Response.DataSet.Fields.FieldByName(COMERCIO_ID).AsInteger;
      lComercio.IdExterno    := FDAO.Response.DataSet.Fields.FieldByName(COMERCIO_ID_EXTERNO).AsString;
      lComercio.RazaoSocial  := FDAO.Response.DataSet.Fields.FieldByName(COMERCIO_RAZAOSOCIAL).AsString;
      lComercio.NomeFantasia := FDAO.Response.DataSet.Fields.FieldByName(COMERCIO_NOMEFANTASIA).AsString;
      
      lLista.Add(lComercio);
        
      FDAO.Response.DataSet.Next;
    end;    
    FDAO.Operations.Update<TComercio>(lLista, [COMERCIO_ID_EXTERNO]);
  finally
    lLista.Free;
  end;  
end;

procedure TForm1.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  edtID.Text          := FDAO.Response.DataSet.Fields.FieldByName('ID').AsString;
  edtIDExterno.Text   := FDAO.Response.DataSet.Fields.FieldByName('EXTERNAL_ID').AsString;
  edtRazaoSocial.Text := FDAO.Response.DataSet.Fields.FieldByName('CORPORATE_NAME').AsString;
  edtFantasia.Text    := FDAO.Response.DataSet.Fields.FieldByName('FANTASY_NAME').AsString;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDAO := TOrionDAOCore.Create(TConnectionFactory.New.DataSet(TConnectionFactory.New.Connection));
  FDAO.Response.DataSet.DataSource(DataSource1);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FDAO.DisposeOf;
end;

end.
