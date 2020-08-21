unit Orion.Utils;

interface

uses
  System.JSON,
  Rest.JSON,
  System.Generics.Collections,
  {$IFDEF VCL}
    Vcl.Graphics,
  {$ELSE}
    FMX.Graphics,
  {$ENDIF}
  System.Classes;


type
  TOrionUtils = class
  private
    FStatusCode : TJSONArray;
    procedure TryDisposeOf(aValue : TObject);
  public
    constructor Create;
    destructor Destroy; override;

    class function ObjectToJSON<T :class>(aObject : T) : TJSONObject;
    class function ObjectListToJSON<T:class>(aObjectList : TObjectList<T>) : TJSONArray;
    class function ObjectToJsonString(aObject : TObject) : string;
    class function ObjectListToJSONString<T:class, constructor>(aObjectList : TObjectList<T>) : string;
    class function JSONToObject<T :class, constructor>(aJSONObject : TJSONObject) : T; overload;
    class function JSONToObject<T :class, constructor>(aJson :string) : T; overload;
    class function JSONToObject<T :class, constructor>(aJSONValue : TJSONValue) : T; overload;
    class function JSONArrayToObjectList<T : class, constructor>(aJSONArray : TJSONArray) : TObjectList<T>; overload;
    class function JSONArrayToObjectList<T : class, constructor>(aJSONArray : TJSONValue) : TObjectList<T>; overload;
    class function JSONStringToJSONValue(aValue: string): TJSONValue;
    class function JSONStringToObject<T :class, constructor>(aJSONString: string): T; overload;
    class function JSONStringToObjectList<T :class, constructor>(aJSONString: string): TObjectList<T>; overload;
    class function EncodeBase64(aValue : string) : string;
    class function DecodeBase64(aValue: string): string; overload;
    class function DecodeBase64<T:class, constructor>(aValue: string): T; overload;
    class procedure DecodeBase64(aValue : string; aResult : TMemoryStream); overload;
    class procedure DecodeBase64(aValue, aResult : TStream); overload;
    class function BitmapFromBase64(aBitmap : TBitmap) : string;
    class function Base64FromStream(aBase64 : string) : TStream;
    function ResultCode201 : TJSONArray;
    function ResultCode401 : TJSONArray;
  end;
implementation

uses
  System.TypInfo,
  System.SysUtils, System.NetEncoding;

{ TOrionUtils }

class function TOrionUtils.Base64FromStream(aBase64 : string) : TStream;
var
  lImput : TStringStream;
  lEncoding : TBase64Encoding;
begin
  lImput := TStringStream.Create(aBase64, TEncoding.ASCII);
  Result := TStringStream.Create('', TEncoding.ASCII);
  lEncoding := TBase64Encoding.Create(0);
  try
    lImput.Position := 0;
    lEncoding.Decode(lImput, Result);
//    Result := TBitmap.CreateFromStream(lOutput);
  finally
    lImput.Free;
    lEncoding.Free;
  end;
end;

class function TOrionUtils.BitmapFromBase64(aBitmap: TBitmap): string;
var
  lImput : TBytesStream;
  lOutput : TStringStream;
  lEncoding : TBase64Encoding;
begin
  lImput := TBytesStream.Create;
  try
    aBitmap.SaveToStream(lImput);
    lImput.Position := 0;
    lOutput := TStringStream.Create('', TEncoding.ASCII);
    lEncoding := TBase64Encoding.Create(0);
    lEncoding.Encode(lImput, lOutput);
    Result := lOutput.DataString;
  finally
    lImput.Free;
    lOutput.Free;
    lEncoding.Free;
  end;
end;

constructor TOrionUtils.Create;
begin

end;

class function TOrionUtils.DecodeBase64(aValue: string): string;
begin
  Result := TNetEncoding.Base64.Decode(aValue);
end;

class procedure TOrionUtils.DecodeBase64(aValue: string; aResult: TMemoryStream);
var
  lFotoString : TStringStream;
begin
  lFotoString := TStringStream.Create(aValue);
  try
    lFotoString.Position := 0;
    TNetEncoding.Base64.Decode(lFotoString, aResult);
  finally
    lFotoString.Free;
  end;
end;

class procedure TOrionUtils.DecodeBase64(aValue, aResult: TStream);
begin
  TNetEncoding.Base64.Decode(aValue, aResult);
end;

class function TOrionUtils.DecodeBase64<T>(aValue: string): T;
begin
  Result := JSONToObject<T>(DecodeBase64(aValue));
end;

destructor TOrionUtils.Destroy;
begin

  inherited;
