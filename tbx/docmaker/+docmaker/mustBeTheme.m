function mustBeTheme( theme )
%mustBeTheme  Validation function for optional named argument Theme
%
%   Copyright 2026 The MathWorks, Inc.

themes = ["none","light","dark","auto"];
assert( ( ischar( theme ) && ismember( theme, themes ) ) || ...
    ( isstring( theme ) && isscalar( theme ) && ismember( theme, themes ) ) || ...
    ( isa( theme, "matlab.graphics.theme.GraphicsTheme" ) && isscalar( theme ) ), ...
    "Theme must be ""none"", ""light"", ""dark"", ""auto"", or a GraphicsTheme." )

end % mustBeTheme
