function s = rmemoji( s )
%rmemoji Remove emojis from string
%
%  s = rmemoji(s) removes emojis from the string s.

%  Emojis are strings that begin and end with ":" with letters, numbers and
%  underscores in between, and Unicode characters from U+2130 to U+1FFFF.

%  Copyright 2024 The MathWorks, Inc.

arguments
    s (1,1) string
end

% Remove :[a-zA-Z0-9_]*:
p = ":" + asManyOfPattern( alphanumericsPattern(1) | "_", 1 ) + ...
    ":" + optionalPattern( asManyOfPattern( whitespacePattern ) );
e = extract( s, p );
s = erase( s, e );
s = strtrim( s );

% Remove Unicode 2130 to 1FFFF
p = asManyOfPattern( characterListPattern( char( 8496:131071 ) ), 1 ) + ...
    optionalPattern( asManyOfPattern( whitespacePattern ) );
e = extract( s, p );
s = erase( s, e );
s = strtrim( s );

end % rmemoji