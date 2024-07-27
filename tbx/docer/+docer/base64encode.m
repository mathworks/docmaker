function s = base64encode( f, o )
%base64encode  Perform Base 64 encoding of a figure
%
%   s = docer.base64encode(f) prints the figure f to file, encodes the file
%   data using Base 64 encoding, and returns the encoded data as a string
%   s.
%
%   s = docer.base64encode(...,"Resolution",r) sets the resolution of the
%   screenshots to r dpi.
%
%   See also: matlab.net.base64encode

%   Copyright 2024 The MathWorks, Inc.

arguments
    f (1,1) matlab.ui.Figure
    o.Resolution (1,1) double {mustBeNonnegative} = 144
end

% Suppress warning
w = warning( "off", "MATLAB:print:ExcludesUIInFutureRelease" ); % suppress
cu = onCleanup( @()warning( w ) ); % restore

% Write to file
drawnow()
fIm = tempname() + ".png";
print( f, fIm, "-dpng", "-r" + o.Resolution ) % save

% Read from file
hIm = fopen( fIm, "r" );
bin = fread( hIm, "uint8=>uint8" );
fclose( hIm );

% Clean up file
delete( fIm )

% Convert
s = matlab.net.base64encode( bin );
s = string( s );

end % base64encode