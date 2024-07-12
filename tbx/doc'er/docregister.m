function docregister( pRoot )
%docregister  Create helptoc XML from Markdown table of contents
%
%  docregister(md,xml)
%
%  See also: docpublish, docdemo, undoc

%  Copyright 2020-2024 The MathWorks, Inc.

arguments
    pRoot (1,1) string {mustBeFolder}
end

% Find style sheet
fXsl = fullfile( fileparts( mfilename( "fullpath" ) ), "resources", ...
    "helptoc.xsl" );

% Put XML next to Markdown
fMd = fullfile( pRoot, "helptoc.md" );
fXml = fullfile( pRoot, "helptoc.xml" );

% Convert to HTML and write to file
cHtml = md2html( fileread( fMd ) ); % content
[~, nHtml] = fileparts( tempname( pRoot ) ); % temp
fHtml = fullfile( pRoot, nHtml + ".html" );
hHtml = fopen( fHtml, "w" );
if hHtml == -1, error( "Could not create ""%s"".", fHtml ), end
s = "<!DOCTYPE html>\n<html>\n<body>\n%s</body>\n</html>\n"; % format string
fprintf( hHtml, s, cHtml ); % build HTML file around fragment
fclose( hHtml );

% Create XML using XSLT
try
    xslt( fHtml, fXsl, fXml );
    fprintf( 1, "[+] %s\n", fXml );
    delete( fHtml ) % clean up
catch e
    delete( fHtml ) % clean up
    rethrow( e )
end

end % doctoc