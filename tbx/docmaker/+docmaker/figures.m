function f = figures()
%figures  Find all figures
%
%   f = docmaker.figures() returns all current figures in ascending number
%   order.

%   Copyright 2024-2025 The MathWorks, Inc.

f = findall( groot(), "-Depth", 1, "Type", "figure" ); % all figures
cn = get( f, {"Number"} ); % cell array of figure numbers
cn(cellfun( @isempty, cn )) = {NaN}; % replace missing
n = cell2mat( cn ); % unpack
[~, i] = sort( n, "ascend" ); % sort ascending
f = f(i); % return in ascending order of figure number

end % figures