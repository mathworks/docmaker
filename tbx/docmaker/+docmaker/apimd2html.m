function html = apimd2html( md, service )
%docmaker.apimd2html  Convert Markdown using a service API
%
%   html = docmaker.apimd2html(md,s) converts Markdown md to HTML using the
%   Markdown API service s. Supported services are "github" and "gitlab".
%
%   See also: docmaker.md2xml, docconvert

%   Copyright 2026 The MathWorks, Inc.

arguments
    md (1,1) string
    service (1,1) string {mustBeMember(service,["github","gitlab"])}
end

% Load the service configuration
configFile = fullfile( fileparts( mfilename( "fullpath" ) ), service + ".json" );
if ~isfile( configFile )
    error( "docmaker:NotFound", ...
        "Configuration file not found: %s", configFile )
end
config = jsondecode( fileread( configFile ) );

% Resolve and validate the hostname
hostnameConfig = config.hostname;
hostnameName = hostnameConfig.name;
if ~isempty( getenv( hostnameName ) )
    hostname = getenv( hostnameName );
elseif hasSecrets() && isSecret( hostnameName )
    hostname = getSecret( hostnameName );
else
    hostname = hostnameConfig.default;
end
assert( docmaker.ishostname( hostname ), ...
    "docmaker:InvalidValue", ...
    "Invalid hostname for %s Markdown API: %s", config.name, hostname )

% Resolve authentication settings
authConfig = config.authentication;
tokenName = authConfig.name;
if ~isempty( getenv( tokenName ) )
    token = getenv( tokenName );
elseif hasSecrets() && isSecret( tokenName )
    token = getSecret( tokenName );
else
    token = '';
end

% Create the service-specific request body
requestConfig = config.request;
method = matlab.net.http.RequestMethod.( requestConfig.method );
switch requestConfig.bodyFormat
    case "plainText"
        body = md;
    case "gfmJson"
        body = struct( "text", md, "gfm", true );
    otherwise
        error( "docmaker:UnsupportedValue", ...
            "Unsupported request body format in %s Markdown API configuration.", ...
            config.name )
end
request = matlab.net.http.RequestMessage( method, [], body );
request = addFields( request, "Content-Type", requestConfig.contentType );
if ~isempty( requestConfig.accept )
    request = addFields( request, "Accept", requestConfig.accept );
end
if strlength( token ) > 0
    header = authConfig.header;
    prefix = authConfig.prefix;
    request = addFields( request, header, string( prefix ) + token );
end

% Send the request to the configured host
uri = matlab.net.URI( "https://" + hostname + requestConfig.path );
try
    response = request.send( uri );
catch e
    error( "docmaker:Unavailable", "%s", e.message )
end

% Report API errors using the configured response field
import matlab.net.http.StatusCode
responseConfig = config.response;
if response.StatusCode ~= StatusCode.( responseConfig.successStatus )
    message = getResponseMessage( ...
        response, responseConfig.errorMessageField );
    statusLine = string( response.StatusLine );
    switch response.StatusCode
        case {StatusCode.Unauthorized, StatusCode.Forbidden}
            errorId = "docmaker:PermissionDenied";
        case StatusCode.NotFound
            errorId = "docmaker:NotFound";
        case {StatusCode.RequestTimeout, StatusCode.GatewayTimeout}
            errorId = "docmaker:Timeout";
        case {StatusCode.BadGateway, StatusCode.ServiceUnavailable}
            errorId = "docmaker:Unavailable";
        otherwise
            errorId = "docmaker:OperationFailed";
    end
    error( errorId, "%s Markdown API returned %s: %s", ...
        config.name, statusLine, message )
end

% Extract the HTML from the configured response format
switch responseConfig.format
    case "rawHtml"
        html = strtrim( string( response.Body.Data ) );
    case "json"
        data = response.Body.Data;
        field = responseConfig.htmlField;
        if isstruct( data ) && isfield( data, field )
            html = strtrim( string( data.(field) ) );
        else
            error( "docmaker:InvalidResponse", ...
                "%s Markdown API response did not contain HTML.", ...
                config.name )
        end
    otherwise
        error( "docmaker:UnsupportedValue", ...
            "Unsupported response format in %s Markdown API configuration.", ...
            config.name )
end

end % apimd2html

function message = getResponseMessage( response, messageField )
%getResponseMessage  Get a readable message from an API response

body = response.Body.Data;
if isstruct( body ) && isfield( body, messageField )
    body = body.(messageField);
end
try
    message = strjoin( string( body(:) ), " " );
catch
    message = "<unreadable response body>";
end
if strlength( message ) == 0
    message = "<empty response body>";
end

end % getResponseMessage

function tf = hasSecrets()
%hasSecrets  Test whether the MATLAB secrets vault is available

persistent HAS_SECRETS
if isempty( HAS_SECRETS )
    if isMATLABReleaseOlderThan( "R2024a" )
        HAS_SECRETS = false;
    else
        try
            [~] = listSecrets();
            HAS_SECRETS = true;
        catch
            HAS_SECRETS = false;
        end
    end
end
tf = HAS_SECRETS;

end % hasSecrets
