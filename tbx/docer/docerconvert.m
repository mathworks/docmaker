function docerconvert( sMd, options )
%docerconvert  Publish Markdown files to HTML with stylesheets and scripts
%
%  docerconvert(md) publishes the Markdown files md to HTML.  md can be a
%  char or string including wildcards, a cellstr or string array, or a dir
%  struct.
%
%  docerconvert(...,"Stylesheets",css) includes the stylesheet(s) css.
%  Stylesheets "github-markdown.css" and "matlaby.css" are always included.
%
%  docerconvert(...,"Scripts",js) includes the script(s) js.
%
%  docerconvert(...,"Root",f) publishes to the root folder f, placing
%  resources in <f>/resources.  If not specified, then the root folder is
%  the lowest superdirectory of the published files.
%
%  See also: md2html, docerrun, docerreg, undocer

%  Copyright 2020-2024 The MathWorks, Inc.

arguments
    sMd
    options.Stylesheets (1,:) string {mustBeFile}
    options.Scripts (1,:) string {mustBeFile}
    options.Root (1,1) string {mustBeFolder}
end

% Check documents
sMd = dirstruct( sMd );
assert( all( extensions( sMd ) == ".md" ), ...
    "docer:InvalidArgument", ...
    "Markdown files must all have extension .md." )
if isempty( sMd ), return, end

% Check root
if isfield( options, "Root" )
    sRoot = dir( options.Root );
    pRoot = sRoot(1).folder; % absolute path
    assert( startsWith( superdir( sMd ), pRoot ), ...
        "docer:InvalidArgument", ...
        "Markdown files must be under folder %s.", pRoot )
else
    pRoot = superdir( sMd );
end

% Folders
pTem = fullfile( fileparts( mfilename( 'fullpath' ) ), 'resources' );
pRez = fullfile( pRoot, 'resources' );
if ~isfolder( pRez ), mkdir( pRez ), end

% Check stylesheets
sCss = dirstruct( fullfile( pTem, ["github-markdown-light.css" "matlaby.css"] ) );
if isfield( options, "Stylesheets" )
    sCss = dirstruct( sCss, options.Stylesheets );
    assert( all( extensions( sCss ) == ".css" ), ...
        "docer:InvalidArgument", ...
        "Stylesheets must all have extension .css." )
end

% Check scripts
if isfield( options, "Scripts" )
    sJs = dirstruct( options.Scripts );
    assert( all( extensions( sJs ) == ".js" ), ...
        "docer:InvalidArgument", ...
        "Scripts must all have extension .js." )
else
    sJs = repmat( dir( "." ), [0 1] );
end

% Publish
w = matlab.io.xml.dom.DOMWriter();
w.Configuration.XMLDeclaration = false;
w.Configuration.FormatPrettyPrint = false;
for ii = 1:numel( sMd ) % loop over files
    fMd = fullfile( sMd(ii).folder, sMd(ii).name ); % this file
    [pHtml, nHtml, ~] = fileparts( fMd );
    fHtml = fullfile( pHtml, nHtml + ".html" );
    try
        doc = convert( fMd, pRez, sCss, sJs );
        writeToFile( w, doc, fHtml )
        fprintf( 1, "[+] %s\n", fHtml );
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

end % docerconvert

function doc = convert( fMd, pRez, css, js )

% Read Markdown from file
pMd = fileparts( fMd );
md = fileread( fMd );

% Convert Markdown to XML
frag = md2xml( md );
linkrep( frag, ".html" )

% Create document
doc = matlab.io.xml.dom.Document( "html", "html", "", "" );
root = getDocumentElement( doc );

% Add header
head = createElement( doc, "head" );
appendChild( root, head );

% Add generator
meta = createElement( doc, "meta" );
appendChild( head, meta );
v = ver( "docer" );
meta.setAttribute( "generator", "MATLAB " + matlabRelease().Release + ...
    " with " + v(1).Name + " " + v(1).Version );

% Add title
h1 = getElementsByTagName( frag, "h1" );
if h1.Length > 0
    title = createElement( doc, "title" );
    appendChild( head, title );
    title.TextContent = h1.item( 0 ).TextContent;
end

