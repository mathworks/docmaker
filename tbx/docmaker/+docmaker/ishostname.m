function tf = ishostname( s )
%docmaker.ishostname  Test whether text is a DNS hostname
%
%   tf = docmaker.ishostname(s) returns true when s is an ASCII DNS
%   hostname without a trailing root dot and false otherwise.
%
%   See also: docmaker.githubmd2html, docmaker.gitlabmd2html

%   Copyright 2026 The MathWorks, Inc.

arguments
    s (1,1) string
end

% Reject missing, empty, and too-long input
if ismissing( s ) || strlength( s ) == 0 || strlength( s ) > 253
    tf = false;
    return
end

% Split on dots and check each label
labels = split( s, "." );
if ~all( arrayfun( @islabel, labels ) )
    tf = false;
    return
end

% Reject IPv4 literals; IPv6 literals fail above
if numel( labels ) == 4 && all( matches( labels, digitsPattern ) ) && ...
        all( str2double( labels ) < 256 )
    tf = false;
    return
end

% Otherwise return true
tf = true;

end % ishostname

function tf = islabel( label )
%islabel  Test whether text is a valid DNS label

if strlength( label ) > 63 % max length
    tf = false;
else % letters, digits or hyphens; letters or digits first and last
    tf = ~isempty( regexp( char( label ), ...
        '^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$', 'once' ) );
end

end % islabel
