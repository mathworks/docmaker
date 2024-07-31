function tidydoc( doc )
%tidydoc  Tidy up document
%
%   tidydoc(doc) tidies the document doc by:
%   * removing permalinks

%   Copyright 2024 The MathWorks, Inc.

% Remove permalinks
rmpermalinks( doc )

end % tidydoc

function rmpermalinks( doc )
%rmpermalinks  Remove permalinks
%
%   rmpermalinks(doc) removes permalinks from the document doc.
%
%   Permalinks are elements with tag name "a" and attribute "aria-label"
%   starting with "Permalink: ".

anchors = doc.getElementsByTagName( "a" );
for ii = anchors.Length:-1:1 % backwards
    anchor = anchors.node( ii );
    if anchor.hasAttribute( "aria-label" ) && startsWith( ...
            anchor.getAttribute( "aria-label" ), "Permalink: " )
        anchor.getParentNode().removeChild( anchor );
    end
end

end % rmpermalinks