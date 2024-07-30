function run( filename )

% Capture initial figures
oldFigures = docer.figures();

% Schedule cleanup
cu = onCleanup( @()delete( setdiff( docer.figures(), oldFigures ) ) );

% Create workspace
w = docer.Workspace();

% Parse document
parser = matlab.io.xml.dom.Parser();
parser.Configuration.AllowDoctype = true;
doc = parser.parseFile( filename );

% Process divs
divs = doc.getElementsByTagName( "div" );
divs = list2array( divs );
for ii = 1:numel( divs )
    div = divs( ii );
    if div.hasAttribute( "class" ) && contains( ...
            div.getAttribute( "class" ), "highlight-source-matlab" )
        inDiv = div; % code block
        inString = div.TextContent; % extract text
        [outString, outFigs] = docer.eval( w, inString ); % evaluate and capture
        for ii = 1:numel( outFigs )
            outFig = outFigs(ii);
            outDiv = doc.createElement( "div" );
            outDiv.setAttribute( "class", "highlight highlight-output-matlab" );
            outImg = doc.createElement( "img" );
            outImg.setAttribute( "src", "data:image/png;base64, " + ...
                docer.encode( docer.capture( outFig ) ) );
            outDiv.appendChild( outImg );
            if isempty( inDiv.getNextSibling() )
                inDiv.getParentNode().appendChild( outDiv );
            else
                inDiv.getParentNode().insertBefore( ...
                    outDiv, inDiv.getNextSibling() );
            end
        end
        if strlength( outString ) > 0
            outString = textcontent( outString ); %
            outDiv = doc.createElement( "div" );
            outDiv.setAttribute( "class", "highlight highlight-output-matlab" );
            outPre = doc.createElement( "pre" );
            outDiv.appendChild( outPre );
            outText = doc.createTextNode( outString );
            outPre.appendChild( outText );
            if isempty( inDiv.getNextSibling() )
                inDiv.getParentNode().appendChild( outDiv );
            else
                inDiv.getParentNode().insertBefore( ...
                    outDiv, inDiv.getNextSibling() );
            end
        end
    elseif div.hasAttribute( "class" ) && contains( ...
            div.getAttribute( "class" ), "highlight-output-matlab" )
        div.getParentNode().removeChild( div );
    end
end
writer = matlab.io.xml.dom.DOMWriter();
writer.writeToFile( doc, filename );

end

function t = textcontent( s )

s = strtrim( s );
parser = matlab.io.xml.dom.Parser();
doc = parser.parseString( "<pre>" + s + "</pre>" );
t = doc.getDocumentElement().TextContent;
t = strtrim( t );

end % textcontent

function array = list2array( list )

array = matlab.io.xml.dom.Element.empty( 1, 0 );
for ii = 1:list.Length
    array(ii) = list.node( ii );
end

end