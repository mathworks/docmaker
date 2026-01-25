function varargout = docindex( pRoot )
%docindex  Create info.xml and helptoc.xml from helptoc.md
%
%   docindex(d) creates documentation index files "info.xml" and
%   "helptoc.xml" and search database "helpsearch-v4" in the folder d.
%
%   [xml,db] = docindex(...) returns the names of the index files xml and
%   the search database folder db created.
%
%   See also: docconvert, docrun, docdelete, builddocsearchdb

%   Copyright 2020-2026 The MathWorks, Inc.

arguments
    pRoot (1,1) string {mustBeFolder}
end

% Canonicalize
sRoot = docmaker.dir( pRoot );
pRoot = sRoot(1).folder; % absolute

% Read helptoc.md
fToc = fullfile( pRoot, "helptoc.md" ); % source
mToc = fileread( fToc ); % Markdown
xToc = docmaker.md2xml( mToc ); % parse
docmaker.linkrep( xToc, ".md", ".html" ) % replace links

% Extract name
h1 = docmaker.list2array( xToc.getElementsByTagName( "h1" ) ); % headings
if isempty( h1 )
    name = "Unknown Toolbox"; % unknown
else
    name = docmaker.rmemoji( h1(1).TextContent ); % first heading
end

% Write info.xml
xInfo = infoxml( name ); % build
writer = matlab.io.xml.dom.DOMWriter(); % writer
writer.Configuration.FormatPrettyPrint = true;
fInfo = fullfile( pRoot, "info.xml" ); % output
writer.writeToFile( xInfo, fInfo ) % write
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
sDatabase = dir( fullfile( pRoot, "helpsearch-v*" ) ); % find database
sDatabase = sDatabase([sDatabase.isdir]); % only folders
fDatabase = string( fullfile( sDatabase(1).folder, sDatabase(1).name ) );
fprintf( 1, "[+] %s\n", fDatabase ); % echo
fDrool = fullfile( pRoot, "custom_toolbox.json" ); % drool
if isfile( fDrool ), delete( fDrool ), end % clean up

% Return outputs
if nargout > 0
    varargout{1} = [fInfo; fHelp];
    varargout{2} = fDatabase;
end

end % docindex

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