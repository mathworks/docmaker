function html = md2html( md )
%md2html  Convert Markdown to HTML
%
%  html = md2html(md) converts the Markdown md to HTML html using the
%  GitHub API.
%
%  API documentation: https://docs.github.com/en/rest/markdown
%
%  See also: docpages

%  Copyright 2024 The MathWorks, Inc.

arguments
    md (1,1) string
end

% Submit request
method = matlab.net.http.RequestMethod.POST;
header = matlab.net.http.HeaderField( "Content-Type", "text/plain" );
request = matlab.net.http.RequestMessage( method, header, md );
uri = matlab.net.URI( "https://api.github.com/markdown/raw" );
response = request.send( uri );

% Handle response
switch response.StatusCode
    case matlab.net.http.StatusCode.OK
        html = response.Body.Data;
    otherwise
        throw( MException( "github:UnhandledError", "Unknown error." ) )
end

end % md2html