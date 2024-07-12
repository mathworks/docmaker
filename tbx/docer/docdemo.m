function docdemo( m, options )
%docdemo  Run MATLAB scripts and capture output
%
%  docdemo(s) runs the MATLAB scripts s and captures figure output to PNG
%  files.
%
%  docdemo(...,"Size",wh) sets the size of the output figures to [width
%  height] wh.
%
%  docdemo(...,"Resolution",r) sets the resolution of the screenshots to r
%  dpi.
%
%  See also: docpublish, docregister, undoc

%  Copyright 2020-2024 The MathWorks, Inc.

arguments
    m % convertible to dirstruct
    options.Size (1,2) double {mustBePositive} = [400 300]
    options.Resolution (1,1) double {mustBeNonnegative} = 144
end

% Check inputs
m = dirstruct( m );
assert( all( extensions( m ) == ".m" ), "docer:InvalidArgument", ...
    "MATLAB scripts must all have extension .m." )

% Process
for ii = 1:numel( m ) % loop
    try
        demo( m(ii), options.Size, options.Resolution )
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

end % docdemos

function demo( script, wh, res )
%demo  Run a single MATLAB script and capture output
%
%  demo(s,wh,res) runs the script s and captures the output with figure
%  [width height] wh and screenshot resolution r dpi.

oldFolder = pwd;
[~, name, ~] = fileparts( script.name );
oldFigures = figures(); % existing figures
try
    cd( script.folder )
    run() % run script
    newFigures = setdiff( figures(), oldFigures ); % new figures
    for ii = 1:numel( newFigures )
        capture( newFigures(ii), string( name ) + ii + ".png", wh, res ) % capture
    end
    delete( setdiff( figures(), oldFigures ) ) % clean up
    cd( oldFolder )
catch e
    delete( setdiff( figures(), oldFigures ) ) % clean up
    cd( oldFolder )
    rethrow( e )
end

end % demo

function f = figures()
%figures  Find all figures
%
%  f = figures() returns all current figures in ascending number order.

f = findobj( groot(), "-Depth", 1, "Type", "figure", ...
    "HandleVisibility", "on" ); % ignore HandleVisibility 'off'
n = cell2mat( get( f, {"Number"} ) ); % figure numbers
[~, i] = sort( n, "ascend" ); % sort ascending
f = f(i); % return in ascending order of figure number

end % figure

function run()
%run  Run script
%
%  run() runs a script in a clean workspace.  The script name is the value
%  of the variable 'name' in the caller workspace.

eval( evalin( 'caller', 'name' ) ) % run in clean workspace

end % run

function capture( f, png, wh, res )
%capture  Capture figure to file
%
%  capture(f,png) prints the figure f to the filename png.
%
%  capture(...,wh,r) specifies the figure width and height wh and the
%  printing resolution r.
%
%  See also: print

w = warning( "off", "MATLAB:print:ExcludesUIInFutureRelease" ); % suppress
f.Position(3:4) = wh;
drawnow()
print( f, png, "-dpng", "-r" + res ) % save
fprintf( 1, "[+] %s\n", png );
warning( w ) % restore

end % capture