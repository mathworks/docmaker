function html = markdown2html( md )
%markdown2html  Create GitLab issue discussion note
%
%  html = markdown2html(md)

% Handle inputs
narginchk( 1, 1 )

% Request
data = struct( "text", md, "gfm", true );
[status, body] = gitlab.request( "POST", "/markdown", data );

% Return
switch status
    case matlab.net.http.StatusCode.Created
        html = body.html;
    otherwise
        throwAsCaller( gitlab.exception( "create", body ) )
end

end % markdown2html