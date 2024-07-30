function s = encode( figure )
%encode  Encode image data
%
%   s = docer.encode(f) encodes the figure f to the string s using Base
%   64 encoding.
%
%   First, the figure is captured.  Second, the captured data is written to
%   a temporary image file.  Third, the binary data is read from the file.
%   Fourth, the binary data is encoded.

%   Copyright 2024 The MathWorks, Inc.

arguments
    figure (1,1) matlab.ui.Figure
end

% Use PNG file format
format = "png";

% Manage transparency
transparent = isequal( figure.Color, "none" );
if transparent
    c = get( 0, "DefaultFigureColor" );
    figure.Color = c;
    args = {"Transparency", c};
    cu = onCleanup( @()set(figure,"Color","none") );
else
    args = cell( 1, 0 );
end

% Capture
x = docer.capture( figure );

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