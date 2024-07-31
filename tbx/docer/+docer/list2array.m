function e = list2array( n )
%elements  Convert node list to element array
%
%   e = docer.list2array(n) converts the node list n to an element array e.
%
%   Node lists are unstable, so moving nodes around in a document can
%   affect the order in the list.  Element arrays in contrast are stable,
%   and so more suitable for iteration.

%   Copyright 2020-2024 The MathWorks, Inc.

for ii = 1:n.Length
    e(ii) = n.node( ii ); %#ok<AGROW>
end
e = e(:); % return column vector

end % list2array