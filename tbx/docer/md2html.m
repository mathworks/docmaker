function html = md2html( md, options )
%md2html  Convert Markdown to HTML
%
%  html = md2html(md) converts the Markdown md to HTML html using the
%  GitHub API.
%
%  html = md2html(md,"ReplaceLinks",tf) controls whether to replace
%  Markdown links with equivalent HTML links (default "on").
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
    options.ReplaceLinks (1,1) matlab.lang.OnOffSwitchState = "on"
end

% Submit request
method = matlab.net.http.RequestMethod.POST;
request = matlab.net.http.RequestMessage( method, [], md );
request = addFields( request, "Content-Type", "text/plain" );
if isenv( "GITHUB_API_TOKEN" ) % authorize if token available
    request = addFields( request, "Authorization", "Bearer " + ...
        getenv( "GITHUB_API_TOKEN" ) );
end
uri = matlab.net.URI( "https://api.github.com/markdown/raw" );
response = request.send( uri );

% Handle response
switch response.StatusCode
    case matlab.net.http.StatusCode.OK
        html = strtrim( response.Body.Data );
    otherwise
        throw( MException( "github:UnhandledError", "[%s] %s", ...
            string( response.StatusLine ), response.Body.Data.message ) )
end

% Close img tags to ensure valid XML
img = strfind( html, "<img " ); % all "img" tag opens
gt = strfind( html, ">" ); % *all* tag closes
for ii = numel( img ):-1:1 % backwards
    i = min( gt(gt>img(ii)) ); % first ">" after "<img "
    if extract( html, i-1 ) == "/", continue, end % already closed
    html = extractBefore( html, i ) + "/>" + extractAfter( html, i ); % replace > with />
end

% Wrap in div
html = "<div class=""github-markdown-html"">" + newline + html + "</div>";

% Replace links
if options.ReplaceLinks
    html = linkrep( html, ".md", ".html" );
end

end % md2html

function s = linkrep( s, old, new )
%linkrep  Replace link path extensions
%
%  s = linkrep(s,o,n) replaces link path extensions in the XML string s
%  from o to n.
%
%  For example, linkrep(s,".md",".html") replaces Markdown links with HTML
%  links.

parser = matlab.io.xml.dom.Parser();
doc = parser.parseString( s );
aa = doc.getElementsByTagName( "a" );
for ii = 1:aa.Length
    a = aa.item(ii-1);
    if a.hasAttribute( "href" )
        href = matlab.net.URI( a.getAttribute( "href" ) );
        if endsWith( href.EncodedPath, old )
            href.EncodedPath = extractBefore( href.EncodedPath, 1 + ...
                strlength( href.EncodedPath ) - strlength( old ) ) + new;
            a.setAttribute( "href", string( href ) )
        end
    end
end
writer = matlab.io.xml.dom.DOMWriter();
writer.Configuration.FormatPrettyPrint = true;
writer.Configuration.XMLDeclaration = false;
s = writer.writeToString( doc );
s = string( s );
s = strtrim( s );

end % linkrep