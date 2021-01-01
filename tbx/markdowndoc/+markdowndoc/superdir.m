function a = superdir( f )
%superdir  Find lowest common superdirectory
%
%  r = superdir(f) finds the lowest common superdirectory for the file list
%  f. f can be specified as a char or string, a cellstr or string array, or
%  a dir struct.
%
%  If f is empty, or if the elements of f have no common superdirectory,
%  then [] is returned.

%  Copyright 2020-2021 The MathWorks, Inc.

% Handle inputs
if isstruct( f ) % dir struct
    p = reshape( {f.folder}, size( f ) ); % extract folders
    n = reshape( {f.name}, size( f ) ); % extract folders
    f = fullfile( p, n ); % combine
else % something else, convert
    f = cellstr( f );
end

% Find ancestor
if isempty( f ) % degenerate
    a = [];
else % normal
    a = fileparts( f{1} ); % initialize
    for ii = 1:numel( f )
        while( ~strncmp( f{ii}, a, numel( a ) ) ) % compare first parts
            if strcmp( a, fileparts( a ) ), a = []; return; end % topped out
            a = fileparts( a ); % up one
        end
    end
end

end % superdir