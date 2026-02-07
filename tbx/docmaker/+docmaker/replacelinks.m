function replacelinks( doc, old, new )
%replacelinks  Replace links in XML document
%
%   docmaker.replacelinks(x,o,n) replaces link extensions o with n in the
%   XML document x.
%
%   For example, replace Markdown links with HTML links using:
%      docmaker.replacelinks(x,".md",".html")

%   Copyright 2024-2026 The MathWorks, Inc.

arguments
    doc (1,1) matlab.io.xml.dom.Document
    old (1,1) string
    new (1,1) string
end

aa = docmaker.list2array( doc.getElementsByTagName( "a" ) );
for ii = 1:numel( aa )
    a = aa(ii);
    if a.hasAttribute( "href" )
        href = matlab.net.URI( a.getAttribute( "href" ) );
        path = href.EncodedPath;
        if endsWith( path, old )
            path = extractBefore( path, ...
                1 + strlength( path ) - strlength( old ) ) + new;
            href.EncodedPath = path;
            a.setAttribute( "href", string( href ) )
        end
    end
end

end % replacelinks