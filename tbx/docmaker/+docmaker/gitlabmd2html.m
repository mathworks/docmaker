function html = gitlabmd2html( markdown )
%docmaker.gitlabmd2html  Convert Markdown to HTML using GitLab
%
%   html = docmaker.gitlabmd2html(md) converts Markdown md using the
%   GitLab Markdown API.
% 
%   Requests to this service must be authenticated. A GitLab access token
%   scope "api" is sufficient. To authenticate, set DOCMAKER_GITLAB_TOKEN
%   as a MATLAB secret (recommended for local machines from R2024a) or as
%   an environment variable (recommended for build runners).
%
%   See also docmaker.githubmd2html, docmaker.cmarkmd2html, docconvert

%   Copyright 2026 The MathWorks, Inc.

arguments
    markdown (1,1) string
end

% Look for the token in a MATLAB secret, then in the environment.
tokenName = "DOCMAKER_GITLAB_TOKEN";
if hasSecrets() && isSecret( tokenName )
    token = string( getSecret( tokenName ) );
else
    token = string( getenv( tokenName ) );
end
if strlength( token ) == 0
    error( "docmaker:gitlabmd2html:MissingToken", ...
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

% Request HTML output from GitLab.com.
uri = matlab.net.URI( "https://gitlab.com/api/v4/markdown" );
response = request.send( uri );

% Return the HTML response, or report the HTTP failure.
switch response.StatusCode
    case matlab.net.http.StatusCode.Created
        data = response.Body.Data;
        if isstruct( data ) && isfield( data, "html" )
            html = strtrim( string( data.html ) );
        else
        error( "docmaker:gitlabmd2html:InvalidResponse", ...
                "GitLab Markdown API response did not contain HTML." )
        end
    otherwise
        message = getResponseMessage( response );
        error( "docmaker:gitlabmd2html:RequestFailed", ...
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
