function doc = gitlabhtml2xml( html )
%GITLABHTML2XML - Normalize GitLab HTML as XML
%   DOC = gitlabhtml2xml(HTML) parses GitLab HTML and adjusts its lazy
%   images, empty anchors, and MATLAB code blocks for DocMaker.
%
%   See also html2xml, md2xml

%   Copyright 2026 The MathWorks, Inc.

arguments
    html (1,1) string
end

doc = docmaker.html2xml( html );

% Promote image URLs out of GitLab's lazy-loading attributes.
images = docmaker.list2array( doc.getElementsByTagName( "img" ) );
for ii = 1:numel( images )
    image = images(ii);
    if image.hasAttribute( "data-src" )
        image.setAttribute( "src", image.getAttribute( "data-src" ) )
        image.removeAttribute( "data-src" )
    end
    if image.hasAttribute( "decoding" ) && ...
            string( image.getAttribute( "decoding" ) ) == "async"
        image.removeAttribute( "decoding" )
    end
    removeLazyClass( image )
end

% Remove empty anchors and mark MATLAB blocks for docrun.
anchors = docmaker.list2array( doc.getElementsByTagName( "a" ) );
for ii = 1:numel( anchors )
    anchor = anchors(ii);
    if ~anchor.hasChildNodes
        anchor.getParentNode().removeChild( anchor );
    end
end

pres = docmaker.list2array( doc.getElementsByTagName( "pre" ) );
for ii = 1:numel( pres )
    pre = pres(ii);
    if docmaker.hasclass( pre, "highlight" ) && ...
            docmaker.hasclass( pre, "language-matlab" )
        div = getCodeBlock( pre );
        if ~isempty( div )
            docmaker.addclass( div, "highlight" )
            docmaker.addclass( div, "highlight-source-matlab" )
        end
    end
end

end % gitlabhtml2xml

function removeLazyClass( image )
%removeLazyClass  Remove the GitLab lazy-load class from an image

if ~image.hasAttribute( "class" )
    return
end

classes = string( strsplit( string( image.getAttribute( "class" ) ), " " ) );
classes(classes == "" | classes == "lazy") = [];
if isempty( classes )
    image.removeAttribute( "class" )
else
    image.setAttribute( "class", strjoin( classes, " " ) )
end

end % removeLazyClass

function div = getCodeBlock( element )
%getCodeBlock  Get the GitLab div containing a MATLAB code block

if ~isa( element, "matlab.io.xml.dom.Element" )
    div = [];
elseif element.TagName == "div" && ...
        docmaker.hasclass( element, "markdown-code-block" )
    div = element;
else
    div = getCodeBlock( element.getParentNode() );
end

end % getCodeBlock
