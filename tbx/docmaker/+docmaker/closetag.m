function xml = closetag( xml, t )
%closetag  Close self-closing tag
%
%   x = closetag(x,t) closes the self-closing tags t in the xml string x.
%
%   Self-closing tags are HTML tags that cannot contain content, e.g.
%   "img", "hr", "br".  Unclosed self-closing tags -- e.g., <br> rather
%   than <br/> -- are valid HTML but invalid XML. GitHub returns valid HTML
%   that may be invalid XML, so closetag closes unclosed self-closing tags.

%   Copyright 2024-2026 The MathWorks, Inc.

lt = sort( [strfind( xml, "<" + t + " " ), ...
    strfind( xml, "<" + t + ">" )], "descend" ); % all *matching* tag opens
gt = strfind( xml, ">" ); % *all* tag closes
for ii = 1:numel( lt ) % backwards
    i = min( gt(gt>lt(ii)) ); % first ">" after "<" + tag
    if extract( xml, i-1 ) == "/", continue, end % already closed
    xml = extractBefore( xml, i ) + "/>" + extractAfter( xml, i ); % replace > with />
end

end % closetag
