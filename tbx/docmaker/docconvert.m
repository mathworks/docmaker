function varargout = docconvert( sMd, options )
%docstarconvert  Convert Markdown documents to HTML
%
%   docstarconvert(md) converts the Markdown document(s) md to HTML.  md can
%   be a char or string including wildcards, a cellstr or string array, or
%   a dir struct.
%
%   Multiple documents can also be specified as docstarconvert(md1,md2,...).
%
%   docstarconvert(...,"Theme",t) sets the theme t.  Available themes are
%   "light", "dark", and "auto" (responsive, default).
%
%   docstarconvert(...,"Stylesheets",css) includes the stylesheet(s) css.
%
%   docstarconvert(...,"Scripts",js) includes the script(s) js.  Scripts are
%   included at the end of the body in the order specified to ensure that
%   the HTML content is loaded and rendered before the scripts run.
%
%   docstarconvert(...,"Root",r) publishes to the root folder r, placing
%   stylesheets and scripts in the subfolder "resources".  The root folder
%   must be a common ancestor of the Markdown documents.  If not specified,
%   the root folder is the lowest common ancestor.
%
%   files = docstarconvert(...) returns the names of the files created.
%
%   See also: docstarindex, docstarrun, docstardelete

%   Copyright 2020-2024 The MathWorks, Inc.

arguments ( Repeating )
    sMd
end

arguments
    options.Theme (1,1) string {mustBeMember(options.Theme,["light","dark","auto"])} = "auto"
    options.Stylesheets (1,:) string {mustBeFile}
    options.Scripts (1,:) string {mustBeFile}
    options.Root (1,1) string {mustBeFolder}
end

% Initialize output
oFiles = strings( 0, 1 );

% Check documents
sMd = docmaker.dir( sMd{:} );
assert( all( docmaker.extensions( sMd ) == ".md" ), ...
    "docstar:InvalidArgument", ...
    "Markdown files must all have extension .md." )
if isempty( sMd ), return, end

% Check root
pMd = reshape( {sMd.folder}, size( sMd ) );
if isfield( options, "Root" )
    sRoot = dir( options.Root );
    pRoot = sRoot(1).folder; % absolute path
    assert( isequal( superfolder( pRoot, pMd{:} ), pRoot ), ...
        "docstar:InvalidArgument", ...
        "Markdown files must be under folder %s.", pRoot )
else
    pRoot = superfolder( pMd{:} );
end

% Folders
pTem = fullfile( fileparts( mfilename( 'fullpath' ) ), 'resources' );
pRez = fullfile( pRoot, 'resources' );
if ~isfolder( pRez ), mkdir( pRez ), end

% Check and copy stylesheets
switch options.Theme
    case "auto"
        nGmd = "github-markdown.css";
    otherwise
        nGmd = "github-markdown-" + options.Theme + ".css";
end
sCss = docmaker.dir( fullfile( pTem, [nGmd "matlaby.css" "copycode.css"] ) );
if isfield( options, "Stylesheets" )
    sCss = docmaker.dir( sCss, options.Stylesheets );
    assert( all( docmaker.extensions( sCss ) == ".css" ), ...
        "docstar:InvalidArgument", ...
        "Stylesheets must all have extension .css." )
end
for ii = 1:numel( sCss )
    copyfile( fullfile( sCss(ii).folder, sCss(ii).name ), pRez )
    fprintf( 1, "[+] %s\n", fullfile( pRez, sCss(ii).name ) );
end
copyfile( fullfile( pTem, "license" ), pRez )
fprintf( 1, "[+] %s\n", fullfile( pRez, "license" ) );
fCss = reshape( fullfile( pRez, {sCss.name} ), size( sCss ) );

% Check and copy scripts
sJs = docmaker.dir( fullfile( pTem, "copycode.js" ) );
if isfield( options, "Scripts" )
    sJs = docmaker.dir( options.Scripts );
    assert( all( docmaker.extensions( sJs ) == ".js" ), ...
        "docstar:InvalidArgument", ...
        "Scripts must all have extension .js." )
end
for ii = 1:numel( sJs )
    copyfile( fullfile( sJs(ii).folder, sJs(ii).name ), pRez )
    fprintf( 1, "[+] %s\n", fullfile( pRez, sJs(ii).name ) );
end
fJs = reshape( fullfile( pRez, {sJs.name} ), size( sJs ) );

% Publish
writer = matlab.io.xml.dom.DOMWriter();
writer.Configuration.XMLDeclaration = false;
writer.Configuration.FormatPrettyPrint = false;
for ii = 1:numel( sMd ) % loop over files
    fMd = fullfile( sMd(ii).folder, sMd(ii).name );
    [pMd, nMd, ~] = fileparts( fMd );
    fHtml = fullfile( pMd, nMd + ".html" );
    doc = convert( fMd, fCss, fJs );
    writer.writeToFile( doc, fHtml, "utf-8" )
    fprintf( 1, "[+] %s\n", fHtml );
    oFiles(end+1,:) = fHtml; %#ok<AGROW>
end

% Return output
if nargout > 0
    varargout{1} = oFiles;
end

end % docstarconvert

function doc = convert( fMd, fCss, fJs )
%convert  Convert Markdown document to HTML with stylesheets and scripts
%
%  convert(md,css,js) converts the Markdown file md to HTML and includes
%  references to the stylesheets css and scripts js.

