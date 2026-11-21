function tf = ishostname( host )
%docmaker.ishostname  Test whether text is a DNS hostname
%
%   tf = docmaker.ishostname(host) returns true when host is an ASCII DNS
%   hostname and false otherwise. A trailing root dot is allowed.
%
%   See also: docmaker.githubmd2html, docmaker.gitlabmd2html

%   Copyright 2026 The MathWorks, Inc.

arguments
    host {mustBeTextScalar}
end

host = string( host );
if ismissing( host ) || strlength( host ) == 0
    tf = false;
    return
end

% Allow the optional root dot, then check DNS presentation lengths.
if endsWith( host, "." )
    host = extractBefore( host, strlength( host ) );
end
if strlength( host ) == 0 || strlength( host ) > 253
    tf = false;
    return
end

labels = split( host, "." );
for ii = 1:numel( labels )
    label = char( labels(ii) );
    if strlength( labels(ii) ) > 63 || ...
            isempty( regexp( label, ...
            '^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$', 'once' ) )
        tf = false;
        return
    end
end

% Reject IPv4 literals; IPv6 literals fail the DNS-label check above.
if isIPv4Literal( labels )
    tf = false;
    return
end

tf = true;

end % ishostname

function tf = isIPv4Literal( labels )
%isIPv4Literal  Test whether labels contain an IPv4 address

tf = false;
if numel( labels ) ~= 4
    return
end

for ii = 1:4
    if isempty( regexp( char( labels(ii) ), '^\d{1,3}$', 'once' ) )
        return
    end
end

octets = str2double( labels );
tf = all( octets <= 255 );

end % isIPv4Literal
