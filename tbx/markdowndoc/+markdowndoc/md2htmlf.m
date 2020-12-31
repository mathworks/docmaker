function htmlf = md2htmlf( md, hostname )
%md2htmlf  Convert (GitLab Flavored) Markdown to HTML fragment
%
%  htmlf = markdowndoc.md2htmlf(md)
%  htmlf = markdowndoc.md2htmlf(md,hostname)

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
        htmlf = response.Body.Data.html;
    otherwise
        throw( MException( "gitlab:create", response.Body.Data.error ) )
end

end % md2htmlf