% Add stylesheets
for ii = 1:numel( css )
    fCss = fullfile( css(ii).folder, css(ii).name );
    [~, nCss, eCss] = fileparts( fCss );
    copyfile( fCss, pRez )
    rCss = relpath( fullfile( pRez, [nCss eCss] ), pMd );
    rCss = strrep( rCss, filesep, '/' );
    link = createElement( doc, "link" );
    appendChild( head, link );
    link.setAttribute( "rel", "stylesheet" );
    link.setAttribute( "href", rCss );
end

% Add scripts
for ii = 1:numel( js )
    fJs = fullfile( js(ii).folder, js(ii).name );
    [~, nJs, eJs] = fileparts( fJs );
    copyfile( fJs, pRez )
    rJs = relpath( fullfile( pRez, [nJs eJs] ), pMd );
    rJs = strrep( rJs, filesep(), '/' );
    script = createElement( doc, "script" );
    appendChild( head, script );
    script.setAttribute( "src", rJs );
end

% Add body
body = createElement( doc, "body" );
body.setAttribute( "class", "markdown-body" )
body.setAttribute( "style", "margin-left: 1em; margin-right: 1em;" )
appendChild( root, body );

% Add main
main = createElement( doc, "main" );
appendChild( body, main );

% Add converted Markdown
div = importNode( doc, getDocumentElement( frag ), true );
appendChild( main, div );

end % convert

function rTo = relpath( fTo, pFr )
%relpath  Compute relative path to a file from a folder
%
%  r = relpath(f,t) computes the relative path to the file t from the
%  *folder* f.
%
%  Examples:
%    relpath('C:\a\b\x','C:\a\b\y') returns '.\y'.
%    relpath('C:\a\b\x','C:\a\b\c\y') returns '.\c\y'.
%    relpath('C:\a\b\c\y','C:\a\b\x') returns '.\..\x'.
%    relpath('C:\a\b\c','D:\x\y\z') returns 'D:\x\y\z'.

pSu = superdir( fullfile( pFr, '.' ), fTo ); % superdirectory
if isempty( pSu ) % no superdirectory, return absolute path
    rTo = fTo;
else % superdirectory, go up then down
    rTo = '.'; % initialize
    while ~strcmp( pFr, pSu )
        rTo = fullfile( rTo, '..' ); % up
        pFr = fileparts( pFr ); % up
    end
    if strcmp( pSu, fileparts( pSu ) ) % root, includes separator
        rTo = fullfile( rTo, extractAfter( fTo, pSu ) );
    else % not root
        rTo = horzcat( rTo, extractAfter( fTo, pSu ) );
    end
end

end % relpath

function d = superdir( varargin )
%superdir  Find lowest common superdirectory
%
%  d = superdir(f) finds the lowest common superdirectory for the file list
%  f. f can be specified as a char or string, a cellstr or string array, or
%  a dir struct.
%
%  If f is empty, or if the elements of f have no common superdirectory,
%  then [] is returned.
%
%  d = superdir(f1,f2,...) is also supported for chars and strings.
%
%  Examples:
%    superdir('C:\a\b\x','C:\a\b\y') returns 'C:\a\b'.
%    superdir('C:\a\x','C:\a\b\y') returns 'C:\a'.
%    superdir('C:\a\b\c','D:\x\y\z') returns [].

% Handle inputs
switch nargin
    case 1
        if isstruct( varargin{:} ) % dir struct
            f = varargin{:}; % unpack
            p = reshape( {f.folder}, size( f ) ); % extract folders
            n = reshape( {f.name}, size( f ) ); % extract folders
            f = fullfile( p, n ); % combine
        else % something else, convert
            f = cellstr( varargin{:} );
        end
    otherwise
        f = cellstr( varargin );
end

% Find ancestor
if isempty( f ) % degenerate
    d = [];
else % normal
    d = fileparts( f{1} ); % initialize
    for ii = 1:numel( f )
        while( ~strncmp( f{ii}, d, numel( d ) ) ) % compare first parts
            if strcmp( d, fileparts( d ) ), d = []; return; end % root, stop
            d = fileparts( d ); % up
        end
    end
end

end % superdir