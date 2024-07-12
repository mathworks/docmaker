function docregister( pRoot, id )
%docregister  Create info.xml, helptoc.xml from Contents.m, helptoc.md
%
%  docregister(f,id) creates info.xml and helptoc.xml for the product with
%  identifier id in the folder f.
%
%  See also: docpublish, docdemo, undoc

%  Copyright 2020-2024 The MathWorks, Inc.

arguments
    pRoot (1,1) string {mustBeFolder}
    id (1,1) string
end

% Find style sheet
fXsl = fullfile( fileparts( mfilename( "fullpath" ) ), "resources", ...
    "helptoc.xsl" );

% Put XML next to Markdown
fMd = fullfile( pRoot, "helptoc.md" );
fXml = fullfile( pRoot, "helptoc.xml" );
fInfo = fullfile( pRoot, "info.xml" );

% Convert to HTML and write to file
assert( exist( fMd, "file" ), "docer:NotFound", ...
    "Cannot find table of contents ""%s"".", fMd )
cHtml = md2html( fileread( fMd ) ); % content
[~, nHtml] = fileparts( tempname( pRoot ) ); % temp
fHtml = fullfile( pRoot, nHtml + ".html" );
hHtml = fopen( fHtml, "w" );
if hHtml == -1, error( "Could not create ""%s"".", fHtml ), end
s = "<!DOCTYPE html>\n<html>\n<body>\n%s</body>\n</html>\n"; % format string
fprintf( hHtml, s, cHtml ); % build HTML file around fragment
fclose( hHtml );

% Create XML using XSLT
try
    xslt( fHtml, fXsl, fXml );
    fprintf( 1, "[+] %s\n", fXml );
    delete( fHtml ) % clean up
catch e
    delete( fHtml ) % clean up
    rethrow( e )
end

cInfo = info( id, pRoot );
fprintf( 1, "%s\n", cInfo );

end % doctoc

function c = info( id, pHelp )
%info  Generate info.xml from product identifier and documentation folder

s = ver( id ); % read metadata from Contents.m
[~, nHelp] = fileparts( pHelp ); % just last part
release = string( s.Release );
if startsWith( release, "(" ) && endsWith( release, ")" )
    release = extractBetween( release, 2, strlength( release ) - 1 );
end
name = string( s.Name );
if endsWith( name, " Toolbox" )
    name = extractBefore( name, strlength( name ) - strlength( "Toolbox" ) );
end

c(1) = "<productinfo xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xsi:noNamespaceSchemaLocation=""optional"">";
c(2) = "<?xml-stylesheet type=""text/xsl"" href=""optional""?>";
c(3) = sprintf( "<matlabrelease>%s</matlabrelease>", release );
c(4) = sprintf( "<name>%s</name>", name );
c(5) = "<type>toolbox</type>";
c(6) = "<icon>$toolbox/matlab/icons/bookicon.gif</icon>";
c(7) = sprintf( "<help_location>../%s</help_location>", nHelp );
c(8) = "</productinfo>";

% Combine
c = strjoin( c, newline );

end % info