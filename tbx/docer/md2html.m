function html = md2html( md )
%md2html  Convert Markdown to HTML
%
%  html = md2html(md) converts the Markdown md to HTML html using the
%  GitHub API.
%
%  API documentation: https://docs.github.com/en/rest/markdown
%
%  Authenticated requests get a higher API rate limit.  To authenticate,
%  set the environment variable GITHUB_API_TOKEN.
%
%  See also: docerpub

%  Copyright 2024 The MathWorks, Inc.

arguments
    md (1,1) string
end

% Submit request
method = matlab.net.http.RequestMethod.POST;
request = matlab.net.http.RequestMessage( method, [], md );
request = addFields( request, "Content-Type", "text/plain" );
if isenv( "GITHUB_API_TOKEN" )
    request = addFields( request, "Authorization", "Bearer " + ...
        getenv( "GITHUB_API_TOKEN" ) );
end
uri = matlab.net.URI( "https://api.github.com/markdown/raw" );
response = request.send( uri );

% Handle response
switch response.StatusCode
    case matlab.net.http.StatusCode.OK
        html = response.Body.Data;
    otherwise
        throw( MException( "github:UnhandledError", "[%s] %s", ...
            string( response.StatusLine ), response.Body.Data.message ) )
end

end % md2html