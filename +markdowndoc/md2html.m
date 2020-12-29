function html = md2html( md, hostname )
%md2html  Convert (GitLab Flavored) Markdown to HTML
%
%  html = markdowndoc.md2html(md)
%  html = markdowndoc.md2html(md,hostname)

%  Copyright 2020 The MathWorks, Inc.

% Handle inputs
narginchk( 1, 2 )
if nargin < 2, hostname = "insidelabs-git.mathworks.com"; end

% Submit request
data = struct( "text", md, "gfm", true );
method = matlab.net.http.RequestMethod.POST;
request = matlab.net.http.RequestMessage( method, [], data );
uri = matlab.net.URI( "https://" + hostname + "/api/v4/markdown" );
response = request.send( uri );

% Handle response
switch response.StatusCode
    case matlab.net.http.StatusCode.Created
        html = response.Body.Data.html;
    otherwise
        throw( MException( "gitlab:create", response.Body.Data.error ) )
end

end % md2html