function x = capture( fig, res )
%capture  Capture figure
%
%   x = docer.capture(f) captures the figure f to image data x.  First, the
%   figure is printed to an image file, and then, the image data is read
%   from the file.
%
%   x = docer.capture(f,r) captures the figure at a resolution of r dpi.
%   The default resolution is 144 dpi.

arguments
    fig (1,1) matlab.ui.Figure
    res (1,1) double {mustBePositive} = 144
end

fn = tempname() + ".png"; % filename
print( fig, fn, "-dpng", "-r" + res ); % print
x = imread( fn ); % read
delete( fn ) % clean up

end % capture