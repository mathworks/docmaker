function html = markdown2html( md )
%markdown2html  Create GitLab issue discussion note
%
%  html = markdown2html(md)

% Handle inputs
narginchk( 1, 1 )

% Request
data = struct( "text", md, "gfm", true );
[status, body] = request( "POST", "/markdown", data );

% Return
switch status
    case matlab.net.http.StatusCode.Created
        html = body.html;
    otherwise
        throwAsCaller( exception( "create", body ) )
end

end % markdown2html

function [status, body] = request( method, endpoint, data )
%request  Send GitLab request and return response
%
%  [status,body] = gitlab.request(method,endpoint,data)

% Retrieve preferences
hostname = "insidelabs-git.mathworks.com";

% Create RequestMessage
request = matlab.net.http.RequestMessage( method, [], data );

% Send request
uri = matlab.net.URI( "https://" + hostname + "/api/v4" + endpoint );
response = request.send( uri );

% Return
status = response.StatusCode;
body = response.Body.Data;

end % request

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