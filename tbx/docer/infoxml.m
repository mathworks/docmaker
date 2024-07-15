function doc = infoxml( name )
%infoxml  Create info.xml document
%
%  x = infoxml(n) creates an info.xml document x with name n.

arguments
    name (1,1) string
end

% Handle inputs
if endsWith( name, " Toolbox" )
    name = extractBefore( name, " Toolbox" );
end

% Create document
doc = matlab.io.xml.dom.Document( "productname" );
doc.XMLStandalone = true;
pn = getDocumentElement( doc ); % root

% Add elements
addElement( pn, "matlabrelease", matlabRelease().Release )
addElement( pn, "name", name )
addElement( pn, "type", "toolbox" )
addElement( pn, "icon", "$toolbox/matlab/icons/bookicon.gif" )
addElement( pn, "help_location", "." )

end % infoxml

function addElement( parent, name, value )
%addElement  Add element to node
%
%  addElement(p,n,v) adds an element with tag name n and value v to the
%  parent node p.

doc = getOwnerDocument( parent ); % document
el = createElement( doc, name ); % create
el.TextContent = value; % set value
appendChild( parent, el ); % add

end % addElement