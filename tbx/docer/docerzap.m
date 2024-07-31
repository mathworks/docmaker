function docerzap( filename, wslevel, zap )

arguments
    filename (1,1) string {mustBeFile}
    wslevel (1,1) double {mustBeInteger,mustBeInRange(wslevel,0,6)} = 0
    zap (1,1) matlab.lang.OnOffSwitchState = "on"
end

% Read from file
parser = matlab.io.xml.dom.Parser();
parser.Configuration.AllowDoctype = true;
doc = parser.parseFile( filename );

% Find all headings and divs
nHeadings = 6; % # HTML heading levels
allHeadings = cell( nHeadings, 1 ); % preallocate
for ii = 1:nHeadings
    allHeadings{ii} = elements( doc.getElementsByTagName( "h"+ii ) );
end
allDivs = elements( doc.getElementsByTagName( "div" ) );

% Initialize
root = doc.getDocumentElement();
oldFigures = docer.figures();
from = root; % start from root
if zap, zaplevel = 0; else, zaplevel = 6; end

while ~isempty( from )

    % Get current level
    if from == root
        fromlevel = 0;
    else
        fromlevel = sscanf( from.TagName, "h%d" );
    end

    % Find next heading
    to = getNextHeading( from, allHeadings );

    % Find divs before next heading
    if isempty( to )
        divs = allDivs(isAfter( allDivs, from ));
    else
        divs = allDivs(isBetween( allDivs, from, to ));
    end

    % Reset if necessary
    if fromlevel <= wslevel
        w = docer.Workspace();
        delete( setdiff( docer.figures(), oldFigures ) )
    end

    % Update zap level
    if fromlevel == 0
        % already initialized
    elseif fromlevel < zaplevel
        zaplevel = fromlevel;
        zap = endsWith( from.TextContent, char( 9889 ) );
    elseif fromlevel == zaplevel
        zap = endsWith( from.TextContent, char( 9889 ) ); % reset
    elseif zap == false
        zaplevel = fromlevel;
        zap = endsWith( from.TextContent, char( 9889 ) );
    end

    % Process divs
    for ii = 1:numel( divs )
        div = divs( ii );
        if zap && div.hasAttribute( "class" ) && contains( ... % MATLAB input
                div.getAttribute( "class" ), "highlight-source-matlab" )
            docer.zap( div, w ) % zap
        elseif div.hasAttribute( "class" ) && contains( ... % MATLAB output
                div.getAttribute( "class" ), "highlight-output-matlab" )
            div.getParentNode().removeChild( div ); % delete
            allDivs(allDivs == div) = [];
        end
    end

    % Advance
    from = to;

end % while

% Clean up
delete( setdiff( docer.figures(), oldFigures ) )

% Write to file
writer = matlab.io.xml.dom.DOMWriter();
writer.writeToFile( doc, filename );

end % docerzap

function ee = elements( nn )
%elements  Convert dynamic node list to static element vector

ee = matlab.io.xml.dom.Element.empty( 0, 1 );
for ii = 1:nn.Length
    ee(ii,1) = nn.node( ii );
end

end % elements

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

[a, b] = expand( a, b ); % expand scalars
tf = true( size( a ) ); % preallocate
for ii = 1:numel( a )
    c = uint8( compareDocumentPosition( b(ii), a(ii) ) );
    tf(ii) = bitget( c, 1 ) == false && bitget( c, 3 ) == true;
end

end % isAfter

function tf = isBetween( a, b, c )
%isBetween  True if an element is between two others
%
%   tf = isBetween(a,b,c) is true if a is between b and c, and false
%   otherwise.

[a, b, c] = expand( a, b, c ); % expand scalars
tf = isAfter( a, b ) & isAfter( c, a );

end % isBetween

function varargout = expand( varargin )
%expand  Perform scalar expansion
%
%   [a,b] = expand(a,b) expands scalar a to match the size of nonscalar b,
%   or vice versa.
%
%   [a,b,c,...] = expand(a,b,c,...) performs scalar expansion on as many
%   variables as requested.

for ii = 1:nargin
    for jj = ii+1:nargin
        if isscalar( varargin{ii} ) && ~isscalar( varargin{jj} )
            varargin{ii} = repmat( varargin{ii}, size( varargin{jj} ) );
        elseif ~isscalar( varargin{ii} ) && isscalar( varargin{jj} )
            varargin{jj} = repmat( varargin{jj}, size( varargin{ii} ) );
        else
            assert( isequal( size( varargin{ii} ), size( varargin{jj} ) ) )
        end
    end
end
varargout = varargin; % return; varargin is not a valid output

end % expand