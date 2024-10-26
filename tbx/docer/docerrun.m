function varargout = docerrun( sHtml, options )
%docerrun  Run MATLAB code in HTML documents and insert output
%
%   docerrun(html) runs MATLAB code blocks in the HTML document(s) html,
%   and inserts the textual and graphical output.  html can be a char or
%   string including wildcards, a cellstr or string array, or a dir struct.
%
%   Textual output is text written to the command window.  Graphical output
%   is new figures or changes to existing figures.
%
%   Multiple documents can also be specified as docerrun(html1,html2,...).
%
%   docerrun(...,"Level",n) specifies the batching level n.  With level 0
%   (default), all blocks in a document are run in a single batch. With
%   level n, each level-n heading is run as a separate batch, with the
%   workspace cleared and figures closed between batches.  With level 7,
%   each block is run as a separate batch.
%
%   files = docerrun(...) returns the names of the files modified.

%   Copyright 2024 The MathWorks, Inc.

arguments ( Repeating )
    sHtml
end

arguments
    options.Level (1,1) double {mustBeInteger,mustBeInRange(options.Level,0,7)} = 0
end

% Initialize output
oFiles = strings( 0, 1 );

% Check documents
sHtml = docer.dir( sHtml{:} );
assert( all( docer.extensions( sHtml ) == ".html" ), ...
    "docer:InvalidArgument", ...
    "HTML files must all have extension .html." )
if isempty( sHtml ), return, end

% Run
for ii = 1:numel( sHtml ) % loop over files
    fHtml = fullfile( sHtml(ii).folder, sHtml(ii).name ); % this file
    run( fHtml, options.Level )
    fprintf( 1, "[%s] %s\n", char( 9889 ), fHtml );
    oFiles(end+1,:) = fHtml; %#ok<AGROW>
end

% Return output
if nargout > 0
    varargout{1} = oFiles;
end

end % docerrun

function run( html, batchLevel )
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
    allHeadings{ii} = docer.list2array( doc.getElementsByTagName( "h"+ii ) );
end
allDivs = docer.list2array( doc.getElementsByTagName( "div" ) );

% Initialize
root = doc.getDocumentElement();
from = root; % start from root
oldFigures = docer.figures(); % existing figures

while true

    % Get current level
    if from == root
        fromLevel = 0;
    else
        fromLevel = sscanf( from.TagName, "h%d" );
    end

    % Update workspace and figures
    if fromLevel <= batchLevel % reset
        w = docer.Workspace();
        delete( setdiff( docer.figures(), oldFigures ) )
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
            runDiv( div, w ) % zap
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
delete( setdiff( docer.figures(), oldFigures ) )

% Write to file
writer = matlab.io.xml.dom.DOMWriter();
writer.Configuration.XMLDeclaration = false;
writer.Configuration.FormatPrettyPrint = false;
writer.writeToFile( doc, html, "utf-8" );

end % run

function runDiv( div, w )
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
oldFigures = docer.figures();
oldPrints = arrayfun( @docer.capture, oldFigures, "UniformOutput", false );

% Evaluate expression and capture output
try
    outString = string( evalinc( w, inString ) );
    ok = true; % ok
catch e
    warning( "docer:EvalError", "%s", e.message ) % rethrow as warning
    outString = e.message;
    ok = false; % error
end

% Capture final figures and their 'prints
newFigures = docer.figures();
newPrints = arrayfun( @docer.capture, newFigures, "UniformOutput", false );

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
    outDiv.setAttribute( "class", "highlight highlight-output" );
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
    outImg = doc.createElement( "img" );
    outImg.setAttribute( "src", "data:image/png;base64, " + ...
        docer.encode( outFigure ) );
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
    assert( isequal( size( a ), size( b ) ), "docer:InvalidArgument", ...
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

po = "<a " + wildcardPattern + ">"; % opening
pc = "</a>"; % closing
while true
    li = extractBetween( s, po, pc, "Boundaries", "inclusive" ); % find
    if isempty( li )
        break % no links, break
    end
    li = li(1); % first
    po = strfind( s, li ); % find
    po = po(1); % first
    t = extractBetween( li, po, pc ); % text
    s = replaceBetween( s, po, po + strlength( li ) - 1, t ); % strip
end
s = strtrim( s ); % tidy

end % rmlinks