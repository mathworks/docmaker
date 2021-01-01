function varargout = publish( md, root, css, js )
%publish  Publish Markdown files with stylesheets and scripts
%
%  publish(md) publishes the Markdown files md to HTML.  md can be a char
%  or string including wildcards, a cellstr or string array, or a dir
%  struct.
%
%  publish(md,f) publishes to the folder f, placing resources in the folder
%  <f>/resources.  If not specified, or if specified as [], then f is the
%  lowest superdirectory of the published files.
%
%  publish(md,f,css,js) includes the stylesheets css and the scripts js.
%  If specified as [], then only the minimal set of stylesheets and scripts
%  are included. If specified without path, then ...
%
%  For debugging, [md,css,js] = publish(...) returns the Markdown files
%  published and the stylesheets and scripts included, as dir structs.
%
%  See also: unpublish

%  Copyright 2020-2021 The MathWorks, Inc.

% Handle inputs
md = i_dir( md );
assert( ~any( [md.isdir] ) )

% Find resources folder
res = fullfile( fileparts( fileparts( mfilename( 'fullpath' ) ) ), 'resources' );

% Check root
if nargin < 2 || isequal( root, [] )
    root = markdowndoc.superdir( md );
else
    assert( isfolder( root ) )
    root = getfield( dir( root ), 'folder' ); % absolute path
    assert( strncmp( root, markdowndoc.superdir( md ), numel( root ) ) )
end

% Check stylesheets
% TODO look in standard place
if nargin < 3 || isequal( css, [] )
    css = [];
else
    css = i_dir( css, res );
    assert( ~any( [css.isdir] ) )
end

% Check scripts
% TODO look in standard place
if nargin < 4 || isequal( js, [] )
    js = [];
else
    js = i_dir( js, res );
    assert( ~any( [js.isdir] ) )
end
js = [i_dir( {'lazyload.js','mdlinks.js'}, res ); js]; % prepend standard

% Publish
for ii = 1:numel( md ) % loop over files
    fMd = fullfile( md(ii).folder, md(ii).name ); % this file
    try
        i_publish( fMd, root, css, js ) % publish
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

% Return output
if nargout, varargout = {md, css, js}; end

end % publish

function i_publish( fMd, root, css, js )
%i_publish  Publish a single Markdown file
%
%  i_publish(md,f,css,js) publishes the Markdown file md to HTML with
%  stylesheets css and scripts js in <f>/resources.

% Check inputs
[pMd, nMd, ~] = fileparts( fMd );
pRes = fullfile( root, 'resources' );
if ~isfolder( pRes ), mkdir( pRes ), end

% Start with doctype and head including title
html = "<!DOCTYPE html>" + newline + ...
    "<html xmlns=""http://www.w3.org/1999/xhtml"" xml:lang=""en"" lang=""en"">" + newline + ...
    "<head>" + newline + ...
    "<meta name=""generator"" content=""" + i_generator() + """>" + newline + ...
    "<title>" + nMd + "</title>" + newline;

% Add stylesheets
for ii = 1:numel( css )
    fCss = fullfile( css(ii).folder, css(ii).name );
    [~, nCss, eCss] = fileparts( fCss );
    copyfile( fCss, pRes )
    rCss = markdowndoc.relpath( fullfile( pRes, [nCss eCss] ), pMd );
    rCss = strrep( rCss, filesep, '/' );
    html = html + "<link rel=""stylesheet"" href=""" + rCss + """>" + newline;
end

% Add scripts
for ii = 1:numel( js )
    fJs = fullfile( js(ii).folder, js(ii).name );
    [~, nJs, eJs] = fileparts( fJs );
    copyfile( fJs, pRes )
    rJs = markdowndoc.relpath( fullfile( pRes, [nJs eJs] ), pMd );
    rJs = strrep( rJs, filesep(), '/' );
    html = html + "<script src=""" + rJs + """></script>" + newline;
end

% Add body
html = html + ...
    "</head>" + newline + "<body>" + newline + "<main>" + newline + ...
    markdowndoc.md2html( fileread( fMd ) ) + newline + ...
    "</main>" + newline + "</body>" + newline + "</html>";

% Write output
fHtml = fullfile( pMd, [nMd '.html'] );
hHtml = fopen( fHtml, "w+" );
fprintf( hHtml, "%s", html );
fclose( hHtml );

end % i_publish

function s = i_dir( p, r )
%i_dir  Query folder contents
%
%  s = i_dir(p) queries the contents of the folder p.  If p is a char or a
%  string then s is dir(p).  If p is a cellstr or a string array then s is
%  the concatenation of the results of calling dir on each element.  If p
%  is already a struct returned from dir then it is returned unaltered.
%
%  s = i_dir(...,r) looks in the folder r if no contents are found
%  initially.
%
%  See also: dir

% Check inputs
if nargin > 1, assert( isfolder( r ), 'Folder not found.' ), end

% List contents
if isstruct( p ) && all( ismember( fieldnames( p ), fieldnames( dir() ) ) )
    s = p(:);
elseif ischar( p )
    s = dir( p );
    if isempty( s ) && nargin > 1
        s = dir( fullfile( r, p ) );
    end
elseif isstring( p ) || iscellstr( p )
    p = cellstr( p );
    s = cell( size( p ) );
    for ii = 1:numel( p )
        q = p{ii};
        t = dir( q );
        if isempty( t ) && nargin > 1
            t = dir( fullfile( r, q ) );
        end
        s{ii} = t;
    end
    s = vertcat( s{:} );
else
    error( 'Input must be a char or string, a cellstr or string array, or a dir struct.' )
end

end % i_dir

function s = i_generator()
%i_generator  HTML meta generator name
%
%  s = i_generator() returns a string detailing the MATLAB and markdowndoc
%  versions, e.g, "MATLAB 9.9 (R2020b) with markdowndoc 0.1".

matlab = ver( 'MATLAB' );
markdowndoc = ver( 'markdowndoc' );
s = sprintf( '%s %s %s with %s %s', matlab.Name, matlab.Version, ...
    matlab.Release, markdowndoc.Name, markdowndoc.Version );
s = string( s );

end % i_generator