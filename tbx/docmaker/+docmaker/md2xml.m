function doc = md2xml( md, options )
%docmaker.md2xml  Convert Markdown to XML
%
%   DOC = docmaker.md2xml(MD) converts Markdown MD using the cmark-gfm MEX.
%   This is the default and runs offline.
%
%   DOC = docmaker.md2xml(MD,Converter="github") uses GitHub's Markdown
%   API instead. This requires network access; DOCMAKER_GITHUB_TOKEN is
%   optional.
%
%   See also docconvert, docmaker.githubgfm2html

%   Copyright 2026 The MathWorks, Inc.

arguments
    md (1,1) string
    options.Converter (1,1) string {mustBeMember( ...
        options.Converter, ["cmark", "github"])} = "cmark"
end

switch options.Converter
    case "cmark"
        % Check for a MEX binary built for this platform.
        mexFile = fullfile( fileparts( mfilename( "fullpath" ) ), ...
            "cmarkgfm2html." + mexext() );
        if ~isfile( mexFile )
            error( "docmaker:md2xml:MissingMEX", ...
                "The cmark-gfm MEX was not found: %s. " + ...
                "Run `buildtool mex` from the repository root to build " + ...
                "it for this MATLAB platform.", mexFile )
        end
        html = string( docmaker.cmarkgfm2html( md ) );
    case "github"
        html = docmaker.githubgfm2html( md );
end

doc = docmaker.html2xml( html );

end % md2xml
