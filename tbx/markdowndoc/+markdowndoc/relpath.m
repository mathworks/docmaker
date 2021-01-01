function rTo = relpath( pFrom, fTo )
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

sFrom = separator( pFrom ); % separator
fFrom = [pFrom, sFrom, '.']; % fullfile
pShared = markdowndoc.superdir( {fFrom fTo} ); % common ancestor folder
if isempty( pShared ) % no common ancestor
    rTo = fTo; % return absolute path
else % common ancestor
    sTo = separator( fTo ); % identify separator
    rTo = '.'; % initialize
    while ~strcmp( pFrom, pShared )
        rTo = [rTo, sTo, '..']; %#ok<AGROW> % append ..
        pFrom = fileparts( pFrom ); % up one level
    end
    if strcmp( pShared, fileparts( pShared ) ) % root, ends with separator
        rTo = [rTo, sTo, fTo(numel(pShared)+1:end)];
    else % not root
        rTo = [rTo, fTo(numel(pShared)+1:end)];
    end
end

end % relpath

function s = separator( f )
%separator  Identify file separator in filename
%
%  s = separator(f) identifies the file separator in the filename f by
%  searching for, in order: filesep, /, \.  If no separator is found then
%  filesep is assumed.

if any( f == filesep )
    s = filesep;
elseif any( f == '/' )
    s = '/';
elseif any( f == '\' )
    s = '\';
else
    s = filesep;
end

end % separator