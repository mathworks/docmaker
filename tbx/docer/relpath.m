function r = relpath( d, f )
%relpath  Relative path from folder to file
%
%  r = relpath(d,f) returns the relative path r from the folder d to the
%  file f.  The folder and file must exist, and can be specified as
%  absolute or relative (with respect to the current folder) paths.

%  Copyright 2020-2024 The MathWorks, Inc.

% Canonicalize
assert( isfolder( d ), "docer:NotFound", "Folder ""%s"" not found.", d )
sd = dir( d );
pd = string( sd(1).folder ); % first entry is "."
assert( isfile( f ), "docer:NotFound", "File ""%s"" not found.", f )
sf = dir( f );
pf = string( sf(1).folder ); % single matching entry
nf = string( sf(1).name ); % single matching entry

% Find common ancestor folder
ps = superfolder( pd, pf );
if isequal( ps, [] )
    r = fullfile( pf, nf ); % absolute
else
    tp = split( pd, filesep );
    tf = split( pf, filesep );
    ts = split( ps, filesep );
    up = repmat( "..", numel( tp ) - numel( ts ), 1 ); % go up
    dn = tf(numel( ts )+1:end,:); % then down
    r = fullfile( join( up, filesep ), join( dn, filesep ), nf );
end

% Return matching datatype
if ischar( d ) && ischar( f ), r = char( r ); end

end % relpath