function fixdoc( doc )
%xhtmltidy  Tidy up XHTML
%
%   xhtmltidy(doc) tidies the document doc by:
%   * removing empty <a>, <span> and <div> tags

%   Copyright 2024 The MathWorks, Inc.

fixpermalinks( doc )

end % xhtmltidy

function fixpermalinks( doc )
%fixpermalinks  Fix permalinks
%
%   fixpermalinks(doc) fixes permalinks in the document doc.

for ii = 1:6
    headings = doc.getElementsByTagName( "h"+ii ); % find
    headings = nodelist2array( headings ); % stable
    for jj = 1:numel( headings )
        heading = headings(jj);
        fixpermalink( heading )
    end
end

end

function fixpermalink( heading )
%fixpermalink  Fix permalink
%
%   fixpermalink(h) fixes the permalink for the heading h.  Sibling anchors
%   of the heading are moved under the heading, and the 

% Find parent
div = heading.getParentNode();
if div.TagName ~= "div", return, end

% Find, fix, and move
anchors = div.getElementsByTagName( "a" ); % find
anchors = nodelist2array( anchors ); % stable
for ii = 1:numel( anchors )
    anchor = anchors(ii);
    if anchor.hasAttribute( "class" ) && anchor.getAttribute( "class" ) == "anchor"
        if anchor.hasAttribute( "id" ) && anchor.hasAttribute( "href" )
            id = string( anchor.getAttribute( "id" ) );
            href = string( anchor.getAttribute( "href" ) );
            if startsWith( id, "user-content-" ) && startsWith( href, "#" ) && ...
                    extractAfter( id, "user-content-" ) == extractAfter( href, "#" )
                anchor.setAttribute( "id", extractAfter( href, "#" ) );
            end
        end
        heading.appendChild( anchor ); % move
    end
end

end % fixpermalink

function o = nodelist2array( n )
%nodelist2array  Convert node list to object array
%
%   o = nodelist2array(n) converts the node list n to the object array o.
%   Node lists are unstable whereas object arrays are stable.

o = matlab.io.xml.dom.Element.empty( [1 0] ); % preallocate
for ii = 1:n.Length
    o(ii) = n.node( ii );
end

end % nodelist2array

function rmempty( doc, tags )
%rmempty  Remove tags with no contents
%
%   This is a multipass operation, since removing a tag may empty its
%   parent, and so on.

done = false; % initialize
while done == false
    done = true; % unless more empty
    for ii = 1:numel( tags )
        tag = tags(ii);
        elements = getElementsByTagName( doc, tag ); % matching
        for jj = elements.Length:-1:1 % backwards
            element = elements.item( jj-1 );
            if isempty( element.Children ) % empty
                removeChild( getParentNode( element ), element ); % remove
                done = false; % another pass
            end
        end % elements
    end % tags
end % while

end % rmempty