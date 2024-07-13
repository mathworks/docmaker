function docerreg( pRoot )
%docerreg  Create info.xml, helptoc.xml from Contents.m, helptoc.md
%
%  docerreg(f,id) creates info.xml and helptoc.xml for the product with
%  identifier id in the folder f.
%
%  See also: docerpub, docerrun, undocer

%  Copyright 2020-2024 The MathWorks, Inc.

arguments
    pRoot (1,1) string {mustBeFolder}
end

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

end % docerreg