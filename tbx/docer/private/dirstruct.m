function s = dirstruct( p, varargin )
%dirstruct  List folder contents
%
%  s = dirstruct(p) lists the contents of the folder p.  If p is a char
%  or a string then s is dir(p).  If p is a cellstr or a string array then
%  s is the concatenation of the results of calling dir on each element.
%  If p is already a struct returned from dir then it is returned
%  unaltered.
%
%  s = dirstruct(p1,p2,...) is the concatenation of the results of
%  dirstruct(p1), dirstruct(p2), ...
%
%  See also: dir

%  Copyright 2024 The MathWorks, Inc.

% Process first input
narginchk( 1, Inf )
if isstruct( p ) && all( ismember( fieldnames( p ), fieldnames( dir() ) ) )
    s = p(:);
else
    p = cellstr( p );
    s = cell( size( p ) );
    for ii = 1:numel( p )
        s{ii} = dir( p{ii} );
    end
    s = vertcat( s{:} );
end

% Process subsequent inputs
if nargin > 1
    s = [s; dirstruct( varargin{:} )];
end

end % dirstruct