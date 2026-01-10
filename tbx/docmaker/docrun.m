function varargout = docrun( sHtml, options )
%docrun  Run MATLAB code in HTML documents and insert output
%
%   docrun(html) runs MATLAB code blocks in the HTML document(s) html, and
%   inserts the textual and graphical output.  html can be a char or string
%   including wildcards, a cellstr or string array, or a dir struct.
%
%   Multiple documents can also be specified as docrun(html1,html2,...).
%
%   Textual output is text written to the command window.  Graphical output
%   is new figures or changes to existing figures.
%
%   docrun runs arbitrary MATLAB code blocks in HTML documents.  This is a
%   potential vector for malicious attacks.  Only run code from people or
%   organizations you trust.
%
%   docrun(...,"Level",n) specifies the batching level n.  With level 0
%   (default), all blocks in a document are run in a single batch. With
%   level n, each level-n heading is run as a separate batch, with the
%   workspace cleared and figures closed between batches.  With level 7,
%   each block is run as a separate batch.
%
%   docrun(...,"Theme",t) specifies the theme t.  Available themes are
%   "none" (as is, default), "light", "dark" and "auto" (responsive).
%
%   files = docrun(...) returns the names of the files modified.

%   Copyright 2024-2026 The MathWorks, Inc.

arguments ( Repeating )
    sHtml
end

arguments
    options.Level (1,1) double {mustBeInteger,mustBeInRange(options.Level,0,7)} = 0
    options.Theme (1,1) string {mustBeMember(options.Theme,["none","light","dark","auto"])} = "none"
end

% Initialize output
oFiles = strings( 0, 1 );

% Check documents
sHtml = docmaker.dir( sHtml{:} );
assert( all( docmaker.extensions( sHtml ) == ".html" ), ...
    "docmaker:InvalidArgument", ...
    "HTML files must all have extension .html." )
if isempty( sHtml ), return, end

% Run
for ii = 1:numel( sHtml ) % loop over files
    fHtml = fullfile( sHtml(ii).folder, sHtml(ii).name ); % this file
    run( fHtml, options.Level, options.Theme )
    fprintf( 1, "[%s] %s\n", char( 9889 ), fHtml );
    oFiles(end+1,:) = fHtml; %#ok<AGROW>
end

% Return output
if nargout > 0
    varargout{1} = oFiles;
end

end % docrun

function run( html, batchLevel, theme )
%run  Run MATLAB code in an HTML document and insert output
%
%   run(html,b) runs MATLAB code blocks in the HTML document html with the
%   batching level b, and inserts the textual and graphical output.

% Read from file
parser = matlab.io.xml.dom.Parser();
parser.Configuration.AllowDoctype = true;
doc = parser.parseFile( html );

% Find all headings and divs
nHeadings = 6; % # HTML heading levels
allHeadings = cell( nHeadings, 1 ); % preallocate
for ii = 1:nHeadings
    allHeadings{ii} = docmaker.list2array( doc.getElementsByTagName( "h"+ii ) );
end
allDivs = docmaker.list2array( doc.getElementsByTagName( "div" ) );

% Initialize
root = doc.getDocumentElement();
from = root; % start from root
oldFigures = docmaker.figures(); % existing figures

while true

    % Get current level
    if from == root
        fromLevel = 0;
    else
        fromLevel = sscanf( from.TagName, "h%d" );
    end

    % Update workspace and figures
    if fromLevel <= batchLevel % reset
        w = docmaker.Workspace();
        delete( setdiff( docmaker.figures(), oldFigures ) )
    end

    % Find divs before next heading
    to = getNextHeading( from, allHeadings );
    if isempty( to )
        divs = allDivs(isAfter( allDivs, from ));
    else
        divs = allDivs(isAfter( allDivs, from ) & isAfter( to, allDivs ));
    end

    % Run source divs, remove old output divs
    for ii = 1:numel( divs )
        div = divs( ii );
        if div.hasAttribute( "class" ) && contains( ... % MATLAB input
                div.getAttribute( "class" ), "highlight-source-matlab" ) && ...
                ~endsWith( div.TextContent, whitespacePattern() )
            runDiv( div, w, theme ) % zap
        elseif div.hasAttribute( "class" ) && contains( ... % MATLAB output
                div.getAttribute( "class" ), "highlight-output-matlab" )
            div.getParentNode().removeChild( div ); % remove
        end
    end

    % Continue
    if isempty( to )
        break % done
    else
        from = to; % advance
    end

