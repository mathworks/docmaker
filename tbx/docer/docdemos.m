function docdemos( scripts, options )
%docdemos  Run scripts and capture output
%
%  docdemos(s) runs the scripts s and captures figure output to PNG files.
%
%  docdemos(...,"Size",wh) sets the size of the output figures to [width
%  height] wh.
%
%  docdemos(...,"Resolution",r) sets the resolution of the screenshots to r
%  dpi.

%  Copyright 2020-2024 The MathWorks, Inc.

arguments
    scripts string
    options.Size (1,2) double {mustBePositive} = [400 300]
    options.Resolution (1,1) double {mustBePositive} = 144
end

% Convert input to dirstruct
scripts = dirstruct( scripts );

% Process
for ii = 1:numel( scripts ) % loop
    try
        docdemo( scripts(ii), options.Size, options.Resolution )
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

end % docdemos

function docdemo( script, wh, res )
%docdemo  Run script and capture output
%
%  docdemo(s,wh,res) runs the script s and captures the output with figure
%  [width height] wh and screenshot resolution r dpi.

oldFolder = pwd;
[~, name, ~] = fileparts( script.name ); %#ok<ASGLU>
oldFigures = figures(); % existing figures
try
    cd( script.folder )
    run() % run script
    newFigures = setdiff( figures(), oldFigures ); % new figures
    for ii = 1:numel( newFigures )
        capture( newFigures(ii), string( names ) + ii + ".png", wh, res ) % capture
    end
    delete( setdiff( figures(), oldFigures ) ) % clean up
    cd( oldFolder )
catch e
    delete( setdiff( figures(), oldFigures ) ) % clean up
    cd( oldFolder )
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
warning( w ) % restore

end % capture