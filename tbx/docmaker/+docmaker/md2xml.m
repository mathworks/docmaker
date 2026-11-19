function doc = md2xml( md, options )
%docmaker.md2xml  Convert Markdown to XML
%
%   DOC = docmaker.md2xml(MD) converts Markdown MD using the cmark-gfm MEX.
%   This is the default and runs offline.
%
%   DOC = docmaker.md2xml(MD,Converter="github") uses GitHub's Markdown
%   API. DOCMAKER_GITHUB_TOKEN is optional.
%
%   DOC = docmaker.md2xml(MD,Converter="gitlab") uses GitLab's Markdown
%   API. Set the MATLAB Secret or environment variable
%   DOCMAKER_GITLAB_TOKEN before using this converter.
%
%   See also docconvert, docmaker.githubgfm2html,
%   docmaker.gitlabgfm2html

%   Copyright 2026 The MathWorks, Inc.

arguments
    md (1,1) string
    options.Converter (1,1) string {mustBeMember( ...
        options.Converter, ["cmark", "github", "gitlab"])} = "cmark"
end

switch options.Converter
    case "cmark"
        % Check for a MEX binary built for this platform.
        mex = fullfile( fileparts( mfilename( "fullpath" ) ), ...
            "cmarkgfm2html." + mexext() );
        if ~isfile( mex )
            error( "docmaker:md2xml:MissingMEX", ...
                "cmark-gfm converter not found: %s " + newline + ...
                "Run `buildtool mex` to build from source for this platform", ...
                mex )
        end
        html = string( docmaker.cmarkgfm2html( md ) );
    case "github"
        html = docmaker.githubgfm2html( md );
    case "gitlab"
        html = docmaker.gitlabgfm2html( md );
        doc = docmaker.gitlabhtml2xml( html );
        return
end

doc = docmaker.html2xml( html );

end % md2xml
