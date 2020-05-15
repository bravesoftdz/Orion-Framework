unit Orion.RestClient.Indy;

interface

uses
  Orion.RestClient.Interfaces, System.JSON, IdHTTP, idGlobal;

type
  TOrionRestClientIndy = class(TInterfacedObject, iOrionRestClient)
  private
    FIndyHttp : TIdHttp;
    FToken : string;
    procedure SetToken;
  public
    constructor Create; overload;
    constructor Create(aToken : string); overload;
    destructor Destroy; override;
    class function New : iOrionRestClient; overload;
    class function New(aToken : string) : iOrionRestClient; overload;

    function Get(aUri : string) : string;
    function Post(aUri : string; aBody : string) : string;
    function Put(aUri : string; aBody : string) : string;
    function Delete(aUri : string) : string;
  end;
implementation

uses
  System.Classes,
  System.NetEncoding;

{ TOrionRestClientIndy }

constructor TOrionRestClientIndy.Create;
begin
  FIndyHttp := TIdHttp.Create(nil);
end;

constructor TOrionRestClientIndy.Create(aToken: string);
begin
  FToken := aToken;
end;

function TOrionRestClientIndy.Delete(aUri : string) : string;
begin
  Result := FIndyHttp.Delete(aUri);
end;

destructor TOrionRestClientIndy.Destroy;
begin
  FIndyHttp.DisposeOf;
  inherited;
end;

function TOrionRestClientIndy.Get(aUri : string) : string;
begin
  Result := FIndyHttp.Get(aUri);
end;

class function TOrionRestClientIndy.New(aToken: string): iOrionRestClient;
begin
  Result := Self.Create(aToken);
end;

class function TOrionRestClientIndy.New: iOrionRestClient;
begin
  Result := Self.Create;
end;

function TOrionRestClientIndy.Post(aUri : string; aBody : string) : string;
var
  lStream : TStringStream;
begin
  lStream := TStringStream.Create(TNetEncoding.Base64.Encode(aBody));
  try
    Result := FIndyHttp.Post(aUri, lStream);
  finally
    lStream.DisposeOf;
  end;
end;

function TOrionRestClientIndy.Put(aUri : string; aBody : string) : string;
var
  lStream : TStringStream;
begin
  lStream := TStringStream.Create(TNetEncoding.Base64.Encode(aBody));
  try
    Result := FIndyHttp.Put(aUri, lStream);
  finally
    lStream.Free;
  end;
end;

procedure TOrionRestClientIndy.SetToken;
begin
  if FToken <> '' then
  begin
    FIndyHttp.Request.CustomHeaders.AddValue('','');
  end;
end;

end.
