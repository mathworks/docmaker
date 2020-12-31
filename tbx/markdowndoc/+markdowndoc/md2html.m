function html = md2html( md, hostname )
%md2html  Convert (GitLab Flavored) Markdown to HTML fragment
%
%  html = markdowndoc.md2html(md,hostname) converts the Markdown md to HTML
%  html using the GitLab API at the specified hostname.
%
%  html = markdowndoc.md2html(md) uses the default host: insidelabs within
%  MathWorks and GitLab.com outside.
%
%  MarkDown API documentation: https://docs.gitlab.com/ee/api/markdown.html
%
%  See also: markdowndoc.publish

%  Copyright 2020-2021 The MathWorks, Inc.

% Handle inputs
narginchk( 1, 2 )
if nargin < 2
    switch lower( getenv( "userdomain" ) )
        case "mathworks"
            hostname = "insidelabs-git.mathworks.com"; % MathWorks
        otherwise
            hostname = "gitlab.com"; % public
    end
end

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