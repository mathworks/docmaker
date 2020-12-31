function r = relpath( f, t )
%relpath  Compute relative path between two files
%
%  p = relpath(f,t) computes the relative path from the file f to the file
%  t.
%
%  Examples:
%    relpath('C:\a\b\x','C:\a\b\y') returns '.\y'.
%    relpath('C:\a\b\x','C:\a\b\c\y') returns '.\c\y'.
%    relpath('C:\a\b\c\y','C:\a\b\x') returns '.\..\x'.
%    relpath('C:\a\b\c','D:\x\y\z') returns 'D:\x\y\z'.

%  Copyright 2020-2021 The MathWorks, Inc.

a = markdowndoc.ancestordir( {f t} ); % find common ancestor
if isempty( a ) % no common ancestor
    r = t; % return absolute path
else % common ancestor
    r = '.'; % initialize
    while ~strcmp( fileparts( f ), a )
        r = fullfile( r, '..' ); % append ..
        f = fileparts( f ); % up one level
    end
    if strcmp( a, fileparts( a ) )
        r = [r, t(numel(a):end)]; % append t after r
    else
        r = [r, t(numel(a)+1:end)]; % append t after r
    end
end

end % relpath