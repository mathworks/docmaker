function nndemos( s )
%nndemos  Run script and capture output

d = pwd;
[p, n, ~] = fileparts( s );
if isempty( p ), p = d; end
o = figures(); % existing figures
try
    cd( p )
    run() % run script
    t = setdiff( figures(), o ); % new figures
    for ii = 1:numel( t )
        grab( t(ii), string( n ) + ii + ".png" ) % capture
    end
    delete( setdiff( figures(), o ) ) % clean up
    cd( d )
catch e
    delete( setdiff( figures(), o ) ) % clean up
    cd( d )
    rethrow( e )
end

end % nndemos

function f = figures()
%figures  Find all figures

f = findobj( groot, '-Depth', 1, 'Type', 'figure', 'HandleVisibility', 'on' );

end % figure

function run()
%run  Run script

eval( evalin( 'caller', 'n' ) ) % run in clean workspace

end % run

function grab( f, filename )
%grab  Capture figure to file

w = warning( 'off', 'MATLAB:print:ExcludesUIInFutureRelease' ); % suppress
f.Position(3:4) = [400 300];
drawnow()
print( f, filename, '-dpng', '-r144' ) % save
warning( w ) % restore

end % grab