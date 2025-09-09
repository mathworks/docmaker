function x = extensions( s )
%extensions  File extensions
%
%   x = docmaker.extensions(s) returns file extensions x from the folder
%   struct s.
%
%   See also: docmaker.dir, fileparts

%   Copyright 2024-2025 The MathWorks, Inc.

x = cell( size( s ) ); % preallocate
for ii = 1:numel( s )
    [~, ~, x{ii}] = fileparts( s(ii).name );
end

end % extensions