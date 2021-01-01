function varargout = unpublish( f )
%unpublish  Unpublish Markdown files
%
%  unpublish(root) unpublishes the documentation in the folder f by
%  deleting HTML files in f and its subfolders and deleting the folder
%  <f>/resources.
%
%  For debugging, html = unpublish(...) returns the HTML files unpublished,
%  as a dir struct.
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
    try
        delete( fHtml )
    catch e
        warning( e.identifier, '%s', e.message ) % rethrow as warning
    end
end

% Delete resources folder
pRes = fullfile( f, 'resources' );
if exist( pRes ) == 7, rmdir( pRes, 's' ), end %#ok<EXIST>

% Return output
if nargout, varargout = {d}; end

end % unpublish