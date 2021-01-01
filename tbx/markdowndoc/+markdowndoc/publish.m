function publish( md, root, css, js )

% Check files to process
md = dirstruct( md );
assert( ~any( [md.isdir] ) )

% Check root
if nargin < 2 || isequal( root, [] )
    root = markdowndoc.ancestordir( md );
else
    assert( isfolder( root ) )
    root = getfield( dir( root ), 'folder' );
    assert( strncmp( root, markdowndoc.ancestordir( md ), numel( root ) ) )
end

% Check stylesheets
% TODO look in standard place
if nargin < 3 || isequal( css, [] )
    css = [];
else
    css = dirstruct( css );
    assert( ~any( [css.isdir] ) )
end
css = [dirstruct( fullfile( tbxresources(), 'matlaby.css' ) ); css]; % prepend standard

% Check scripts
% TODO look in standard place
if nargin < 4 || isequal( js, [] )
    js = [];
else
    js = dirstruct( js );
end
js = [dirstruct( fullfile( tbxresources(), 'lazyload.js' ) ); ...
    dirstruct( fullfile( tbxresources(), 'mdlinks.js' ) ); js]; % prepend standard

% Publish
for ii = 1:numel( md )
    i_publish( fullfile( md(ii).folder, md(ii).name ), root, css, js )
end

end

function d = dirstruct( d )
%dirstruct  Convert file specification to dir struct
%
%  d = dirstruct(s) converts the file specification to a dir struct.

if isstruct( d ) && all( ismember( fieldnames( d ), fieldnames( dir() ) ) )
    d = d(:);
elseif iscellstr( d ) || isstring( d ) % strings, call dir and combine
    d = cellstr( d );
    for ii = 1:numel( d )
        d{ii} = dir( d{ii} );
    end
    d = vertcat( d{:} );
else % call dir
    d = dir( d );
end

end

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