function s = getDefaultFigureSize()
%getDefaultFigureSize  Default figure size

p = get( 0, "DefaultFigurePosition" ); % [x y w h]
s = p(3:4); % [w h]

end % getDefaultFigureSize