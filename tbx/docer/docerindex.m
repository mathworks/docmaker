function docerindex( pRoot )
%docerindex  Create info.xml and helptoc.xml from helptoc.md
%
%   docerindex(d) creates documentation index files "info.xml" and
%   "helptoc.xml" and search database "helpsearch-v4" in the folder d.
%
%   See also: docerconvert, docerrun, docerdelete, builddocsearchdb

%   Copyright 2020-2024 The MathWorks, Inc.

arguments
    pRoot (1,1) string {mustBeFolder}
end

% Canonicalize
sRoot = docer.dir( pRoot );
pRoot = sRoot(1).folder; % absolute

% Read helptoc.md
fToc = fullfile( pRoot, "helptoc.md" ); % source
mToc = fileread( fToc ); % Markdown
xToc = docer.md2xml( mToc ); % parse
docer.linkrep( xToc, ".md", ".html" ) % replace links

% Extract name
h1 = docer.list2array( xToc.getElementsByTagName( "h1" ) ); % headings
if isempty( h1 )
    name = "Unknown Toolbox"; % unknown
else
    name = docer.rmemoji( h1(1).TextContent ); % first heading
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

% Build search database
search = ['builddocsearchdb(''', strrep( pRoot, '''', '''''' ), ''')']; % command
evalc( search ); % build without echo
fDatabase = dir( fullfile( pRoot, "helpsearch-v4*" ) ); % find database
fDatabase = fDatabase([fDatabase.isdir]); % only folders
fprintf( 1, "[+] %s\n", fullfile( fDatabase(1).folder, fDatabase(1).name ) ); % echo
fDrool = fullfile( pRoot, "custom_toolbox.json" ); % drool
if isfile( fDrool ), delete( fDrool ), end % clean up

end % docerindex

function doc = infoxml( name )
%infoxml  Create info.xml document
%
%   x = infoxml(n) creates an info.xml document x with name n.

arguments
    name (1,1) string
end

% Handle inputs
if endsWith( name, " Toolbox" )
    name = extractBefore( name, " Toolbox" );
end

% Create document
doc = matlab.io.xml.dom.Document( "productinfo" );
doc.XMLStandalone = true;
info = doc.getDocumentElement(); % root

% Add elements
addElement( info, "matlabrelease", matlabRelease().Release )
addElement( info, "name", name )
addElement( info, "type", "toolbox" )
addElement( info, "icon", "$toolbox/matlab/icons/bookicon.gif" )
addElement( info, "help_location", "." )

end % infoxml

function addElement( parent, name, value )
%addElement  Add element to node
%
%  addElement(p,n,v) adds an element with tag name n and value v to the
%  parent node p.

doc = parent.getOwnerDocument(); % document
element = doc.createElement( name ); % create
parent.appendChild( element ); % add
text = doc.createTextNode( value ); % create
element.appendChild( text ); % add

end % addElement