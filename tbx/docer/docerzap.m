function docerzap( filename, wslevel, zap )

arguments
    filename (1,1) string {mustBeFile}
    wslevel (1,1) double {mustBeInteger,mustBeInRange(wslevel,0,6)} = 0
    zap (1,1) matlab.lang.OnOffSwitchState = "off"
end

% Read from file
parser = matlab.io.xml.dom.Parser();
parser.Configuration.AllowDoctype = true;
doc = parser.parseFile( filename );

% Find all headings and divs
allHeadings = cell( 6, 1 ); % preallocate
for ii = 1:numel( allHeadings )
    allHeadings{ii} = elements( doc.getElementsByTagName( "h"+ii ) );
end
allDivs = elements( doc.getElementsByTagName( "div" ) );
tf = true( size( allDivs ) );
for ii = 1:numel( allDivs )
    tf(ii) = allDivs(ii).hasAttribute( "class" ) && ( ...
        contains( allDivs(ii).getAttribute( "class" ), "highlight-source-matlab" ) || ...
        contains( allDivs(ii).getAttribute( "class" ), "highlight-output-matlab" ) );
end
allDivs(~tf) = [];

from = doc.getDocumentElement; % start from root
if zap, zaplevel = 0; else, zaplevel = 6; end
while ~isempty( from )
    % Get current level
    if from == doc.getDocumentElement()
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
    % Create fresh workspace if necessary
    if fromlevel <= wslevel
        w = docer.Workspace();
    end
    % Update zap level
    if fromlevel <= zaplevel
        zaplevel = fromlevel;
        zap = endsWith( from.TextContent, char( 9889 ) );
    elseif fromlevel == zaplevel
        zap = endsWith( from.TextContent, char( 9889 ) ); % reset
    elseif zap == false
        zaplevel = fromlevel;
        zap = endsWith( from.TextContent, char( 9889 ) );
    end

    



    from = to;

end % while

end % docerzap

function ee = elements( nn )

ee = matlab.io.xml.dom.Element.empty( 0, 1 );
for ii = 1:nn.Length
    ee(ii) = nn.node( ii );
end

end % elements

function nextHeading = getNextHeading( e, allHeadings )

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

end

function tf = isAfter( a, b )
%isAfter  True if an element is after another
%
%   tf = isAfter(a,b) is true if a is after b, and false otherwise.

[a, b] = expand( a, b ); % expand scalars
tf = true( size( a ) ); % preallocate
for ii = 1:numel( a )
    tf(ii) = bitget( uint8( compareDocumentPosition( b(ii), a(ii) ) ), 3 );
end

end

function tf = isBefore( a, b )

tf = isAfter( b, a );

end % isBefore

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