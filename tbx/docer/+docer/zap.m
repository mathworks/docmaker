function zap( div, w )
%zap  Execute MATLAB code and insert textual and graphical output
%
%   zap(d,w) executes the MATLAB code block from the div d in the workspace
%   w, and inserts the textual and graphical output between d and its next
%   sibling.
%
%   Textual output is text written to the command window.  Graphical output
%   is new figures or changes to existing figures.

%   Copyright 2024 The MathWorks, Inc.

% Get related helper elements
doc = div.getOwnerDocument(); % for node creation
next = div.getNextSibling(); % for result insertion

% Extract code
inDiv = div;
inString = div.TextContent;

%%%
expr = inString;
%%%

% Capture initial figures and their 'prints
oldFigures = docer.figures();
oldPrints = arrayfun( @docer.capture, oldFigures, "UniformOutput", false );

% Evaluate expression and capture output
try
    output = string( evalinc( w, expr ) );
catch e
    rethrow( e ) % trim stack
end

% Capture final figures and their 'prints
newFigures = docer.figures();
newPrints = arrayfun( @docer.capture, newFigures, "UniformOutput", false );

% Return new and modified figures
wasPrints = cell( size( newPrints ) ); % preallocate
[tf, loc] = ismember( oldFigures, newFigures ); % match
wasPrints(loc(tf)) = oldPrints(tf); % corresponding
modFigures = newFigures(~cellfun( @isequal, newPrints, wasPrints )); % select
modFigures = modFigures(:); % return column vector

%%%
outString = output;
outFigs = modFigures;
%%%

% Add text output
if strlength( outString ) > 0

    % Strip out markup
    parser = matlab.io.xml.dom.Parser();
    outDoc = parser.parseString( "<pre>" + strtrim( outString ) + "</pre>" );
    outString = strtrim( outDoc.getDocumentElement().TextContent );

    % Create HTML elements div, pre, text
    outDiv = doc.createElement( "div" );
    outDiv.setAttribute( "class", "highlight highlight-output-matlab" );
    outPre = doc.createElement( "pre" );
    outPre.setAttribute( "style", "background-color:var(--bgColor-default);" );
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

end % zap