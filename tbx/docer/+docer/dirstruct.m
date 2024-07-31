function s = dirstruct( p, varargin )
%dirstruct  List folder contents
%
%   s = docer.dirstruct(f) returns the contents of the folder f, which can
%   be specified as an absolute or relative path, and can include
%   wildcards.  The returned folder structure s contains fields name,
%   folder, date, bytes, isdir, and datenum.  Duplicates are removed.
%
%   docer.dirstruct(ff), where ff is nonscalar, concatentes and
%   deduplicates the results of calling the function on each of the
%   elements.
%
%   docer.dirstruct(f1,f2,...) concatenates and deduplicates the results of
%   calling the function on each of the inputs.
%
%   docer.dirstruct(s), where s is a folder structure, deduplicates and
%   returns the input.
%
%   docer.dirstruct is a wrapper for dir to support struct, nonscalar, and
%   multiple inputs.
%
%   See also: dir

%   Copyright 2024 The MathWorks, Inc.

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
    s = [s; docer.dirstruct( varargin{:} )];
end

% Deduplicate
f = arrayfun( @(x)fullfile(x.folder,x.name), s, "UniformOutput", false );
[~, i] = unique( f, "stable" );
s = s(i);

end % dirstruct