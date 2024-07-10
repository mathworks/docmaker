function varargout = docpages( md, options )
%docpages  Publish Markdown files to HTML with stylesheets and scripts
%
%  docpages(md) publishes the Markdown files md to HTML.  md can be a char
%  or string including wildcards, a cellstr or string array, or a dir
%  struct.
%
%  docpages(md,f) publishes to the folder f, placing resources in the folder
%  <f>/resources.  If not specified, or if specified as [], then f is the
%  lowest superdirectory of the published files.
%
%  docpages(md,f,css,js) includes the stylesheets css and the scripts js.
%  If specified as [], then only the minimal set of stylesheets and scripts
%  are included. If specified without path, then ...
%
%  For debugging, [md,css,js] = docpages(...) returns the Markdown files
%  published and the stylesheets and scripts included, as dir structs.
%
%  See also: docdemos, doctoc, undoc

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
css = dirstruct( fullfile( res, ["github-markdown.css" "matlaby.css"] ) );
if isfield( options, "Stylesheets" )
    css = dirstruct( css, options.Stylesheets );
end
assert( all( extensions( css ) == ".css" ), "docer:InvalidArgument", ...
    "Stylesheets must all have extension .css." )

% Check scripts
js = dirstruct( fullfile( res, "mdlinks.js" ) );
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
        docpage( fMd, root, css, js )
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

% Return output
if nargout, varargout = {md, css, js}; end

end % docpages

function docpage( fMd, root, css, js )
%docpage  Publish a single Markdown file
%
%  docpage(md,f,css,js) publishes the Markdown file md to HTML with
%  stylesheets css and scripts js in <f>/resources.

% Check inputs
[pMd, nMd, ~] = fileparts( fMd );
pRes = fullfile( root, 'resources' );
if ~isfolder( pRes ), mkdir( pRes ), end

% Start with doctype and head including title
html = "<!DOCTYPE html>" + newline + ...
    "<html xmlns=""http://www.w3.org/1999/xhtml"" xml:lang=""en"" lang=""en"">" + newline + ...
    "<head>" + newline + ...
    "<meta name=""generator"" content=""" + generator() + """>" + newline + ...
    "<title>" + nMd + "</title>" + newline;

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

end % docpage

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
%  s = generator() returns a string detailing the MATLAB and markdowndoc
%  versions, e.g, "MATLAB R2024a with Doc'er 0.2".

matlab = ver( 'MATLAB' ); %#ok<VERMATLAB>
matlab = matlab(1);
toolbox = ver( 'doc''er' );
toolbox = toolbox(1);
s = sprintf( '%s %s with %s %s', matlab.Name, ...
    matlab.Release(2:end-1), toolbox.Name, toolbox.Version );
s = string( s );

end % generator