function xslt( source, style, destination )
%xslt  Transform an XML document using an XSLT engine

if ispc() % .NET, fast
    NET.addAssembly( "System.Xml" );
    xform = System.Xml.Xsl.XslCompiledTransform();
    xform.Load( style );
    xform.Transform( source, destination );
else % Java, slow
    xslt( source, style, destination );
end

end % xslt