function x = extensions( s )
%extensions  File extensions
%
%   x = docstar.extensions(s) returns file extensions x from the folder
%   struct s.
%
%   See also: docstar.dir, fileparts

%   Copyright 2024 The MathWorks, Inc.

x = cell( size( s ) ); % preallocate
for ii = 1:numel( s )
    [~, ~, x{ii}] = fileparts( s(ii).name );
end

end % extensions