function unpublish( f )
%unpublish  Unpublish Markdown files
%
%  unpublish(root) unpublishes the documentation in the folder f by
%  deleting HTML files in f and its subfolders and deleting the folder
%  <f>/resources.
%
%  See also: publish

%  Copyright 2020-2021 The MathWorks, Inc.

% Check inputs
assert( isfolder( f ), 'markdowndoc:InvalidArgument', ...
    'Folder not found.' )

% Delete HTML files in folder and subfolders
d = dir( fullfile( f, '**', '*.html' ) );
for ii = 1:numel( d )
    fHtml = fullfile( d(ii).folder, d(ii).name );
    fprintf( 1, '[markdowndoc] Deleting ''%s''... ', fHtml ); % progress
    try
        delete( fHtml )
        fprintf( 1, 'OK.\n' ); % progress
    catch e
        fprintf( 1, 'failed.\n' ); % progress
        fprintf( 2, '%s\n', e.message ); % message
    end
end

% Delete resources folder
pRes = fullfile( f, 'resources' );
if exist( pRes ) == 7, rmdir( pRes, 's' ), end %#ok<EXIST>

end % unpublish