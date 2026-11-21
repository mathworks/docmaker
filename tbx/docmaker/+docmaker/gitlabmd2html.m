function html = gitlabmd2html( markdown )
%docmaker.gitlabmd2html  Convert Markdown to HTML using GitLab
%
%   html = docmaker.gitlabmd2html(md) converts Markdown md using the
%   GitLab Markdown API.
% 
%   The hostname defaults to "gitlab.com". Set DOCMAKER_GITLAB_HOSTNAME
%   as a MATLAB Secret or environment variable to use an alternative
%   GitLab instance. The environment variable takes precedence over the
%   Secret.
%
%   Requests to this service must be authenticated. A GitLab access token
%   scope "api" is sufficient. To authenticate, set DOCMAKER_GITLAB_TOKEN
%   as a MATLAB secret (recommended for local machines from R2024a) or as
%   an environment variable (recommended for build runners). If both are
%   set, the environment variable takes precedence.
%
%   See also: docmaker.githubmd2html, docmaker.cmarkmd2html, docconvert

%   Copyright 2026 The MathWorks, Inc.

arguments
    markdown (1,1) string
end

% Look for a configured hostname; environment values override secrets.
hostnameName = "DOCMAKER_GITLAB_HOSTNAME";
hostnameFromEnvironment = string( getenv( hostnameName ) );
hostnameFromSecret = "";
if strlength( hostnameFromEnvironment ) == 0 && ...
        hasSecrets() && isSecret( hostnameName )
    hostnameFromSecret = string( getSecret( hostnameName ) );
end
hostname = docmaker.selectApiSetting( hostnameFromEnvironment, ...
    hostnameFromSecret, "gitlab.com" );
if ~docmaker.ishostname( hostname )
    error( "docmaker:InvalidValue", ...
        "Invalid GitLab hostname: %s", hostname )
end

% Look for the token in the environment, then in a MATLAB Secret.
tokenName = "DOCMAKER_GITLAB_TOKEN";
tokenFromEnvironment = string( getenv( tokenName ) );
tokenFromSecret = "";
if strlength( tokenFromEnvironment ) == 0 && ...
        hasSecrets() && isSecret( tokenName )
    tokenFromSecret = string( getSecret( tokenName ) );
end
token = docmaker.selectApiSetting( tokenFromEnvironment, ...
    tokenFromSecret, "" );
if strlength( token ) == 0
    error( "docmaker:PermissionDenied", ...
        "GitLab Markdown conversion requires a personal access token." + ...
        newline() + "Set DOCMAKER_GITLAB_TOKEN as an environment " + ...
        "variable or MATLAB Secret." )
end

% Create a request with GitLab-flavored Markdown as JSON.
method = matlab.net.http.RequestMethod.POST;
body = struct( "text", markdown, "gfm", true );
request = matlab.net.http.RequestMessage( method, [], body );
request = addFields( request, "Content-Type", "application/json" );
request = addFields( request, "Accept", "application/json" );
request = addFields( request, "PRIVATE-TOKEN", token );

% Request HTML output from GitLab.
uri = matlab.net.URI( "https://" + hostname + "/api/v4/markdown" );
try
    response = request.send( uri );
catch exception
    if contains( lower( string( exception.identifier ) ), "timeout" ) || ...
            contains( lower( string( exception.message ) ), "timed out" )
        error( "docmaker:Timeout", ...
            "GitLab Markdown API request timed out: %s", ...
            string( exception.message ) )
    else
        error( "docmaker:Unavailable", ...
            "GitLab Markdown API is unavailable: %s", ...
            string( exception.message ) )
    end
end

% Return the HTML response, or report the HTTP failure.
switch response.StatusCode
    case matlab.net.http.StatusCode.Created
        data = response.Body.Data;
        if isstruct( data ) && isfield( data, "html" )
            html = strtrim( string( data.html ) );
        else
            error( "docmaker:InvalidResponse", ...
                "GitLab Markdown API response did not contain HTML." )
        end
    otherwise
        message = getResponseMessage( response );
        statusCode = double( response.StatusCode );
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
            "GitLab Markdown API returned %s: %s", ...
            string( response.StatusLine ), message )
end

end % gitlabmd2html

function message = getResponseMessage( response )
%getResponseMessage  Get a readable message from an API response

body = response.Body.Data;
if isstruct( body ) && isfield( body, "message" )
    body = body.message;
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
