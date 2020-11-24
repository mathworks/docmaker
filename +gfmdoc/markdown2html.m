function html = markdown2html( md )
%markdown2html  Create GitLab issue discussion note
%
%  html = markdown2html(md)

% Handle inputs
narginchk( 1, 1 )

% Request
data = struct( "text", md, "gfm", true );
[status, body] = gitlab.request( "POST", "/markdown", data );

% Return
switch status
    case matlab.net.http.StatusCode.Created
        html = body.html;
    otherwise
        throwAsCaller( exception( "create", body ) )
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