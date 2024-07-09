function varargout = rmdoc( pDoc )
%nnundoc  Unpublish Markdown files
%
%  nnundoc(root) unpublishes the documentation in the folder f by deleting
%  HTML files in f and its subfolders, deleting the folder <f>/resources,
%  and deleting <f>/helptoc.xml.
%
%  For debugging, html = nnundoc(...) returns the HTML files unpublished,
%  as a dir struct.
%
%  See also: nndoc

%  Copyright 2020-2021 The MathWorks, Inc.

% Check inputs
assert( isfolder( pDoc ), 'markdowndoc:InvalidArgument', ...
    'Folder not found.' )

% Delete HTML files in folder and subfolders
dHtml = dir( fullfile( pDoc, '**', '*.html' ) );
for ii = 1:numel( dHtml )
    fHtml = fullfile( dHtml(ii).folder, dHtml(ii).name );
    try
        delete( fHtml )
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

% Delete resources folder
pRes = fullfile( pDoc, 'resources' );
if exist( pRes ) == 7, rmdir( pRes, 's' ), end %#ok<EXIST>

% Delete helptoc.xml
fHelp = fullfile( pDoc, 'helptoc.xml' );
if exist( fHelp, 'file' ), delete( fHelp ), end

% Return output
if nargout, varargout = {dHtml}; end

end % nnundoc