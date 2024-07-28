function s = encode( x, fmt )
%encode  Encode image data
%
%   s = docer.encode(x) encodes the image data x to the string s using Base
%   64 encoding.  First, the data is written to an image file, and then,
%   the file contents are encoded.

arguments
    x uint8
    fmt (1,1) string = "png"
end

fn = tempname() + "." + fmt; % filename
imwrite( x, fn ) % serialize
f = fopen( fn, "r" ); % open
u = fread( f, "uint8=>uint8" ); % read
fclose( f ); % close
s = matlab.net.base64encode( u ); % encode
s = string( s ); % convert

end % encode