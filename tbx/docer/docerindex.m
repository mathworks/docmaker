function docerindex( pRoot )
%docerindex  Create info.xml and helptoc.xml from helptoc.md
%
%  docerindex(f) creates info.xml and helptoc.xml from helptoc.md in the
%  folder f.
%
%  See also: docerconvert, docerrun, docerdelete

%  Copyright 2020-2024 The MathWorks, Inc.

arguments
    pRoot (1,1) string {mustBeFolder}
end

% Canonicalize
sRoot = dirstruct( pRoot );
pRoot = sRoot(1).folder;

% Read helptoc.md
fToc = fullfile( pRoot, "helptoc.md" );
mToc = fileread( fToc );
xToc = md2xml( mToc );
linkrep( xToc, ".md", ".html" )

% Extract name
h1 = xToc.getElementsByTagName( "h1" );
if h1.Length > 0
    name = h1.item( 0 ).TextContent;
else
    name = "Unknown Toolbox";
end

% Write info.xml
xInfo = infoxml( name );
fInfo = fullfile( pRoot, "info.xml" );
w = matlab.io.xml.dom.DOMWriter();
w.Configuration.FormatPrettyPrint = true;
w.writeToFile( xInfo, fInfo )
fprintf( 1, "[+] %s\n", fInfo );

% Write helptoc.xml
transformer = matlab.io.xml.transform.Transformer();
oToc = matlab.io.xml.transform.SourceDocument( xToc );
fXsl = fullfile( fileparts( mfilename( "fullpath" ) ), "resources", "helptoc.xsl" );
oXsl = matlab.io.xml.transform.StylesheetSourceFile( fXsl );
fHelp = fullfile( pRoot, "helptoc.xml" );
oHelp = matlab.io.xml.transform.ResultFile( fHelp );
transform( transformer, oToc, oXsl, oHelp );
fprintf( 1, "[+] %s\n", fHelp );

end % docerindex