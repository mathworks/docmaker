function docerrun( m, options )
%docerrun  Run MATLAB scripts and save generated figures to image files
%
%   docerrun(s) runs the MATLAB script(s) s and saves generated figures to
%   image files.
%
%   docerrun(...,"Size",wh) sets the size of the figures to [width height]
%   wh.
%
%   docerrun(...,"Resolution",r) sets the resolution of the screenshots to
%   r dpi.
%
%   See also: docerconvert, docerindex, docerdelete

%   Copyright 2020-2024 The MathWorks, Inc.

arguments ( Repeating )
    m % convertible to dirstruct
end

arguments
    options.Size (1,2) double {mustBePositive} = [400 300]
    options.Resolution (1,1) double {mustBeNonnegative} = 144
end

% Check inputs
m = docer.dirstruct( m{:} );
assert( all( extensions( m ) == ".m" ), "docer:InvalidArgument", ...
    "MATLAB scripts must all have extension .m." )

% Process
for ii = 1:numel( m ) % loop
    try
        run( m(ii), options.Size, options.Resolution )
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

end % docerrun

function run( script, wh, res )
%run  Run a single MATLAB script and capture output
%
%  run(s,wh,res) runs the script s and captures the output with figure
%  [width height] wh and screenshot resolution r dpi.

oldFolder = pwd;
[~, name, ~] = fileparts( script.name );
oldFigures = figures(); % existing figures
try
    cd( script.folder )
    go() % run script
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

end % run

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

function go()
%go  Run script
%
%  go() runs a script in a clean workspace.  The script name is the value
%  of the variable 'name' in the caller workspace.

eval( evalin( 'caller', 'name' ) ) % run in clean workspace

end % go

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