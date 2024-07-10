function s = dirstruct( p, r )
%dirstruct  List folder contents
%
%  s = dirstruct(p) lists the contents of the folder p.  If p is a char
%  or a string then s is dir(p).  If p is a cellstr or a string array then
%  s is the concatenation of the results of calling dir on each element.
%  If p is already a struct returned from dir then it is returned
%  unaltered.
%
%  s = dirstruct(...,r) looks in the folder r if no contents are found
%  initially.
%
%  See also: dir

% Check inputs
if nargin > 1, assert( isfolder( r ), "Folder not found." ), end

% List contents
if isstruct( p ) && all( ismember( fieldnames( p ), fieldnames( dir() ) ) )
    s = p(:);
elseif ischar( p )
    s = dir( p );
    if isempty( s ) && nargin > 1
        s = dir( fullfile( r, p ) );
    end
elseif isstring( p ) || iscellstr( p )
    p = cellstr( p );
    s = cell( size( p ) );
    for ii = 1:numel( p )
        q = p{ii};
        t = dir( q );
        if isempty( t ) && nargin > 1
            t = dir( fullfile( r, q ) );
        end
        s{ii} = t;
    end
    s = vertcat( s{:} );
else
    error( "docer:InvalidArgument", ...
        "Input must be a char or string, a cellstr or string array, or a dir struct." )
end

end % dirstruct