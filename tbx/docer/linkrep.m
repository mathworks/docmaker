function linkrep( doc, old, new )
%linkrep  Replace links in XML document
%
%  linkrep(x,o,n) replaces links in the XML document x with extension o
%  with links with extension n.
%
%  For example, replace Markdown links with HTML links using:
%    linkrep(x,".md",".html")

%  Copyright 2024 The MathWorks, Inc.

aa = doc.getElementsByTagName( "a" );
for ii = 1:aa.Length
    a = aa.item(ii-1);
    if a.hasAttribute( "href" )
        href = matlab.net.URI( a.getAttribute( "href" ) );
        path = href.EncodedPath;
        if endsWith( path, old )
            path = extractBefore( path, ...
                1 + strlength( path )- strlength( old ) ) + new;
            href.EncodedPath = path;
            a.setAttribute( "href", string( href ) )
        end
    end
end

end % linkrep