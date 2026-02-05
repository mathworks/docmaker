function addclass( e, n )
%docmaker.addclass  Add class to XML element
%
%   docmaker.addclass(e,c) adds the class c to the element e.

%   Copyright 2024-2026 The MathWorks, Inc.

arguments
    e (1,1) matlab.io.xml.dom.Element
    n (1,1) string
end

if e.hasAttribute( "class" )
    o = e.getAttribute( "class" ); % existing class(es)
    o = string( o );
    o = strsplit( o, " " );
    if ~ismember( n, o )
        e.setAttribute( "class", strjoin( [o, n], " " ) );
    end
else
    e.setAttribute( "class", n );
end

end % addclass