end % while

% Clean up
delete( setdiff( docmaker.figures(), oldFigures ) )

% Write to file
writer = matlab.io.xml.dom.DOMWriter();
writer.Configuration.XMLDeclaration = false;
writer.Configuration.FormatPrettyPrint = false;
writer.writeToFile( doc, html, "utf-8" );

end % run

function runDiv( div, w, theme )
%runDiv  Run MATLAB code from a div and insert output
%
%   runDiv(d,w) runs the MATLAB code from the div d in the workspace w, and
%   inserts the output between d and its next sibling.

% Get related helper elements
doc = div.getOwnerDocument(); % for node creation
next = div.getNextSibling(); % for result insertion

% Extract code
inDiv = div;
inString = div.TextContent;

% Capture initial figures and their 'prints
oldFigures = docmaker.figures();
oldPrints = arrayfun( @docmaker.capture, oldFigures, "UniformOutput", false );

% Evaluate expression and capture output
try
    outString = string( evalinc( w, inString ) );
    ok = true; % ok
catch e
    warning( "docmaker:EvalError", "%s", e.message ) % rethrow as warning
    outString = e.message;
    ok = false; % error
end

% Capture final figures and their 'prints
newFigures = docmaker.figures();
newPrints = arrayfun( @docmaker.capture, newFigures, "UniformOutput", false );

% Return new and modified figures
wasPrints = cell( size( newPrints ) ); % preallocate
[tf, loc] = ismember( oldFigures, newFigures ); % match
wasPrints(loc(tf)) = oldPrints(tf); % corresponding
outFigures = newFigures(~cellfun( @isequal, newPrints, wasPrints )); % select
outFigures = outFigures(:); % return column vector

% Add text output
if strlength( outString ) > 0

    % Strip out markup
    backspacePattern = wildcardPattern(1) + characterListPattern(char(8));
    outString = erase( outString, backspacePattern );
    outString = rmlinks( outString );

    % Create HTML elements div, pre, text
    outDiv = doc.createElement( "div" );
    outDiv.setAttribute( "class", "highlight highlight-output-matlab" );
    outPre = doc.createElement( "pre" );
    outPre.setAttribute( "style", "background-color:var(--bgColor-default);" );
    if ~ok % error, style text color
        outPre.setAttribute( "style", outPre.getAttribute( "style" ) + ...
            " color:var(--fgColor-danger);" );
    end
    outDiv.appendChild( outPre );
    outText = doc.createTextNode( outString );
    outPre.appendChild( outText );

    % Add output to document
    if isempty( next )
        inDiv.getParentNode().appendChild( outDiv ); % end
    else
        inDiv.getParentNode().insertBefore( outDiv, next );
    end

end

% Add figure output
for jj = 1:numel( outFigures )

    outFigure = outFigures(jj);

    % Create HTML elements div, img
    outDiv = doc.createElement( "div" );
    outDiv.setAttribute( "class", "highlight highlight-output-matlab" );
    if ~isprop( outFigure, "Theme" ) || isequal( theme, "none" )
        outImg = createSimpleImage( doc, outFigure );
    elseif isequal( theme, "auto" )
        outImg = createResponsiveImage( doc, outFigure );
    else
        outImg = createThemedImage( doc, outFigure, theme );
    end
    outDiv.appendChild( outImg );

    % Add output to document
    if isempty( next )
        inDiv.getParentNode().appendChild( outDiv ); % end
    else
        inDiv.getParentNode().insertBefore( outDiv, next );
    end

end

end % runDiv

function nextHeading = getNextHeading( e, allHeadings )
%getNextHeading  Get next heading
%
%   h = getNextHeading(e,ah) returns the next heading h from among all
%   headings ah after the element e.

nextHeading = [];
for ii = 1:numel( allHeadings )
    thisHeadings = allHeadings{ii};
    for jj = 1:numel( thisHeadings )
        thisHeading = thisHeadings(jj);
        if isAfter( thisHeading, e ) && ( isequal( nextHeading, [] ) || ...
                isAfter( nextHeading, thisHeading ) )
            nextHeading = thisHeading;
            break
        end
    end
