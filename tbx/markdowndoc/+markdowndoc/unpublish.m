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
p = unique( {d.folder} );
for ii = 1:numel( p )
    delete( fullfile( p{ii}, '*.html' ) )
end

% Delete resources folder
pRes = fullfile( f, 'resources' );
if exist( pRes ) == 7, rmdir( pRes, 's' ), end %#ok<EXIST>

end % unpublish