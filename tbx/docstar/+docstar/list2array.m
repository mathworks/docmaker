function elements = list2array( nodeList )
%list2array  Convert node list to element array
%
%   e = docstar.list2array(n) converts the node list n to an element array
%   e.
%
%   Node lists are unstable, so moving nodes around in a document can
%   affect the order in the list.  Element arrays in contrast are stable,
%   and so more suitable for iteration.

%   Copyright 2020-2024 The MathWorks, Inc.

arguments
    nodeList (1,1) matlab.io.xml.dom.NodeList
end

elements = matlab.io.xml.dom.Element.empty( 0, 1 ); % in case n is empty
for ii = 1:nodeList.Length
    elements(ii) = nodeList.node( ii );
end
elements = elements(:); % return column vector

end % list2array