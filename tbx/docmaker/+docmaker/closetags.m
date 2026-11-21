function s = closetags( s, t )
%docmaker.closetags  Close self-closing tag
%
%   xml = docmaker.closetags(html,t) closes the self-closing tags t in the
%   HTML string html.
%
%   Self-closing tags are HTML tags that cannot contain content, e.g.
%   "img", "hr", "br". Unclosed self-closing tags -- e.g., <br> rather than
%   <br/> -- are valid HTML but invalid XML.

%   Copyright 2024-2026 The MathWorks, Inc.

lt = sort( [strfind( s, "<" + t + " " ), ...
    strfind( s, "<" + t + ">" )], "descend" ); % all *matching* tag opens
gt = strfind( s, ">" ); % *all* tag closes
for ii = 1:numel( lt ) % backwards
    i = min( gt(gt>lt(ii)) ); % first ">" after "<" + tag
    if extract( s, i-1 ) == "/", continue, end % already closed
    s = extractBefore( s, i ) + "/>" + extractAfter( s, i ); % replace > with />
end

end % closetags
