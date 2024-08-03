function f = figures()
%figures  Find all figures
%
%   f = docer.figures() returns all current figures in ascending number
%   order.

%   Copyright 2024 The MathWorks, Inc.

f = findobj( groot(), "-Depth", 1, "Type", "figure", ...
    "HandleVisibility", "on" ); % ignore HandleVisibility 'off'
cn = get( f, {"Number"} ); % cell array of figure numbers
cn(cellfun( @isempty, cn )) = {NaN}; % replace missing
n = cell2mat( cn ); % unpack
[~, i] = sort( n, "ascend" ); % sort ascending
f = f(i); % return in ascending order of figure number

end % figures