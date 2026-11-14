function doc = html2xml( html )
%html2xml  Convert rendered HTML to an XML DOM document
%
%   doc = docmaker.html2xml(html) converts rendered HTML to an XML DOM
%   document and normalizes MATLAB code blocks for docrun.
%
%   See also docconvert, docmaker.md2xml

%   Copyright 2026 The MathWorks, Inc.

arguments
    html (1,1) string
end

html = strtrim( html );

% Close HTML void elements to make the response valid XML
html = docmaker.closetags( html, "img" );
html = docmaker.closetags( html, "hr" );
html = docmaker.closetags( html, "br" );
html = docmaker.closetags( html, "input" );

parser = matlab.io.xml.dom.Parser();
doc = parser.parseString( "<div>" + html + "</div>" );
doc.XMLStandalone = true;

% Normalize MATLAB code blocks for docrun
pres = docmaker.list2array( doc.getElementsByTagName( "pre" ) );
for ii = 1:numel( pres )
    pre = pres(ii);
    codes = docmaker.list2array( pre.getElementsByTagName( "code" ) );
    parent = pre.getParentNode();
    hasMatlabWrapper = isa( parent, "matlab.io.xml.dom.Element" ) && ...
        docmaker.hasclass( parent, "highlight-source-matlab" );
    isMatlab = hasMatlabWrapper;
    if ~isempty( codes )
        code = codes(1);
        isMatlab = isMatlab || ...
            docmaker.hasclass( code, "language-matlab" );
    end
    if pre.hasAttribute( "lang" )
        isMatlab = isMatlab || ...
            lower( string( pre.getAttribute( "lang" ) ) ) == "matlab";
    end
    if ~isMatlab
        continue
    end

    % cmark-gfm appends a newline to fenced code blocks
    if ~isempty( codes )
        content = string( code.TextContent );
        if endsWith( content, newline() )
            code.TextContent = extractBefore( content, strlength( content ) );
        end
    end

    % GitHub may already wrap syntax-highlighted code for docrun
    if hasMatlabWrapper
        continue
    end

    div = doc.createElement( "div" );
    div.setAttribute( "class", "highlight highlight-source-matlab" );
    parent.insertBefore( div, pre );
    div.appendChild( pre );
end

end % html2xml
