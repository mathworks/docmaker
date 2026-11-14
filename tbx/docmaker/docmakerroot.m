function folder = docmakerroot()
%docmakerroot  Return the DocMaker root folder
%
%   folder = docmakerroot() returns the folder containing the DocMaker
%   toolbox source.

%   Copyright 2026 The MathWorks, Inc.

arguments ( Output )
    folder(1, 1) string {mustBeFolder}
end % arguments ( Output )

folder = fileparts( mfilename( "fullpath" ) );

end % docmakerroot
