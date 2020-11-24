function html = markdown2html( md )
%markdown2html  Create GitLab issue discussion note
%
%  html = markdown2html(md)

% Request
hostname = "insidelabs-git.mathworks.com";
data = struct( "text", md, "gfm", true );
method = matlab.net.http.RequestMethod.POST;
request = matlab.net.http.RequestMessage( method, [], data );
uri = matlab.net.URI( "https://" + hostname + "/api/v4/markdown" );
response = request.send( uri );

% Return
switch response.StatusCode
    case matlab.net.http.StatusCode.Created
        html = response.Body.Data.html;
    otherwise
        throwAsCaller( exception( "create", response.Body.Data ) )
end

end % markdown2html

function e = exception( identifier, body )
%exception  Create exception from identifier and response body
%
%  e = exception(identifier,body)

if isfield( body, "error" )
    message = body.error;
elseif isfield( body, "message" )
    message = body.message;
else
    message = "Unknown error.";
end
e = MException( "gitlab:" + identifier, message );

end % exception