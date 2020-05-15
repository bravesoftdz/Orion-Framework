unit Orion.RestClient.Interfaces;

interface

type
  iOrionRestClient = interface
    ['{FC57B899-6720-4A0E-BDCA-B13D9447CB95}']
    function Get(aUri : string) : string;
    function Post(aUri : string; aBody : string) : string;
    function Put(aUri : string; aBody : string) : string;
    function Delete(aUri : string) : string;
  end;
implementation

end.
