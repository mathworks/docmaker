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
pRoot = sRoot(1).folder; % absolute

% Read helptoc.md
fToc = fullfile( pRoot, "helptoc.md" ); % source
mToc = fileread( fToc ); % Markdown
xToc = md2xml( mToc ); % parse
linkrep( xToc, ".md", ".html" ) % replace links

% Extract name
h1 = xToc.getElementsByTagName( "h1" ); % headings
if h1.Length > 0
    name = rmemoji( h1.item( 0 ).TextContent ); % first heading
else
    name = "Unknown Toolbox"; % unknown
end

% Write info.xml
xInfo = infoxml( name ); % build
w = matlab.io.xml.dom.DOMWriter(); % writer
w.Configuration.FormatPrettyPrint = true;
fInfo = fullfile( pRoot, "info.xml" ); % output
w.writeToFile( xInfo, fInfo ) % write
fprintf( 1, "[+] %s\n", fInfo ); % echo

% Write helptoc.xml
transformer = matlab.io.xml.transform.Transformer(); % transformer
oToc = matlab.io.xml.transform.SourceDocument( xToc ); % input
pTem = fullfile( fileparts( mfilename( "fullpath" ) ), "resources" ); % templates
fXsl = fullfile( pTem, "helptoc.xsl" );
oXsl = matlab.io.xml.transform.StylesheetSourceFile( fXsl ); % stylesheet
fHelp = fullfile( pRoot, "helptoc.xml" );
oHelp = matlab.io.xml.transform.ResultFile( fHelp ); % output
transform( transformer, oToc, oXsl, oHelp ); % transform
fprintf( 1, "[+] %s\n", fHelp ); % echo

end % docerindex