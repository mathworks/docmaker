function mdtoc( nMd, nXml )
%mdtoc  Create helptoc XML from Markdown table of contents
%
%  mdtoc(md,xml)

% Read input Markdown
md = fileread( nMd );

% Convert Markdown to HTML
html = md2html( md );
html = "<body>" + html + "</body>"; % TODO necessary?

% Write HTML to file
nHtml = "temp.html";
c = onCleanup( @()delete(nHtml) );
fHtml = fopen( nHtml, "w" );
fwrite( fHtml, html );
fclose( fHtml );

% Convert from HTML to XML using XSL
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