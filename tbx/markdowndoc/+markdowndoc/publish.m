function publish( md, root, css, js )

% Check files to process
md = i_dir( md );
assert( ~any( [md.isdir] ) )

% Check root
if nargin < 2 || isequal( root, [] )
    root = markdowndoc.superdir( md );
else
    assert( isfolder( root ) )
    root = getfield( dir( root ), 'folder' ); % full path
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
css = [i_dir( fullfile( tbxresources(), 'matlaby.css' ) ); css]; % prepend standard

% Check scripts
% TODO look in standard place
if nargin < 4 || isequal( js, [] )
    js = [];
else
    js = i_dir( js );
end
js = [i_dir( fullfile( tbxresources(), 'lazyload.js' ) ); ...
    i_dir( fullfile( tbxresources(), 'mdlinks.js' ) ); js]; % prepend standard

% Publish
for ii = 1:numel( md )
    i_publish( fullfile( md(ii).folder, md(ii).name ), root, css, js )
end

end

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

function i_publish( fMd, pShared, css, js )

% Check inputs
[pMd, nMd, ~] = fileparts( fMd );
pResources = fullfile( pShared, 'resources' );
if ~isfolder( pResources ), mkdir( pResources ), end

% Start with doctype and head including title
html = "<!DOCTYPE html>" + newline + ...
    "<html xmlns=""http://www.w3.org/1999/xhtml"" xml:lang=""en"" lang=""en"">" + newline + ...
    "<head>" + newline + "<title>" + nMd + "</title>" + newline;

% Add stylesheets
for ii = 1:numel( css )
    fCss = fullfile( css(ii).folder, css(ii).name );
    [~, nCss, eCss] = fileparts( fCss );
    copyfile( fCss, pResources )
    rCss = markdowndoc.relpath( pMd, fullfile( pResources, [nCss eCss] ) );
    rCss = strrep( rCss, filesep, '/' );
    html = html + "<link rel=""stylesheet"" href=""" + rCss + """>" + newline;
end

% Add scripts
for ii = 1:numel( js )
    fJs = fullfile( js(ii).folder, js(ii).name );
    [~, nJs, eJs] = fileparts( fJs );
    copyfile( fJs, pResources )
    rJs = markdowndoc.relpath( pMd, fullfile( pResources, [nJs eJs] ) );
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

function r = tbxresources()

p = fileparts( mfilename( 'fullpath' ) );
c = fileparts( p );
r = fullfile( c, 'resources' );

end % tbxresources