end

end % getNextHeading

function tf = isAfter( a, b )
%isAfter  True if an element is after another
%
%   tf = isAfter(a,b) is true if a is after b, and false otherwise.
%
%   https://www.w3schools.com/jsref/met_node_comparedocumentposition.asp

% Check inputs and perform scalar expansion
if isscalar( a ) && ~isscalar( b )
    a = repmat( a, size( b ) );
elseif ~isscalar( a ) && isscalar( b )
    b = repmat( b, size( a ) );
else
    assert( isequal( size( a ), size( b ) ), "docmaker:InvalidArgument", ...
        "Cannot compare element arrays of different sizes." )
end

% Compare each element in turn
tf = true( size( a ) ); % preallocate
for ii = 1:numel( a )
    c = uint8( compareDocumentPosition( b(ii), a(ii) ) );
    tf(ii) = bitget( c, 1 ) == false && bitget( c, 3 ) == true;
end

end % isAfter

function s = rmlinks( s )
%rmlinks  Remove links from output text
%
%   s = rmlinks(s) removes links from the text s, replacing <a ...>c</a>
%   with c.

to = "<a " + wildcardPattern + ">"; % opening
tc = "</a>"; % closing
while true
    li = extractBetween( s, to, tc, "Boundaries", "inclusive" ); % find
    if isempty( li )
        break % no links, break
    end
    li = li(1); % first
    po = strfind( s, li ); % find
    po = po(1); % first
    t = extractBetween( li, to, tc ); % text
    s = replaceBetween( s, po, po + strlength( li ) - 1, t ); % strip
end
s = strtrim( s ); % tidy

end % rmlinks

function img = createSimpleImage( doc, f )
%createSimpleImage  Create as-is image from figure
%
%   e = createSimpleImage(doc,f) creates an image element from the figure f
%   in the document doc.

data = docmaker.encode( f );
img = doc.createElement( "img" );
img.setAttribute( "src", "data:image/png;base64," + data );
position = hgconvertunits( f, f.Position, ...
    f.Units, "pixels", groot() ); % pixels
img.setAttribute( "style", "width: " + position(3) + ...
    "px; height: auto" ); % apply display scaling

end % createSimpleImage

function img = createThemedImage( doc, f, newTheme  )
%createThemedImage  Create themed image from figure
%
%   e = createThemedImage(doc,f,t) creates an image element from the figure
%   f with the theme t in the document doc.

oldTheme = f.Theme;
undo = onCleanup( @()set( f, "Theme", oldTheme ) );
f.Theme = newTheme;
data = docmaker.encode( f );
img = doc.createElement( "img" );
img.setAttribute( "src", "data:image/png;base64," + data );
position = hgconvertunits( f, f.Position, ...
    f.Units, "pixels", groot() ); % pixels
img.setAttribute( "style", "width: " + position(3) + ...
    "px; height: auto" ); % apply display scaling

end % createThemedImage

function picture = createResponsiveImage( doc, f )
%createResponsiveImage  Create responsive image from figure
%
%   e = createThemedImage(doc,f) creates a responsive image element from
%   the figure f in the document doc.

oldTheme = f.Theme;
undo = onCleanup( @()set( f, "Theme", oldTheme ) );
f.Theme = "light";
lightData = docmaker.encode( f );
f.Theme = "dark";
darkData = docmaker.encode( f );
picture = doc.createElement( "picture" );
lightSrc = doc.createElement( "source" );
lightSrc.setAttribute( "media", "(prefers-color-scheme: light)" );
lightSrc.setAttribute( "srcset", "data:image/png;base64," + lightData );
picture.appendChild( lightSrc );
darkSrc = doc.createElement( "source" );
darkSrc.setAttribute( "media", "(prefers-color-scheme: dark)" );
darkSrc.setAttribute( "srcset", "data:image/png;base64," + darkData );
picture.appendChild( darkSrc );
img = doc.createElement( "img" );
img.setAttribute( "src", "data:image/png;base64," + lightData );
position = hgconvertunits( f, f.Position, f.Units, "pixels", groot() ); % pixels
img.setAttribute( "style", "width: " + position(3) + ...
    "px; height: auto" ); % apply display scaling
picture.appendChild( img );

end % createResponsiveImage