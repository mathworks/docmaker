function folder = docmakerroot()
%DOCMAKERROOT DocMaker root folder.

%   Copyright 2026 The MathWorks, Inc.

arguments ( Output )
    folder(1, 1) string {mustBeFolder}
end % arguments ( Output )

folder = fileparts( mfilename( "fullpath" ) );

end % docmakerroot