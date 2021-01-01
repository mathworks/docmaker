function d = superdir( varargin )
%superdir  Find lowest common superdirectory
%
%  d = superdir(f) finds the lowest common superdirectory for the file list
%  f. f can be specified as a char or string, a cellstr or string array, or
%  a dir struct.
%
%  If f is empty, or if the elements of f have no common superdirectory,
%  then [] is returned.
%
%  d = superdir(f1,f2,...) is also supported for chars and strings.
%
%  Examples:
%    superdir('C:\a\b\x','C:\a\b\y') returns 'C:\a\b'.
%    superdir('C:\a\x','C:\a\b\y') returns 'C:\a'.
%    superdir('C:\a\b\c','D:\x\y\z') returns [].

%  Copyright 2020-2021 The MathWorks, Inc.

% Handle inputs
switch nargin
    case 1
        if isstruct( varargin{:} ) % dir struct
            f = varargin{:}; % unpack
            p = reshape( {f.folder}, size( f ) ); % extract folders
            n = reshape( {f.name}, size( f ) ); % extract folders
            f = fullfile( p, n ); % combine
        else % something else, convert
            f = cellstr( varargin{:} );
        end
    otherwise
        f = cellstr( varargin );
end

% Find ancestor
if isempty( f ) % degenerate
    d = [];
else % normal
    d = fileparts( f{1} ); % initialize
    for ii = 1:numel( f )
        while( ~strncmp( f{ii}, d, numel( d ) ) ) % compare first parts
            if strcmp( d, fileparts( d ) ), d = []; return; end % root, stop
            d = fileparts( d ); % up
        end
    end
end

end % superdir