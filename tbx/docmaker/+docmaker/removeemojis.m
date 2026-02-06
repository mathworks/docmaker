function s = removeemojis( s )
%removeemojis  Remove emojis from string
%
%   s = docmaker.removeemojis(s) removes emojis from the string s.
%
%   Emojis are strings that begin and end with ":" with letters, numbers
%   and underscores in between, and Unicode characters from U+2130.

%   Copyright 2024-2026 The MathWorks, Inc.

arguments
    s (1,1) string
end

% Remove :[a-zA-Z0-9_]*:
p = ":" + asManyOfPattern( alphanumericsPattern(1) | "_", 1 ) + ...
    ":" + optionalPattern( asManyOfPattern( whitespacePattern ) );
e = extract( s, p );
s = erase( s, e );
s = strtrim( s );

% Remove Unicode U+2130 and above
c = char( s );
c(c>=hex2dec( "2130" )) = hex2dec( "2130" );
s = string( c );
p = asManyOfPattern( characterListPattern( char( 8496 ) ), 1 ) + ...
    optionalPattern( asManyOfPattern( whitespacePattern ) );
e = extract( s, p );
s = erase( s, e );
s = strtrim( s );

end % removeemojis