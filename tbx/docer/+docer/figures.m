function f = figures()
%figures  Find all figures
%
%   f = docer.figures() returns all current figures in ascending number
%   order.

%   Copyright 2024 The MathWorks, Inc.

f = findobj( groot(), "-Depth", 1, "Type", "figure", ...
    "HandleVisibility", "on" ); % ignore HandleVisibility 'off'
c = get( f, {"Number"} ); % figure numbers
c(cellfun( @isempty, c )) = {NaN};
[~, i] = sort( cell2mat( c ), "ascend" ); % sort ascending
f = f(i); % return in ascending order of figure number

end % figures