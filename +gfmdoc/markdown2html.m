function html = markdown2html( md )
%markdown2html  Convert GitLab Flavored Markdown to HTML
%
%  html = markdown2html(md)

% Request
hostname = "insidelabs-git.mathworks.com";
data = struct( "text", md, "gfm", true );
method = matlab.net.http.RequestMethod.POST;
request = matlab.net.http.RequestMessage( method, [], data );
uri = matlab.net.URI( "https://" + hostname + "/api/v4/markdown" );
response = request.send( uri );

% Return
switch response.StatusCode
    case matlab.net.http.StatusCode.Created
        html = response.Body.Data.html;
    otherwise
        throw( MException( "gitlab:create", response.Body.Data.error ) )
end

end % markdown2html