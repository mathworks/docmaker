function rTo = relpath( pFr, fTo )
%relpath  Compute relative path between two files
%
%  r = relpath(f,t) computes the relative path from the folder f to the
%  file t.
%
%  Examples:
%    relpath('C:\a\b\x','C:\a\b\y') returns '.\y'.
%    relpath('C:\a\b\x','C:\a\b\c\y') returns '.\c\y'.
%    relpath('C:\a\b\c\y','C:\a\b\x') returns '.\..\x'.
%    relpath('C:\a\b\c','D:\x\y\z') returns 'D:\x\y\z'.

%  Copyright 2020-2021 The MathWorks, Inc.

fFr = fullfile( pFr, '.' );
pSu = markdowndoc.superdir( fFr, fTo ); % common ancestor folder
if isempty( pSu ) % no common ancestor
    rTo = fTo; % return absolute path
else % common ancestor
    rTo = '.'; % initialize
    while ~strcmp( pFr, pSu )
        rTo = fullfile( rTo, '..' );
        pFr = fileparts( pFr ); % up one level
    end
    if strcmp( pSu, fileparts( pSu ) ) % root, includes separator
        rTo = fullfile( rTo, fTo(numel(pSu)+1:end) );
    else % not root
        rTo = [rTo, fTo(numel(pSu)+1:end)];
    end
end

end % relpath