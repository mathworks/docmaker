function publish( md, root, stylesheets, scripts )

% Check files to process
if ischar( md ) || isstring( md )
    md = dir( md );
elseif iscellstr( md )
    for ii = 1:numel( md )
        md{ii} = dir( md{ii} );
    end
    md = [md{:}];
elseif isstruct( md ) && all( ismember( fieldnames( md ), fieldnames( dir() ) ) )
    md = reshape( md, 1, [] ); % dir struct, OK
else
    error( 'markdowndoc:InvalidArgument', ...
        'Input file(s) must strings or dir structs.' )
end
if isempty( md ), return, end

% Check root
if nargin < 2 || isequal( root, [] )
    root = i_root( md );
else
    assert( isfolder( root ) )
end

% Check stylesheets
% TODO support dirspec
% TODO bake in standard
% TODO look in standard place
if nargin < 3 || isequal( stylesheets, [] )
    stylesheets = cell( 1, 0 );
else
    stylesheets = cellstr( stylesheets );
end

% Check scripts
% TODO support dirspec
% TODO bake in standard
% TODO look in standard place
if nargin < 4 || isequal( scripts, [] )
    scripts = cell( 1, 0 );
else
    scripts = cellstr( scripts );
end

% Publish
for ii = 1:numel( md )
    fMd = fullfile( md(ii).folder, md(ii).name ); % full file name
    dMd = md(ii).isdir; % folder flag
    [~, ~, eMd] = fileparts( fMd ); % file extension
    if dMd == true % folder
        warning( 'markdowndoc:InvalidArgument', ...
            'Cannot publish folder ''%s''.', fMd )
    elseif ~strcmpi( eMd, '.md' ) % not .md
        warning( 'markdowndoc:InvalidArgument', ...
            'Cannot publish non-Markdown file ''%s''.', fMd )
    else % go for it
        i_publish( fMd, root, stylesheets, scripts )
    end
end

end

function i_publish( fMd, root, stylesheets, scripts )

% Check inputs
[pMd, nMd, ~] = fileparts( fMd );

% Start with doctype and head including title
html = "<!DOCTYPE html>" + newline + ...
    "<html xmlns=""http://www.w3.org/1999/xhtml"" xml:lang=""en"" lang=""en"">" + newline + ...
    "<head>" + newline + "<title>" + nMd + "</title>" + newline;

% Add stylesheets
for ii = 1:numel( stylesheets )
    i_copyresource( stylesheets{ii}, root )
    html = html + ...
        "<link rel=""stylesheet"" href=""" + ...
        i_relpath( root, stylesheets{ii} ) + """>" + newline;
end


% Add scripts
for ii = 1:numel( scripts )
    i_copyresource( scripts{ii}, root )
    html = html + ...
        "<script src=""" + i_relpath( root, scripts{ii} ) + ...
        """></script>" + newline;
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

function i_copyresource( fS, r )

[~, nS, eS] = fileparts( fS ); % source name and extension
pD = fullfile( r, 'resources' ); % destination folder
if ~isfolder( pD ), mkdir( pD ), end % ensure destination folder exists
copyfile( fS, fullfile( pD, [nS eS] ) ) % copy file

end % i_copyresource

function from = i_relpath( from, to )

end