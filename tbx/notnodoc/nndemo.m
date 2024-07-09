function nndemo( s )
%nndemo  Run script and capture output

d = pwd;
[p, n, x] = fileparts( s );
if isempty( p ), p = d; end
o = figures(); % existing figures
try
    cd( p )
    run() % run script
    t = setdiff( figures(), o ); % new figures
    for ii = 1:numel( t )
        capture( t(ii), string( n ) + ii + x ) % capture
    end
    delete( setdiff( figures(), o ) ) % clean up
    cd( d )
catch e
    delete( setdiff( figures(), o ) ) % clean up
    cd( d )
    rethrow( e )
end

end % nndemo

function f = figures()
%figures  Find all figures

f = findobj( groot, '-Depth', 1, 'Type', 'figure', 'HandleVisibility', 'on' );

end % figure

function run()
%run  Run script

eval( evalin( 'caller', 'n' ) ) % run in clean workspace

end % run

function capture( f, filename )
%capture  Capture figure to file

w = warning( 'off', 'MATLAB:print:ExcludesUIInFutureRelease' ); % suppress
f.Position(3:4) = [400 300];
drawnow()
print( f, filename, '-dpng', '-r0' ) % save
warning( w ) % restore

end % capture