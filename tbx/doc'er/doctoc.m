function doctoc( fMd )
%mdtoc  Create helptoc XML from Markdown table of contents
%
%  mdtoc(md,xml)

% Find style sheet
pXsl = fullfile( fileparts( mfilename( 'fullpath' ) ), 'resources' );
fXsl = fullfile( pXsl, "helptoc.xsl" );

% Put helptoc.xml next to input Markdown file
[pMd, nMd, ~] = fileparts( fMd );
fXml = fullfile( pMd, nMd + ".xml" );

% Generate HTML fragment
cHtml = md2html( fileread( fMd ) );
[pHtml, nHtml] = fileparts( tempname( pMd ) );
xHtml = ".html";
fHtml = fullfile( pHtml, nHtml + xHtml );
hHtml = fopen( fHtml, "w" );
fprintf( hHtml, "<html>\n%s\n</html>\n", cHtml );
fclose( hHtml );


% Create helptoc.xml
xslt( fHtml, fXsl, fXml );
fprintf( 1, "[+] %s\n", fXml );

% Clean up
delete( fHtml )

end % doctoc