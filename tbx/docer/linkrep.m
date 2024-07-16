function linkrep( doc, ext )
%linkrep  Replace Markdown links in XML document
%
%  linkrep(x,ext) replaces Markdown links in the XML document x with the
%  extension ext.

%  Copyright 2024 The MathWorks, Inc.

aa = doc.getElementsByTagName( "a" );
for ii = 1:aa.Length
    a = aa.item(ii-1);
    if a.hasAttribute( "href" )
        href = matlab.net.URI( a.getAttribute( "href" ) );
        path = href.EncodedPath;
        if endsWith( path, ".md" )
            path = extractBefore( path, strlength( path ) - 2 ) + ext;
            href.EncodedPath = path;
            a.setAttribute( "href", string( href ) )
        end
    end
end

end % linkrep