end;

class function TOrionUtils.EncodeBase64(aValue: string): string;
begin
  Result := TNetEncoding.Base64.Encode(aValue);
end;

procedure TOrionUtils.TryDisposeOf(aValue: TObject);
begin
  if Assigned(aValue) then
    aValue.DisposeOf;
end;

class function TOrionUtils.JSONToObject<T>(aJson: string): T;
begin
  Result := TJson.JsonToObject<T>(aJSON);
end;

class function TOrionUtils.JSONToObject<T>(aJSONObject: TJSONObject): T;
begin
  Result := TJson.JsonToObject<T>(aJSONObject);
end;

class function TOrionUtils.ObjectListToJSON<T>(
  aObjectList: TObjectList<T>): TJSONArray;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to Pred(aObjectList.Count) do
    Result.AddElement(ObjectToJSON(aObjectList[i]));
end;

class function TOrionUtils.ObjectListToJSONString<T>(aObjectList : TObjectList<T>) : string;
var
  lArray : TJSONArray;
begin
  lArray := ObjectListToJSON<T>(aObjectList);
  try
    Result := lArray.ToString;
  finally
    lArray.Free;
  end;
end;

class function TOrionUtils.ObjectToJSON<T>(aObject : T) : TJSONObject;
begin
  if aObject <> nil then
    Result := TJson.ObjectToJsonObject(aObject);
end;

class function TOrionUtils.ObjectToJsonString(aObject: TObject): string;
begin
  if aObject <> nil then
    Result := TJson.ObjectToJsonString(aObject);
end;

function TOrionUtils.ResultCode201: TJSONArray;
var
  LObjResult : TJSONObject;
begin
  TryDisposeOf(FStatusCode);
  FStatusCode := TJSONArray.Create;
  LObjResult := TJSONObject.Create;
  LObjResult.AddPair('Message', 'Inserção realizada com sucesso!');
  LObjResult.AddPair('StatusCode', '201');
  FStatusCode.Add(LObjResult);
  Result := FStatusCode;
end;

function TOrionUtils.ResultCode401: TJSONArray;
var
  LObjResult : TJSONObject;
begin
  TryDisposeOf(FStatusCode);
  FStatusCode := TJSONArray.Create;
  LObjResult := TJSONObject.Create;
  LObjResult.AddPair('Message', 'Usuário não autenticado.');
  LObjResult.AddPair('StatusCode', '401');
  FStatusCode.Add(LObjResult);
  Result := FStatusCode;
end;

class function TOrionUtils.JSONArrayToObjectList<T>(aJSONArray: TJSONArray): TObjectList<T>;
var
  I: Integer;
  lObjJson : TJSONObject;
begin
  Result := TObjectList<T>.Create;
  for I := 0 to Pred(aJSONArray.Count) do
  begin
    lObjJson := TJSONObject(aJSONArray.Items[i]);
    Result.Add(JSONToObject<T>(lObjJson));
  end;
end;

class function TOrionUtils.JSONArrayToObjectList<T>(aJSONArray: TJSONValue): TObjectList<T>;
var
  I: Integer;
  lObjJson : TJSONObject;
begin
  Result := TObjectList<T>.Create;
  for I := 0 to Pred(TJSONArray(aJSONArray).Count) do
  begin
    lObjJson := TJSONObject(TJSONArray(aJSONArray).Items[i]);
    Result.Add(JSONToObject<T>(lObjJson));
  end;
end;

class function TOrionUtils.JSONStringToJSONValue(aValue: string): TJSONValue;
begin
  Result := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(aValue), 0);
end;

class function TOrionUtils.JSONStringToObject<T>(aJSONString: string): T;
begin
  Result := TJson.JsonToObject<T>(aJSONString)
end;

class function TOrionUtils.JSONStringToObjectList<T>(aJSONString: string): TObjectList<T>;
var
  I: Integer;
  lObjJson : TJSONObject;
  lObjArray : TJSONArray;
begin
  lObjArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(aJSONString), 0) as TJSONArray;
  try
    Result := TObjectList<T>.Create;
    for I := 0 to Pred(lObjArray.Count) do
    begin
      lObjJson := TJSONObject(lObjArray.Items[i]);
      Result.Add(JSONToObject<T>(lObjJson));
    end;
  finally
    lObjArray.DisposeOf;
  end;
end;

class function TOrionUtils.JSONToObject<T>(aJSONValue: TJSONValue): T;
begin
  Result := TJson.JsonToObject<T>(TJSONObject(aJSONValue));
end;

end.
