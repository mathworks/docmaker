function run( filename )

% Capture initial figures
oldFigures = docer.figures();
cu = onCleanup( @()delete( setdiff( docer.figures(), oldFigures ) ) );

% Create workspace
w = docer.Workspace();

% Read from file
parser = matlab.io.xml.dom.Parser();
parser.Configuration.AllowDoctype = true;
doc = parser.parseFile( filename );

% Find all divs
divs = doc.getElementsByTagName( "div" );
divs = list2array( divs );

% Process divs
for ii = 1:numel( divs )

    div = divs( ii );
    next = div.getNextSibling();

    if div.hasAttribute( "class" ) && contains( ... % MATLAB input
            div.getAttribute( "class" ), "highlight-source-matlab" )

        % Extract code
        inDiv = div;
        inString = div.TextContent;

        % Evaluate code and capture output
        [outString, outFigs] = docer.eval( w, inString );

        % Add text output
        if strlength( outString ) > 0

            % Strip out markup
            outString = textcontent( outString );

            % Create HTML elements div, pre, text
            outDiv = doc.createElement( "div" );
            outDiv.setAttribute( "class", "highlight highlight-output-matlab" );
            outPre = doc.createElement( "pre" );
            outDiv.appendChild( outPre );
            outText = doc.createTextNode( outString );
            outPre.appendChild( outText );

            % Add output to document
            if isempty( next )
                inDiv.getParentNode().appendChild( outDiv ); % end
            else
                inDiv.getParentNode().insertBefore( outDiv, next );
            end

        end

        % Add figure output
        for jj = 1:numel( outFigs )

            outFig = outFigs(jj);

            % Create HTML elements div, img
            outDiv = doc.createElement( "div" );
            outDiv.setAttribute( "class", "highlight highlight-output-matlab" );
            outImg = doc.createElement( "img" );
            outImg.setAttribute( "src", "data:image/png;base64, " + ...
                docer.encode( outFig ) );
            outDiv.appendChild( outImg );

            % Add output to document
            if isempty( next )
                inDiv.getParentNode().appendChild( outDiv ); % end
            else
                inDiv.getParentNode().insertBefore( outDiv, next );
            end

        end

    elseif div.hasAttribute( "class" ) && contains( ... % MATLAB output
            div.getAttribute( "class" ), "highlight-output-matlab" )

        % Delete
        div.getParentNode().removeChild( div );

    end

end

% Write to file
writer = matlab.io.xml.dom.DOMWriter();
writer.writeToFile( doc, filename );

end % run

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