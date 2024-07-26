function s = encodefig( f, o )
%encodefig  Base 64 encoding of figure
%
%   s = encodefig(f) encodes the figure f using base 64 encoding and
%   returns the encoded data as a string s.

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

end % figuredata