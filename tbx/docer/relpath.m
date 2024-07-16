function r = relpath( b, p )
%relpath  Relative path
%
%  r = relpath(b,p) returns the relative path r of the path p from the base
%  b.

if ~ischar( p )
    b = string( b );
    s = string( p );
    if isscalar( b ) && ~isscalar( s )
        b = repmat( b, size( s ) );
    elseif ~isscalar( b ) && isscalar( s )
        s = repmat( s, size( b ) );
    end
    r = strings( size( s ) );
    for ii = 1:numel( s )
        r(ii) = relpath( char( b(ii) ), char( s(ii) ) );
    end
    if iscellstr( p ) %#ok<ISCLSTR>
        r = cellstr( r );
    else
        r = feval( class( p ), r );
    end
else
    try
        r = s_relpath( b, p );
    catch
        error( "docer:Path", "Invalid path ""%s"".", p )
    end
    if ~isequal( class( r ), class( p ) )
        r = feval( class( p ), r ); % cast
    end
end

end % relpath

function r = s_relpath( b, p )
%s_relpath  Implementation for scalar relpath

arguments
    b char
    p char
end

r = System.IO.Path.GetRelativePath( b, p ); % .NET

end % s_relpath