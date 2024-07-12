function doctoc( fMd )
%mdtoc  Create helptoc XML from Markdown table of contents
%
%  mdtoc(md,xml)

arguments
    fMd (1,1) string {mustBeFile}
end

% Find style sheet
fXsl = fullfile( fileparts( mfilename( "fullpath" ) ), "resources", ...
    "helptoc.xsl" );

% Put XML next to Markdown
[pMd, nMd, ~] = fileparts( fMd );
fXml = fullfile( pMd, nMd + ".xml" );

% Convert to HTML and write to file
cHtml = md2html( fileread( fMd ) );
[pHtml, nHtml] = fileparts( tempname( pMd ) );
xHtml = ".html";
fHtml = fullfile( pHtml, nHtml + xHtml );
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