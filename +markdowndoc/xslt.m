function xslt( source, style, destination )
%xslt  Transform an XML document using an XSLT engine
%
%  markdowndoc.xslt(source,style,destination) transforms the XML input file
%  source to the output file destination using the stylesheet style.  On
%  Windows, the .NET assembly System.Xml is used, for faster performance
%  than MATLAB's Java implementation.
%
%  See also: xslt

%  Copyright 2020 The MathWorks, Inc.

if ispc() % .NET, fast
    NET.addAssembly( "System.Xml" );
    xform = System.Xml.Xsl.XslCompiledTransform();
    xform.Load( style );
    xform.Transform( source, destination );
else % Java, slow
    xslt( source, style, destination );
end

end % xslt