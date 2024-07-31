function s = encode( fig )
%encode  Encode image data
%
%   s = docer.encode(f) encodes the figure f to the string s using Base
%   64 encoding.
% 
%   The process consists of 4 steps:
%   1. Capture the image data from the figure
%   2. Write the image data to a temporary file
%   3. Read the file as binary data
%   4. Encode the binary data
%
%   See also: docer.capture

%   Copyright 2024 The MathWorks, Inc.

arguments
    fig (1,1) matlab.ui.Figure
end

% Use PNG file format
format = "png";

% Manage transparency
transparent = isequal( fig.Color, "none" );
if transparent
    c = get( 0, "DefaultFigureColor" );
    fig.Color = c;
    args = {"Transparency", c};
    cu = onCleanup( @()set(fig,"Color","none") );
else
    args = cell( 1, 0 );
end

% Capture
x = docer.capture( fig );

% Write to temporary file
filename = tempname() + "." + format; % filename
imwrite( x, filename, format, args{:} )

% Read from temporary file
f = fopen( filename, "r" ); % open
u = fread( f, "uint8=>uint8" ); % read
fclose( f ); % close

% Encode
s = matlab.net.base64encode( u ); % encode
s = string( s ); % convert

end % encode