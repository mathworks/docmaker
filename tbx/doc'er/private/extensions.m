function x = extensions( s )
%extensions  File extensions
%
%  x = extensions(s) returns file extensions x from the folder struct s.

%  Copyright 2024 The MathWorks, Inc.

x = strings( size( s ) ); % preallocate
for ii = 1:numel( s )
    [~, ~, x(ii)] = fileparts( s(ii).name );
end

end % extensions