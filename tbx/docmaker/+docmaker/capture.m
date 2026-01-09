function x = capture( fig )
%capture  Capture figure
%
%   x = docmaker.capture(f) captures the figure f to image data x.
%
%   See also: getframe

%   Copyright 2024-2026 The MathWorks, Inc.

arguments
    fig (1,1) matlab.ui.Figure
end

% Hide axes toolbars
ax = findobj( fig, "Type", "axes" );
tf = true( size( ax ) );
for ii = 1:numel( ax )
    tf(ii) = ax(ii).Toolbar.Visible;
    ax(ii).Toolbar.Visible = false;
end

% Capture
[x, ~] = getframe( fig );

% Restore axes toolbars
for ii = 1:numel( ax )
    ax(ii).Toolbar.Visible = tf(ii);
end

end % capture