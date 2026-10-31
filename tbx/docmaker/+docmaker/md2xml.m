function doc = md2xml( md )
%docmaker.md2xml  Convert Markdown to XML using cmark-gfm
%
%   x = docmaker.md2xml(md) converts the Markdown md to XML using the
%   local cmark-gfm MEX. Conversion runs offline.
%
%   The cmark-gfm MEX is currently supplied for Windows x64 only.

%   Copyright 2026 The MathWorks, Inc.

arguments
    md (1,1) string
end

% Check for a MEX binary built for this platform.
mexFile = fullfile( fileparts( mfilename( "fullpath" ) ), ...
    "cmarkgfm2html." + mexext() );
if ~isfile( mexFile )
    error( "docmaker:md2xml:MissingMEX", ...
        "The cmark-gfm converter requires cmarkgfm2html.%s, " + ...
        "currently supplied for Windows x64 only.", mexext() )
end

% Convert Markdown to HTML.
html = string( docmaker.cmarkgfm2html( md ) );
html = strtrim( html );

% Close HTML void elements to ensure valid XML.
html = docmaker.closetags( html, "img" );
html = docmaker.closetags( html, "hr" );
html = docmaker.closetags( html, "br" );
html = docmaker.closetags( html, "input" );

% Parse HTML as XML.
parser = matlab.io.xml.dom.Parser();
doc = parser.parseString( "<div>" + html + "</div>" );
doc.XMLStandalone = true;

% Normalize MATLAB code blocks for docrun.
pres = docmaker.list2array( doc.getElementsByTagName( "pre" ) );
for ii = 1:numel( pres )
    pre = pres(ii);
    codes = docmaker.list2array( pre.getElementsByTagName( "code" ) );
    if isempty( codes ) || ...
            ~docmaker.hasclass( codes(1), "language-matlab" )
        continue
    end

    % cmark-gfm adds a final newline to fenced code blocks.
    code = codes(1);
    content = string( code.TextContent );
    if endsWith( content, newline() )
        code.TextContent = extractBefore( content, strlength( content ) );
    end

    % docrun identifies MATLAB source by this wrapper class.
    div = doc.createElement( "div" );
    div.setAttribute( "class", "highlight highlight-source-matlab" );
    parent = pre.getParentNode();
    parent.insertBefore( div, pre );
    div.appendChild( pre );
end

end % md2xml