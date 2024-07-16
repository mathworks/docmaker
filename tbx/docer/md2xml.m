function doc = md2xml( md )
%md2xml  Convert Markdown to XML
%
%  x = md2xml(md) converts the Markdown md to the XML document x using the
%  GitHub API at: https://docs.github.com/en/rest/markdown
%
%  Authenticated requests get a higher API rate limit.  To authenticate,
%  set the secret or preference using:
%  * setSecret("GitHub API token"), or
%  * setpref("docer","token",t)

%  Copyright 2024 The MathWorks, Inc.

arguments
    md (1,1) string
end

% Submit request
method = matlab.net.http.RequestMethod.POST;
request = matlab.net.http.RequestMessage( method, [], md );
request = addFields( request, "Content-Type", "text/plain" );
if ~verLessThan( "MATLAB", "24.1" ) && isSecret( "GitHub API token" ) %#ok<VERLESSMATLAB>
    request = addFields( request, "Authorization", ...
        "Bearer " + getSecret( "GitHub API token" ) );
elseif ispref( "docer", "token" )
    request = addFields( request, "Authorization", ...
        "Bearer " + getpref( "docer", "token" ) );
end
uri = matlab.net.URI( "https://api.github.com/markdown/raw" );
response = request.send( uri );

% Handle response
switch response.StatusCode
    case matlab.net.http.StatusCode.OK
        xml = response.Body.Data;
        xml = strtrim( xml );
    otherwise
        throw( MException( "docer:UnhandledError", "[%s] %s", ...
            string( response.StatusLine ), response.Body.Data.message ) )
end

% Close img tags to ensure valid XML
img = strfind( xml, "<img " ); % all "img" tag opens
gt = strfind( xml, ">" ); % *all* tag closes
for ii = numel( img ):-1:1 % backwards
    i = min( gt(gt>img(ii)) ); % first ">" after "<img "
    if extract( xml, i-1 ) == "/", continue, end % already closed
    xml = extractBefore( xml, i ) + "/>" + extractAfter( xml, i ); % replace > with />
end

% Wrap in div
parser = matlab.io.xml.dom.Parser();
doc = parser.parseString( "<div>" + xml + "</div>" );
doc.XMLStandalone = true;

end % md2xml