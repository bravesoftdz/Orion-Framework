unit Orion.RestClient.Indy;

interface

uses
  Orion.RestClient.Interfaces,
  System.JSON,
  IdHTTP,
  idGlobal,
  IdException;

type
  TOrionRestClientIndy = class(TInterfacedObject, iOrionRestClient)
  private
    FIndyHttp : TIdHttp;
    FToken : string;
    FResult : string;
    FBaseUrl : string;
    procedure SetToken;
    function BuildUri(aUri : string) : string;
  public
    constructor Create; overload;
    constructor Create(aToken : string); overload;
    destructor Destroy; override;
    class function New : iOrionRestClient; overload;
    class function New(aToken : string) : iOrionRestClient; overload;

    function BaseUrl : string; overload;
    function BaseUrl(aValue : string) : iOrionRestClient; overload;
    function Get(aUri : string) : string;
    function Post(aUri : string; aBody : string; aEncodeBase64 : boolean = true) : string;
    function Put(aUri : string; aBody : string) : string;
    function Delete(aUri : string) : string;
    function StatusCode : integer;
    function ResponseBody : string;
  end;
implementation

uses
  System.Classes,
  System.NetEncoding,
  System.SysUtils;

{ TOrionRestClientIndy }

constructor TOrionRestClientIndy.Create;
begin
  FIndyHttp := TIdHttp.Create(nil);
//  FIndyHttp.HTTPOptions := [hoNoProtocolErrorException];
end;

function TOrionRestClientIndy.BaseUrl(aValue: string): iOrionRestClient;
begin
  Result := Self;
  FBaseUrl := aValue;
end;

function TOrionRestClientIndy.BuildUri(aUri: string): string;
begin
  if FBaseUrl.Trim <> EmptyStr then
  begin
    if not aUri.Contains(FBaseUrl) then
      Result := FBaseUrl + aUri
    else
      Result := aUri;
    Exit;
  end;

  Result := aUri;
end;

function TOrionRestClientIndy.BaseUrl: string;
begin
  Result := FBaseUrl;
end;

constructor TOrionRestClientIndy.Create(aToken: string);
begin
  FToken := aToken;
end;

function TOrionRestClientIndy.Delete(aUri : string) : string;
begin
  try
    FResult := FIndyHttp.Delete(BuildUri(aUri));
    Result := FResult;
  except on E: EIdHTTPProtocolException do
    begin
      FResult := E.ErrorMessage;
      Result  := E.ErrorMessage;
      raise OrionRestClientException.Create(E.ErrorMessage);
    end;
  end;
end;

destructor TOrionRestClientIndy.Destroy;
begin
  FIndyHttp.DisposeOf;
  inherited;
end;

function TOrionRestClientIndy.Get(aUri : string) : string;
begin
  try
    FResult := FIndyHttp.Get(BuildUri(aUri));
    Result := FResult;
  except on E: EIdHTTPProtocolException do
    begin
      FResult := E.ErrorMessage;
      Result  := E.ErrorMessage;
      raise OrionRestClientException.Create(E.ErrorMessage);
    end;
  end;
end;

class function TOrionRestClientIndy.New(aToken: string): iOrionRestClient;
begin
  Result := Self.Create(aToken);
end;

class function TOrionRestClientIndy.New: iOrionRestClient;
begin
  Result := Self.Create;
end;

function TOrionRestClientIndy.Post(aUri : string; aBody : string; aEncodeBase64 : boolean = true) : string;
var
  lStream : TStringStream;
begin
  if aEncodeBase64 then
    lStream := TStringStream.Create(TNetEncoding.Base64.Encode(aBody))
  else
    lStream := TStringStream.Create(aBody);
  try
    try
      FResult := FIndyHttp.Post(BuildUri(aUri), lStream);
      Result := FResult;
    except on E: EIdHTTPProtocolException do
      begin
        FResult := E.ErrorMessage;
        Result  := E.ErrorMessage;
        raise OrionRestClientException.Create(E.ErrorMessage);
      end;
    end;
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
    try
      FResult := FIndyHttp.Put(BuildUri(aUri), lStream);
      Result := FResult;
    except on E: EIdHTTPProtocolException do
      begin
        FResult := E.ErrorMessage;
        Result  := E.ErrorMessage;
        raise OrionRestClientException.Create(E.ErrorMessage);
      end;
    end;
  finally
    lStream.Free;
  end;
end;

function TOrionRestClientIndy.ResponseBody: string;
begin
  Result := FResult;
end;

procedure TOrionRestClientIndy.SetToken;
begin
  if FToken <> '' then
  begin
    FIndyHttp.Request.CustomHeaders.AddValue('','');
  end;
end;

function TOrionRestClientIndy.StatusCode: integer;
begin
  Result := FIndyHttp.ResponseCode;
end;

end.
