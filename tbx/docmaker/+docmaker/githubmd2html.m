function html = githubmd2html( markdown )
%docmaker.githubmd2html  Convert Markdown to HTML using GitHub
%
%   html = docmaker.githubmd2html(md) converts Markdown md to HTML using
%   the GitHub Markdown API.
%
%   The hostname defaults to "api.github.com". Set DOCMAKER_GITHUB_HOSTNAME
%   as a MATLAB Secret or environment variable to use an alternative
%   GitHub instance. The environment variable takes precedence over the
%   Secret.
%
%   Requests to this service are rate limited, and authenticated requests
%   get a higher limit. A GitHub access token with no permissions is
%   sufficient. To authenticate, set DOCMAKER_GITHUB_TOKEN as a MATLAB
%   secret (recommended for local machines from R2024a) or as an
%   environment variable (recommended for build runners). If both are set,
%   the environment variable takes precedence.
%
%   See also: docmaker.cmarkmd2html, docmaker.gitlabmd2html, docconvert

%   Copyright 2026 The MathWorks, Inc.

arguments
    markdown (1,1) string
end

% Create a request with the Markdown as a plain-text body
method = matlab.net.http.RequestMethod.POST;
request = matlab.net.http.RequestMessage( method, [], markdown );
request = addFields( request, "Content-Type", "text/plain" );

% Look for the token in the environment, then in a MATLAB Secret.
tokenName = "DOCMAKER_GITHUB_TOKEN";
token = string( getenv( tokenName ) );
if strlength( token ) == 0 && ...
        hasSecrets() && isSecret( tokenName )
    token = string( getSecret( tokenName ) );
end

% Look for a configured hostname; environment values override secrets.
hostnameName = "DOCMAKER_GITHUB_HOSTNAME";
hostname = string( getenv( hostnameName ) );
if strlength( hostname ) == 0 && ...
        hasSecrets() && isSecret( hostnameName )
    hostname = string( getSecret( hostnameName ) );
end
if strlength( hostname ) == 0
    hostname = "api.github.com";
end
if ~docmaker.ishostname( hostname )
    error( "docmaker:InvalidValue", ...
        "Invalid GitHub hostname: %s", hostname )
end

if strlength( token ) > 0
    request = addFields( request, "Authorization", "Bearer " + token );
end

% Request HTML output from GitHub
uri = matlab.net.URI( "https://" + hostname + "/markdown/raw" );
try
    response = request.send( uri );
catch exception
    if contains( lower( string( exception.identifier ) ), "timeout" ) || ...
            contains( lower( string( exception.message ) ), "timed out" )
        error( "docmaker:Timeout", ...
            "GitHub Markdown API request timed out: %s", ...
            string( exception.message ) )
    else
        error( "docmaker:Unavailable", ...
            "GitHub Markdown API is unavailable: %s", ...
            string( exception.message ) )
    end
end

% Return the HTML response, or report the HTTP failure
switch response.StatusCode
    case matlab.net.http.StatusCode.OK
        html = strtrim( string( response.Body.Data ) );
    otherwise
        statusCode = double( response.StatusCode );
        body = response.Body.Data;
        if isstruct( body ) && isfield( body, "message" )
            body = body.message;
        end
        body = string( body );
        if isempty( body )
            body = "<empty response body>";
        else
            body = strjoin( body(:), " " );
        end
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
        error( errorId, ...
            "GitHub Markdown API returned %s: %s", ...
            string( response.StatusLine ), body )
end

end % githubmd2html

function tf = hasSecrets()
%hasSecrets  Test whether MATLAB secrets are supported

persistent HAS_SECRETS
if isempty( HAS_SECRETS )
    HAS_SECRETS = ~isMATLABReleaseOlderThan( "R2024a" );
end
tf = HAS_SECRETS;

end % hasSecrets
