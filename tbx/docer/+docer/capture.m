function x = capture( fig )
%capture  Capture figure
%
%   x = docer.capture(f) captures the figure f to image data x.

%   Copyright 2024 The MathWorks, Inc.

arguments
    fig (1,1) matlab.ui.Figure
end

[x, ~] = getframe( fig );

end % capture