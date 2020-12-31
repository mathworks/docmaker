function helptoc( nMd, nXml )
%helptoc  Create helptoc XML from Markdown
%
%  gfmdoc.helptoc(md,xml)

fMd = fopen( nMd, "r+" );
md = fread( fMd );
fclose( fMd );
md = string( char( transpose( md ) ) );

html = markdowndoc.md2html( md );
html = "<html>" + newline + "<body>" + html + "</body>" + newline + "</html>";

nHtml = "temp.html";
c = onCleanup( @()delete(nHtml) );
fHtml = fopen( nHtml, "w" );
fwrite( fHtml, html );
fclose( fHtml );

dXsl = fullfile( fileparts( fileparts( mfilename( "fullfile" ) ) ), "xsl" );
xslt( nHtml, fullfile( dXsl, "helptoc.xsl" ), nXml );

end % helptoc