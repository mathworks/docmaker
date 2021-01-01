function mdtoc( nMd, nXml )
%mdtoc  Create helptoc XML from Markdown table of contents
%
%  gfmdoc.mdtoc(md,xml)

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
i_xslt( nHtml, fullfile( dXsl, "helptoc.xsl" ), nXml );

end % mdtoc

function i_xslt( source, style, destination )
%i_xslt  Transform an XML document using an XSLT engine
%
%  i_xslt(source,style,destination) transforms the XML input file source to
%  the output file destination using the stylesheet style.  On Windows, the
%  .NET assembly System.Xml is used, for faster performance than MATLAB's
%  Java implementation.
%
%  See also: xslt

if ispc() % .NET, fast
    NET.addAssembly( "System.Xml" );
    xform = System.Xml.Xsl.XslCompiledTransform();
    xform.Load( style );
    xform.Transform( source, destination );
else % Java, slow
    xslt( source, style, destination );
end

end % i_xslt