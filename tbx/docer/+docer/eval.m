function [output, modFigures] = eval( w, expr )
%eval  Run code in workspace, return output and figures
%
%   [c,f] = docer.eval(w,b) evaluates the block b in the workspace w, and
%   returns the command window output c and the created or modified figures
%   f.

%   Copyright 2024 The MathWorks, Inc.

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

end % eval