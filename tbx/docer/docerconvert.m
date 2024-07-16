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
%  the superfolder of the published files.
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
pMd = reshape( {sMd.folder}, size( sMd ) );
if isfield( options, "Root" )
    sRoot = dir( options.Root );
    pRoot = sRoot(1).folder; % absolute path
    assert( isequal( superfolder( pRoot, pMd{:} ), pRoot ), ...
        "docer:InvalidArgument", ...
        "Markdown files must be under folder %s.", pRoot )
else
    pRoot = superfolder( pMd{:} );
end

% Folders
pTem = fullfile( fileparts( mfilename( 'fullpath' ) ), 'resources' );
pRez = fullfile( pRoot, 'resources' );
if ~isfolder( pRez ), mkdir( pRez ), end

% Check and copy stylesheets
sCss = dirstruct( fullfile( pTem, ["github-markdown-light.css" "matlaby.css"] ) );
if isfield( options, "Stylesheets" )
    sCss = dirstruct( sCss, options.Stylesheets );
    assert( all( extensions( sCss ) == ".css" ), ...
        "docer:InvalidArgument", ...
        "Stylesheets must all have extension .css." )
end
for ii = 1:numel( sCss )
    copyfile( fullfile( sCss(ii).folder, sCss(ii).name ), pRez )
    fprintf( 1, "[+] %s\n", fullfile( pRez, sCss(ii).name ) );
    sCss(ii).folder = pRez;
end

% Check and copy scripts
if isfield( options, "Scripts" )
    sJs = dirstruct( options.Scripts );
    assert( all( extensions( sJs ) == ".js" ), ...
        "docer:InvalidArgument", ...
        "Scripts must all have extension .js." )
else
    sJs = repmat( dir( "." ), [0 1] );
end
for ii = 1:numel( sJs )
    copyfile( fullfile( sJs(ii).folder, sJs(ii).name ), pRez )
    fprintf( 1, "[+] %s\n", fullfile( pRez, sJs(ii).name ) );
    sJs(ii).folder = pRez;
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
        doc = convert( fMd, sCss, sJs );
        writeToFile( w, doc, fHtml )
        fprintf( 1, "[+] %s\n", fHtml );
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

end % docerconvert

function doc = convert( fMd, sCss, sJs )

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
for ii = 1:numel( sCss )
    fCss = fullfile( sCss(ii).folder, sCss(ii).name );
    rCss = relpath( pMd, fCss );
    rCss = strrep( rCss, filesep, "/" );
    link = createElement( doc, "link" );
    appendChild( head, link );
    link.setAttribute( "rel", "stylesheet" );
    link.setAttribute( "href", rCss );
end

% Add scripts
for ii = 1:numel( sJs )
    fJs = fullfile( sJs(ii).folder, sJs(ii).name );
    rJs = relpath( pMd, fJs );
    rJs = strrep( rJs, filesep, "/" );
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