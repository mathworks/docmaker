function mdtoc( nMd, nXml )
%mdtoc  Create helptoc XML from Markdown table of contents
%
%  mdtoc(md,xml)

% Read input Markdown
md = fileread( nMd );

% Convert Markdown to HTML
html = md2html( md );

% Convert HTML to XML by enclosing and adding a declaration
encoding = "utf-8";
declaration = "<?xml version=""1.0"" encoding=""" + encoding + """?>";
xml = declaration + "<html>" + html + "</html>";

% Write XML to file
nTemp = "temp.xml";
c = onCleanup( @()delete(nTemp) );
fTemp = fopen( nTemp, "w", "native", encoding );
fprintf( fTemp, "%s", xml );
fclose( fTemp );

% Convert from HTML to XML using XSL
fXsl = fullfile( fileparts( mfilename( "fullpath" ) ), "resources", "helptoc.xsl" );
xslt( nTemp, fXsl, nXml );

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
    %     xslt = System.Xml.Xsl.XslCompiledTransform();
    %     xslt.Load( style );
    %     settings = System.Xml.XmlWriterSettings();
    %     settings.Indent = true;
    %     settings.IndentChars = "\t";
    %     % settings.NewLineOnAttributes = true;
    %     settings.ConformanceLevel = System.Xml.ConformanceLevel.Fragment;
    %     writer = System.Xml.XmlWriter.Create( destination, settings );
    %     xslt.Transform( System.Xml.XPath.XPathDocument( source ), writer );
    %     writer.Close();
    xform = System.Xml.Xsl.XslCompiledTransform();
    xform.Load( style );
    xform.Transform( source, destination );
else % Java, slow
    xslt( source, style, destination );
end

end % i_xslt