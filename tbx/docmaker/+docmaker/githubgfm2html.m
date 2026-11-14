function html = githubgfm2html( markdown )
%githubgfm2html  Convert Markdown to HTML using GitHub's API
%
%   html = githubgfm2html(md) converts Markdown md to HTML using the
%   GitHub Markdown API at https://docs.github.com/en/rest/markdown.
%
%   Requests to this service are rate limited, and authenticated requests
%   get a higher limit. A GitHub access token with no permissions is
%   sufficient. To authenticate, set DOCMAKER_GITHUB_TOKEN as a MATLAB
%   secret (recommended for local machines from R2024a) or as an
%   environment variable (recommended for build runners).
%
%   See also: docmaker.md2xml, docconvert

%   Copyright 2026 The MathWorks, Inc.

arguments
    markdown (1,1) string
end

% Create a request with the Markdown as a plain-text body
method = matlab.net.http.RequestMethod.POST;
request = matlab.net.http.RequestMessage( method, [], markdown );
request = addFields( request, "Content-Type", "text/plain" );

% Look for token, in a MATLAB secret, or in an environment variable
tokenName = "DOCMAKER_GITHUB_TOKEN";
if hasSecrets() && isSecret( tokenName )
    token = string( getSecret( tokenName ) );
else % fallback
    token = string( getenv( tokenName ) ); % empty if no env var
end
if strlength( token ) > 0
    request = addFields( request, "Authorization", "Bearer " + token );
end

% Request HTML output from GitHub
uri = matlab.net.URI( "https://api.github.com/markdown/raw" );
response = request.send( uri );

% Return the HTML response, or report the HTTP failure
switch response.StatusCode
    case matlab.net.http.StatusCode.OK
        html = strtrim( string( response.Body.Data ) );
    otherwise
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
        error( "docmaker:githubgfm2html:RequestFailed", ...
            "GitHub Markdown API returned %s: %s", ...
            string( response.StatusLine ), body )
end

end % githubgfm2html

function tf = hasSecrets()
%hasSecrets  Test whether MATLAB secrets are supported

persistent HAS_SECRETS
if isempty( HAS_SECRETS )
    HAS_SECRETS = ~isMATLABReleaseOlderThan( "R2024a" );
end
tf = HAS_SECRETS;

end % hasSecrets
