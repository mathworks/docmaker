function html = apimd2html( md, service )
%docmaker.apimd2html  Convert Markdown using a service API
%
%   html = docmaker.apimd2html(md,s) converts Markdown md to HTML using the
%   Markdown API service s. Supported services are "github" and "gitlab".
%
%   See also: docmaker.githubmd2html, docmaker.gitlabmd2html

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

% Resolve and validate the hostname.
hostnameVar = string( config.hostname.variable );
hostname = string( getenv( hostnameVar ) );
if strlength( hostname ) == 0 && ...
        hasSecrets() && isSecret( hostnameVar )
    hostname = string( getSecret( hostnameVar ) );
end
if strlength( hostname ) == 0
    hostname = string( config.hostname.default );
end
if ~docmaker.ishostname( hostname )
    error( "docmaker:InvalidValue", ...
        "%s", "Invalid hostname for " + string( config.name ) + ...
        ": " + hostname )
end

% Resolve authentication settings.
auth = config.authentication;
tokenName = string( auth.variable );
token = string( getenv( tokenName ) );
if strlength( token ) == 0 && ...
        hasSecrets() && isSecret( tokenName )
    token = string( getSecret( tokenName ) );
end
if strlength( token ) == 0 && auth.required
    error( "docmaker:PermissionDenied", ...
        "%s", string( config.name ) + " Markdown conversion requires " + ...
        tokenName + "." )
end

% Create the service-specific request body.
requestConfig = config.request;
switch string( requestConfig.method )
    case "POST"
        method = matlab.net.http.RequestMethod.POST;
    otherwise
        error( "docmaker:UnsupportedOperation", ...
            "%s", "Unsupported HTTP method in " + string( config.name ) + ...
            " configuration." )
end

switch string( requestConfig.bodyFormat )
    case "plainText"
        body = md;
    case "gfmJson"
        body = struct( "text", md, "gfm", true );
    otherwise
        error( "docmaker:UnsupportedValue", ...
            "Unsupported request body format in %s configuration.", ...
            string( config.name ) )
end

request = matlab.net.http.RequestMessage( method, [], body );
request = addFields( request, "Content-Type", ...
    string( requestConfig.contentType ) );
if ~isempty( requestConfig.accept )
    request = addFields( request, "Accept", string( requestConfig.accept ) );
end
if strlength( token ) > 0
    header = string( auth.header );
    prefix = string( auth.prefix );
    request = addFields( request, header, prefix + token );
end

% Send the request to the configured host.
uri = matlab.net.URI( "https://" + hostname + string( requestConfig.path ) );
try
    response = request.send( uri );
catch exception
    if contains( lower( string( exception.identifier ) ), "timeout" ) || ...
            contains( lower( string( exception.message ) ), "timed out" )
        error( "docmaker:Timeout", ...
            "%s Markdown API request timed out: %s", ...
            string( config.name ), string( exception.message ) )
    else
        error( "docmaker:Unavailable", ...
            "%s Markdown API is unavailable: %s", ...
            string( config.name ), string( exception.message ) )
    end
end

% Report API errors using the configured response field when available.
responseConfig = config.response;
statusCode = double( response.StatusCode );
if statusCode ~= responseConfig.successStatusCode
    message = getResponseMessage( ...
        response, string( responseConfig.errorMessageField ) );
    statusLine = string( response.StatusLine );
    switch statusCode
        case {401, 403}
            errorId = "docmaker:PermissionDenied";
        case 404
            errorId = "docmaker:NotFound";
        case {408, 504}
            errorId = "docmaker:Timeout";
        case {502, 503}
            errorId = "docmaker:Unavailable";
        otherwise
            errorId = "docmaker:OperationFailed";
    end
    error( errorId, "%s Markdown API returned %s: %s", ...
        string( config.name ), statusLine, message )
end

% Extract the HTML from the configured response format.
switch string( responseConfig.format )
    case "rawHtml"
        html = strtrim( string( response.Body.Data ) );
    case "json"
        data = response.Body.Data;
        field = char( string( responseConfig.htmlField ) );
        if isstruct( data ) && isfield( data, field )
            html = strtrim( string( data.(field) ) );
        else
            error( "docmaker:InvalidResponse", ...
                "%s Markdown API response did not contain HTML.", ...
                string( config.name ) )
        end
    otherwise
        error( "docmaker:UnsupportedValue", ...
            "Unsupported response format in %s configuration.", ...
            string( config.name ) )
end

end % apimd2html

function message = getResponseMessage( response, messageField )
%getResponseMessage  Get a readable message from an API response

body = response.Body.Data;
if isstruct( body ) && isfield( body, char( messageField ) )
    body = body.(char( messageField ));
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
%hasSecrets  Test whether MATLAB secrets are supported

persistent HAS_SECRETS
if isempty( HAS_SECRETS )
    HAS_SECRETS = ~isMATLABReleaseOlderThan( "R2024a" );
end
tf = HAS_SECRETS;

end % hasSecrets
