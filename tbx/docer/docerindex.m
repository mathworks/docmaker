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
fHelp = fullfile( pRoot, "helptoc.md" );
mHelp = fileread( fHelp );
xHelp = md2xml( mHelp );
linkrep( xHelp, ".md", ".html" )

% Extract name
h1 = xHelp.getElementsByTagName( "h1" );
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

return


















% Find resources folder
pRez = fullfile( fileparts( mfilename( "fullpath" ) ), "resources" );

% Create helptoc.xml from helptoc.md
fHelpMd = fullfile( pRoot, "helptoc.md" ); % source file
xHelp = md2html( fileread( fHelpMd ) ); % convert to XML fragment
xHelp = "<?xml version=""1.0"" encoding=""utf-8""?>" + ...
    "<xml>" + newline + xHelp + "</xml>"; % wrap fragment
fHelpIn = tempname() + ".xml"; % temp file
writelines( xHelp, fHelpIn ) % write to file
cuHelp = onCleanup( @()delete( fHelpIn ) ); % clean up
fHelpXsl = fullfile( pRez, "helptoc.xsl" );
fHelpOut = fullfile( pRoot, "helptoc.xml" );
xslt( fHelpIn, fHelpXsl, fHelpOut ); % transform
fprintf( 1, "[+] %s\n", fHelpOut ); % echo

% Create info.xml from Contents.m
r = matlabRelease().Release;
n = "Package Jockey";
sInfo = struct( "release", r, "name", n );
fInfoIn = tempname() + ".xml"; % temp file
writestruct( sInfo, fInfoIn ); % write to file
cuInfo = onCleanup( @()delete( fInfoIn ) ); % clean up
fInfoXsl = fullfile( pRez, "info.xsl" );
fInfoOut = fullfile( pRoot, "info.xml" );
xslt( fInfoIn, fInfoXsl, fInfoOut ); % transform
fprintf( 1, "[+] %s\n", fInfoOut ); % echo

end % docerindex