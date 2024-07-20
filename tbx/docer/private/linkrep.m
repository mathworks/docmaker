function linkrep( doc, old, new )
%linkrep  Replace links in XML document
%
%   linkrep(x,o,n) replaces links with extension o in the XML document x
%   with links with extension n.
%
%   For example, replace Markdown links with HTML links using:
%      linkrep(x,".md",".html")

%   Copyright 2024 The MathWorks, Inc.

arguments
    doc (1,1) matlab.io.xml.dom.Document
    old (1,1) string
    new (1,1) string
end

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