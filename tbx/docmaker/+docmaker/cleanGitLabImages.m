function cleanGitLabImages( doc )
%cleanGitLabImages  Remove GitLab lazy-loading from image elements
%
%   docmaker.cleanGitLabImages(doc) normalizes GitLab Markdown API image
%   output so generated documentation can render without GitLab's web UI
%   JavaScript.

%   Copyright 2026 The MathWorks, Inc.

arguments
    doc (1,1) matlab.io.xml.dom.Document
end

imgs = docmaker.list2array( doc.getElementsByTagName( "img" ) );
for imgIdx = 1:numel( imgs )
    img = imgs(imgIdx);
    if img.hasAttribute( "data-src" )
        img.setAttribute( "src", img.getAttribute( "data-src" ) )
        img.removeAttribute( "data-src" )
    end
    if img.hasAttribute( "decoding" ) && ...
            string( img.getAttribute( "decoding" ) ) == "async"
        img.removeAttribute( "decoding" )
    end
    removeLazyClass( img )
end

end % cleanGitLabImages

function removeLazyClass( img )
%removeLazyClass  Remove the GitLab lazy-load class from an image

if ~img.hasAttribute( "class" )
    return
end

classes = string( strsplit( string( img.getAttribute( "class" ) ), " " ) );
classes(classes == "" | classes == "lazy") = [];
if isempty( classes )
    img.removeAttribute( "class" )
else
    img.setAttribute( "class", strjoin( classes, " " ) )
end

end % removeLazyClass
