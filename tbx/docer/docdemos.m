function docdemos( scripts )
%docdemos  Run script and capture output
%
%  docdemos(s)



end

function docdemo( script )

oldDir = pwd;
[paths, names, ~] = fileparts( script );
if isempty( paths ), paths = oldDir; end
oldFigures = figures(); % existing figures
try
    cd( paths )
    run() % run script
    newFigures = setdiff( figures(), oldFigures ); % new figures
    for ii = 1:numel( newFigures )
        grab( newFigures(ii), string( names ) + ii + ".png" ) % capture
    end
    delete( setdiff( figures(), oldFigures ) ) % clean up
    cd( oldDir )
catch e
    delete( setdiff( figures(), oldFigures ) ) % clean up
    cd( oldDir )
    rethrow( e )
end

end % docdemos

function f = figures()
%figures  Find all figures
%
%  f = figures() returns all current figures in ascending number order.

f = findobj( groot(), '-Depth', 1, 'Type', 'figure', ...
    'HandleVisibility', 'on' ); % ignore HandleVisibility 'off'
n = cell2mat( get( f, 'Number' ) ); % figure numbers
[~, i] = sort( n, 'ascend' ); % sort ascending
f = f(i); % return in ascending order of figure number

end % figure

function run()
%run  Run script
%
%  run() runs a script in a clean workspace.  The script name is the value
%  of the variable 'n' in the caller workspace.

eval( evalin( 'caller', 'n' ) ) % run in clean workspace

end % run

function grab( f, png, wh, res )
%grab  Capture figure to file
%
%  grab(f,png) prints the figure f to the filename png.
%
%  grab(...,wh,r) specifies the figure width and height wh and the printing
%  resolution r.

arguments
    f (1,1) matlab.ui.Figure
    png (1,1) string
    wh (1,2) double = [400 300]
    res (1,1) double = 144
end

w = warning( "off", "MATLAB:print:ExcludesUIInFutureRelease" ); % suppress
f.Position(3:4) = wh;
drawnow()
print( f, png, "-dpng", "-r" + res ) % save
warning( w ) % restore

end % grab