% Read Markdown from file
pMd = fileparts( fMd );
md = fileread( fMd );

% Convert Markdown to XML
xml = docmaker.md2xml( md );

% Replace Markdown links
docmaker.linkrep( xml, ".md", ".html" )

% Create document
doc = matlab.io.xml.dom.Document( "html", "html", "", "" );
root = getDocumentElement( doc );

% Add header
head = createElement( doc, "head" );
appendChild( root, head );

% Add generator
generator = createElement( doc, "meta" );
v = ver( "docstar" );
generator.setAttribute( "name", "generator" );
generator.setAttribute( "content", "MATLAB " + matlabRelease().Release + ...
    " with " + v(1).Name + " " + v(1).Version );
appendChild( head, generator );

% Add charset
charset = createElement( doc, "meta" );
charset.setAttribute( "charset", "utf-8" );
appendChild( head, charset );

% Add title
h1 = docmaker.list2array( getElementsByTagName( xml, "h1" ) );
if ~isempty( h1 )
    title = doc.createElement( "title" );
    head.appendChild( title );
    titleText = doc.createTextNode( docmaker.rmemoji( h1(1).TextContent ) );
    title.appendChild( titleText );
end

% Add stylesheets
for ii = 1:numel( fCss )
    rCss = relpath( pMd, fCss{ii} );
    rCss = strrep( rCss, filesep, "/" );
    link = createElement( doc, "link" );
    link.setAttribute( "rel", "stylesheet" );
    link.setAttribute( "href", rCss );
    appendChild( head, link );
end

% Add body
body = createElement( doc, "body" );
body.setAttribute( "class", "markdown-body" )
appendChild( root, body );

% Add main
main = createElement( doc, "main" );
main.setAttribute( "class", "markdown-body" ) % for embedding in <template>
appendChild( body, main );

% Add converted Markdown
div = importNode( doc, getDocumentElement( xml ), true );
appendChild( main, div );

% Remove permalinks (anchors with attribute "aria-label" starting with
% "Permalink: ")
anchors = docmaker.list2array( doc.getElementsByTagName( "a" ) );
for ii = 1:numel( anchors )
    anchor = anchors(ii);
    if anchor.hasAttribute( "aria-label" ) && startsWith( ...
            anchor.getAttribute( "aria-label" ), "Permalink: " )
        anchor.getParentNode().removeChild( anchor );
    end
end

% Add scripts
for ii = 1:numel( fJs )
    rJs = relpath( pMd, fJs{ii} );
    rJs = strrep( rJs, filesep, "/" );
    script = createElement( doc, "script" );
    script.setAttribute( "src", rJs );
    script.TextContent = "//"; % comment, not empty
    appendChild( body, script );
end

end % convert

function r = relpath( d, f )
%relpath  Relative path from folder to file
%
%   r = relpath(d,f) returns the relative path r from the folder d to the
%   file f.  The folder and file must exist, and can be specified as
%   absolute or relative (with respect to the current folder) paths.

% Canonicalize
assert( isfolder( d ), "docstar:NotFound", "Folder ""%s"" not found.", d )
sd = dir( d );
pd = string( sd(1).folder ); % first entry is "."
assert( isfile( f ), "docstar:NotFound", "File ""%s"" not found.", f )
sf = dir( f );
pf = string( sf(1).folder ); % single matching entry
nf = string( sf(1).name ); % single matching entry

% Find common ancestor folder
ps = superfolder( pd, pf );
if isequal( ps, [] )
    r = fullfile( pf, nf ); % absolute
else
    tp = split( pd, filesep );
    tf = split( pf, filesep );
    ts = split( ps, filesep );
    up = repmat( "..", numel( tp ) - numel( ts ), 1 ); % go up
    dn = tf(numel( ts )+1:end,:); % then down
    r = fullfile( join( up, filesep ), join( dn, filesep ), nf );
end

% Return matching datatype
if ischar( d ) && ischar( f ), r = char( r ); end

end % relpath

function s = superfolder( varargin )
%superfolder  Common ancestor folder
%
%   s = superfolder(p1,p2,...) returns the common ancestor of the folders
%   p1, p2, ...  The folders must exist.  If there is no common ancestor
%   then superfolder returns [].

% Check inputs
narginchk( 1, Inf )
dd = string( varargin );

% Canonicalize using dir
for ii = 1:numel( dd )
    d = dd(ii);
    assert( isfolder( d ), "docstar:NotFound", "Folder ""%s"" not found.", d )
    sd = dir( d );
    dd(ii) = sd(1).folder; % first entry is "."
end

% Loop, split, compare
s = dd(1); % initialize
for ii = 2:numel( dd )
    d = dd(ii);
    ts = split( s, filesep ); % split
    td = split( d, filesep ); % split
    n = min( numel( ts ), numel( td ) ); % comparable length
    tf = ts(1:n) == td(1:n); % compare
    i = find( tf == false, 1, "first" ); % first non-match
    if i == 1 % immediate non-match
        s = [];
        return
    elseif isempty( i ) % full match
        s = join( ts(1:n), filesep );
    else % partial match
        s = join( ts(1:i-1), filesep );
    end
end

% Return matching datatype
if iscellstr( varargin ), s = char( s ); end %#ok<ISCLSTR>

end % superfolder