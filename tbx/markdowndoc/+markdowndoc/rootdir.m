function root = rootdir( d )
%rootdir  Find common ancestor folder for dirspec
%
%  r = rootdir(d) finds a common ancestor folder for the dirspec d.
%
%  If d is empty then r is [].  If there is no common ancestor then an
%  exception is raised.

if isempty( d )
    root = [];
else
    root = d(1).folder; % initialize
    for ii = 1:numel( d )
        while( ~strncmp( d(ii).folder, root, numel( root ) ) )
            assert( ~strcmp( root, fileparts( root ) ), ...
                'markdowndoc:UnhandledError', ...
                'Cannot find root directory.' )
            root = fileparts( root );
        end
    end
end

end % rootdir