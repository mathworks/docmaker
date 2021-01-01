function publish( md, root, css, js )
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
%  See also: unpublish

%  Copyright 2020-2021 The MathWorks, Inc.

% Handle inputs
md = i_dir( md );
assert( ~any( [md.isdir] ) )

% Find resources folder
pCode = fileparts( fileparts( mfilename( 'fullpath' ) ) );
pRes = fullfile( pCode, 'resources' );

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
    css = i_dir( css );
    assert( ~any( [css.isdir] ) )
end
css = [i_dir( fullfile( pRes, 'matlaby.css' ) ); css]; % prepend standard

% Check scripts
% TODO look in standard place
if nargin < 4 || isequal( js, [] )
    js = [];
else
    js = i_dir( js );
end
js = [i_dir( fullfile( pRes, 'lazyload.js' ) ); ...
    i_dir( fullfile( pRes, 'mdlinks.js' ) ); js]; % prepend standard

% Publish
for ii = 1:numel( md ) % loop over files
    fMd = fullfile( md(ii).folder, md(ii).name ); % this file
    fprintf( 1, '[markdowndoc] Publishing ''%s''... ', fMd ); % progress
    try
        i_publish( fMd, root, css, js ) % publish
        fprintf( 1, 'OK.\n' ); % progress
    catch e
        fprintf( 1, 'failed.\n' ); % progress
        fprintf( 2, '%s\n', e.message ); % message
    end
end

end

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

function s = i_dir( d )
%i_dir  Query folder contents
%
%  s = i_dir(p) queries the contents of the folder p.  If p is a char or a
%  string then s is dir(p).  If p is a cellstr or a string array then s is
%  the concatenation of the results of calling dir on each element.  If p
%  is already a struct returned from dir then it is returned unaltered.
%
%  See also: dir

if isstruct( d ) && all( ismember( fieldnames( d ), fieldnames( dir() ) ) )
    s = d(:);
elseif iscellstr( d ) || isstring( d ) % strings, call dir and combine
    d = cellstr( d );
    s = cell( size( d ) ); % preallocate
    for ii = 1:numel( d )
        s{ii} = dir( d{ii} );
    end
    s = vertcat( s{:} );
else % call dir
    s = dir( d );
end

end % i_dir

function s = i_generator()
%i_generator  HTML meta generator name

matlab = ver( 'MATLAB' );
markdowndoc = ver( 'markdowndoc' );
s = sprintf( '%s %s %s with %s %s', matlab.Name, matlab.Version, ...
    matlab.Release, markdowndoc.Name, markdowndoc.Version );
s = string( s );

end % i_generator