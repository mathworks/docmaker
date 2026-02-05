function tf = hasclass( e, n )
%docmaker.hasclass  Add class to XML element
%
%   docmaker.hasclass(e,c) returns true if the element e has the class c,
%   and false otherwise.

%   Copyright 2024-2026 The MathWorks, Inc.

arguments
    e (1,1) matlab.io.xml.dom.Element
    n (1,1) string
end

if e.hasAttribute( "class" )
    o = e.getAttribute( "class" ); % existing classes
    o = string( o );
    o = strsplit( o, " " );
    tf = ismember( n, o );
else
    tf = false;
end

end % hasclass