function rTo = relpath( fTo, pFr )
%relpath  Compute relative path to a file from a folder
%
%  r = relpath(f,t) computes the relative path to the file t from the
%  *folder* f.
%
%  Examples:
%    relpath('C:\a\b\x','C:\a\b\y') returns '.\y'.
%    relpath('C:\a\b\x','C:\a\b\c\y') returns '.\c\y'.
%    relpath('C:\a\b\c\y','C:\a\b\x') returns '.\..\x'.
%    relpath('C:\a\b\c','D:\x\y\z') returns 'D:\x\y\z'.

%  Copyright 2020-2021 The MathWorks, Inc.

pSu = markdowndoc.superdir( fullfile( pFr, '.' ), fTo ); % superdirectory
if isempty( pSu ) % no superdirectory, return absolute path
    rTo = fTo;
else % superdirectory, go up then down
    rTo = '.'; % initialize
    while ~strcmp( pFr, pSu )
        rTo = fullfile( rTo, '..' ); % up
        pFr = fileparts( pFr ); % up
    end
    if strcmp( pSu, fileparts( pSu ) ) % root, includes separator
        rTo = fullfile( rTo, extractAfter( fTo, pSu ) );
    else % not root
        rTo = horzcat( rTo, extractAfter( fTo, pSu ) );
    end
end

end % relpath