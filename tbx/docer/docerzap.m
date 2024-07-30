function docerzap( filename, level, zap )

arguments
    filename (1,1) string {mustBeFile}
    level (1,1) double {mustBeInteger,mustBeInRange(level,0,6)} = 0
    zap (1,1) matlab.lang.OnOffSwitchState = "off"
end

% Read from file
parser = matlab.io.xml.dom.Parser();
parser.Configuration.AllowDoctype = true;
doc = parser.parseFile( filename );

% Find all headings and divs
allHeadings = cell( level, 1 ); % preallocate
for ii = 1:level
    allHeadings{ii} = elements( doc.getElementsByTagName( "h"+ii ) );
end
allDivs = elements( doc.getElementsByTagName( "div" ) );

from = doc.getDocumentElement;
while ~isempty( from )
    to = getNextHeading( from, allHeadings );
    if isempty( to )
        divs = allDivs(isAfter( allDivs, from ));
    else
        divs = allDivs(isBetween( allDivs, from, to ));
    end
    from = to;
end

end

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