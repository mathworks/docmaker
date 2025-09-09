function s = dir( p, varargin )
%dir  List folder contents
%
%   s = docstar.dir(f) returns the contents of the folder f, which can be
%   specified as an absolute or relative path, and can include wildcards.
%   The returned folder struct s contains fields name, folder, date, bytes,
%   isdir, and datenum.  Duplicates are removed.
%
%   docstar.dir(ff), where ff is nonscalar, concatentes and deduplicates
%   the results of calling the function on each of the elements.
%
%   docstar.dir(f1,f2,...) concatenates and deduplicates the results of
%   calling the function on each of the inputs.
%
%   docstar.dir(s), where s is a folder struct, deduplicates and returns
%   the input.
%
%   docstar.dir is a wrapper for dir to support struct, nonscalar, and
%   multiple inputs.
%
%   See also: dir

%   Copyright 2024 The MathWorks, Inc.

% Handle degenerate case of no inputs
if nargin == 0
    s = repmat( dir(), 0, 1 ); % empty struct with fieldnames
    return
end

% Process first input
narginchk( 1, Inf )
if isstruct( p ) && all( ismember( fieldnames( p ), fieldnames( dir() ) ) )
    s = p(:);
else
    p = cellstr( p );
    s = cell( size( p ) );
    for ii = 1:numel( p )
        s{ii} = dir( p{ii} );
    end
    s = vertcat( s{:} );
end

% Process subsequent inputs
if nargin > 1
    s = [s; docstar.dir( varargin{:} )];
end

% Deduplicate
f = arrayfun( @(x)fullfile(x.folder,x.name), s, "UniformOutput", false );
[~, i] = unique( f, "stable" );
s = s(i);

end % dir