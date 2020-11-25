function xslt( source, style, destination )

NET.addAssembly( "System.Xml" );
xform = System.Xml.Xsl.XslCompiledTransform();
xform.Load( style );
xform.Transform( source, destination );

end % xslt