function s = superfolder( varargin )
%superfolder  Common ancestor folder
%
%  s = superfolder(p1,p2,...) returns the common ancestor of the folders
%  p1, p2, ...  The folders must exist.  If there is no common ancestor
%  then superfolder returns [].

% Check inputs
narginchk( 1, Inf )
dd = string( varargin );

% Canonicalize using dir
for ii = 1:numel( dd )
    d = dd(ii);
    assert( isfolder( d ), "docer:NotFound", "Folder ""%s"" not found.", d )
    sd = dir( d );
    dd(ii) = sd(1).folder; % first entry is "."
end

% Loop, split, compare
s = dd(1); % initialize
for ii = 2:numel( dd )
    d = dd(ii);
    ts = split( s, filesep ); % split
    td = split( d, filesep ); % split
    n = min( numel( ts ), numel( td ) ); % comparable length
    tf = ts(1:n) == td(1:n); % compare
    i = find( tf == false, 1, "first" ); % first non-match
    if i == 1 % immediate non-match
        s = [];
        return
    elseif isempty( i ) % full match
        s = join( ts(1:n), filesep );
    else % partial match
        s = join( ts(1:i-1), filesep );
    end
end

% Return matching datatype
if iscellstr( varargin ), s = char( s ); end %#ok<ISCLSTR>

end % superdir