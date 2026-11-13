function s = getDefaultFigureSize()
%getDefaultFigureSize  Default figure size
%
%   Copyright 2026 The MathWorks, Inc.

p = get( 0, "DefaultFigurePosition" ); % [x y w h]
s = p(3:4); % [w h]

end % getDefaultFigureSize