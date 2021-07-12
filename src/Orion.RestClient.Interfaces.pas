unit Orion.RestClient.Interfaces;

interface

uses
  System.SysUtils;

type
  iOrionRestClient = interface
    ['{FC57B899-6720-4A0E-BDCA-B13D9447CB95}']
    function BaseUrl : string; overload;
    function BaseUrl(aValue : string) : iOrionRestClient; overload;
    function Get(aUri : string) : string;
    function Post(aUri : string; aBody : string; aEncodeBase64 : boolean = true) : string;
    function Put(aUri : string; aBody : string) : string;
    function Delete(aUri : string) : string;
    function StatusCode : integer;
    function ResponseBody : string;
  end;

  OrionRestClientException = class(Exception)

  end;

  OrionRestClientExceptionGet = class(OrionRestClientException)

  end;

  OrionRestClientExceptionPost = class(OrionRestClientException)

  end;

  OrionRestClientExceptionPut = class(OrionRestClientException)

  end;

  OrionRestClientExceptionDelete = class(OrionRestClientException)

  end;

  OrionRestClientExceptionNotFound = class(OrionRestClientException)

  end;

  OrionRestClientExceptionBadRequest = class(OrionRestClientException)

  end;

implementation

end.
