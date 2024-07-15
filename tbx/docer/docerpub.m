function varargout = docerpub( md, options )
%docerpub  Publish Markdown files to HTML with stylesheets and scripts
%
%  docerpub(md) publishes the Markdown files md to HTML.  md can be a
%  char or string including wildcards, a cellstr or string array, or a dir
%  struct.
%
%  docerpub(...,"Stylesheets",css) includes the stylesheet(s) css.
%  Stylesheets "github-markdown.css" and "matlaby.css" are always included.
%
%  docerpub(...,"Scripts",js) includes the script(s) js.  Script
%  "md2html.js" is always included.
%
%  docerpub(...,"Root",f) publishes to the root folder f, placing resources
%  in <f>/resources.  If not specified, then the root folder is the lowest
%  superdirectory of the published files.
%
%  See also: md2html, docerrun, docerreg, undocer

%  Copyright 2020-2024 The MathWorks, Inc.

arguments
    md
    options.Stylesheets (1,:) string {mustBeFile}
    options.Scripts (1,:) string {mustBeFile}
    options.Root (1,1) string {mustBeFolder}
end

% Local resources folder
res = fullfile( fileparts( mfilename( 'fullpath' ) ), 'resources' );

% Check documents
md = dirstruct( md );
assert( all( extensions( md ) == ".md" ), "docer:InvalidArgument", ...
    "Markdown files must all have extension .md." )

% Check stylesheets
css = dirstruct( fullfile( res, ["github-markdown-light.css" "matlaby.css"] ) );
if isfield( options, "Stylesheets" )
    css = dirstruct( css, options.Stylesheets );
end
assert( all( extensions( css ) == ".css" ), "docer:InvalidArgument", ...
    "Stylesheets must all have extension .css." )

% Check scripts
js = dirstruct( fullfile( res, "md2html.js" ) );
if isfield( options, "Scripts" )
    js = dirstruct( js, options.Scripts );
end
assert( all( extensions( js ) == ".js" ), "docer:InvalidArgument", ...
    "Scripts must all have extension .js." )

% Check root
if isfield( options, "Root" )
    sRoot = dir( options.Root );
    root = sRoot(1).folder; % absolute path
    assert( startsWith( superdir( md ), root ), "docer:InvalidArgument", ...
        "Markdown files must be under folder %s.", root )
else
    root = superdir( md );
end

% Publish
for ii = 1:numel( md ) % loop over files
    fMd = fullfile( md(ii).folder, md(ii).name ); % this file
    try
        publish( fMd, root, css, js )
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

% Return output
if nargout, varargout = {md, css, js}; end

end % docerpub

function publish( fMd, root, css, js )
%publish  Publish a single Markdown file
%
%  publish(md,f,css,js) publishes the Markdown file md to HTML with
%  stylesheets css and scripts js in <f>/resources.

% Check inputs
[pMd, nMd, ~] = fileparts( fMd );
pRes = fullfile( root, 'resources' );
if ~isfolder( pRes ), mkdir( pRes ), end

% Start with doctype and head including title
html = "<!DOCTYPE html>" + newline + ...
    "<html xmlns=""http://www.w3.org/1999/xhtml"" xml:lang=""en"" lang=""en"">" + ...
    newline + "<head>" + newline + ...
    "<meta name=""generator"" content=""" + generator() + """>" + ...
    newline + "<title>" + nMd + "</title>" + newline;

% Add stylesheets
for ii = 1:numel( css )
    fCss = fullfile( css(ii).folder, css(ii).name );
    [~, nCss, eCss] = fileparts( fCss );
    copyfile( fCss, pRes )
    rCss = relpath( fullfile( pRes, [nCss eCss] ), pMd );
    rCss = strrep( rCss, filesep, '/' );
    html = html + "<link rel=""stylesheet"" href=""" + rCss + """>" + newline;
end

% Add scripts
for ii = 1:numel( js )
    fJs = fullfile( js(ii).folder, js(ii).name );
    [~, nJs, eJs] = fileparts( fJs );
    copyfile( fJs, pRes )
    rJs = relpath( fullfile( pRes, [nJs eJs] ), pMd );
    rJs = strrep( rJs, filesep(), '/' );
    html = html + "<script src=""" + rJs + """></script>" + newline;
end

% Add body
html = html + ...
    "</head>" + newline + "<body class=""markdown-body"">" + newline + ...
    "<main style=""margin: 0.7em"">" + newline + ...
    md2html( fileread( fMd ) ) + "</main>" + newline + ...
    "</body>" + newline + "</html>";

% Write output
fHtml = fullfile( pMd, [nMd '.html'] );
hHtml = fopen( fHtml, "w+" );
fprintf( hHtml, "%s", html );
fclose( hHtml );

% Echo
fprintf( 1, "[+] %s\n", fHtml );

end % publish

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

function s = generator()
%generator  HTML meta generator name
%
%  s = generator() returns a string detailing the MATLAB and Doc'er
%  versions, e.g, "MATLAB R2024a with Doc'er 0.2".

persistent GENERATOR % cache
if isequal( GENERATOR, [] ) % uninitialized
    v = ver( 'docer' ); % from Contents.m
    s = "MATLAB " + matlabRelease().Release + " with " + ...
        v(1).Name + " " + v(1).Version;
    GENERATOR = s; % store
else
    s = GENERATOR; % retrieve
end

end % generator