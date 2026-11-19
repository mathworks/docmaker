function doc = md2xml( md, options )
%md2xml  Convert Markdown to XML
%
%   xml = docmaker.md2xml(md) converts Markdown md using the cmark-gfm MEX.
%   This is the default and runs offline.
%
%   xml = docmaker.md2xml(md,"Converter","github") uses GitHub's Markdown
%   API. The token DOCMAKER_GITHUB_TOKEN is optional.
%
%   xml = docmaker.md2xml(md,"Converter","gitlab") uses GitLab's Markdown
%   API. The token DOCMAKER_GITLAB_TOKEN is required.
%
%   See also docconvert, docmaker.githubmd2html, docmaker.gitlabmd2html

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
            "cmarkmd2html." + mexext() );
        if ~isfile( mex )
            error( "docmaker:md2xml:MissingMEX", ...
                "cmark-gfm converter not found: %s " + newline + ...
                "Run `buildtool mex` to build from source for this platform", ...
                mex )
        end
        html = string( docmaker.cmarkmd2html( md ) );
    case "github"
        html = docmaker.githubmd2html( md );
    case "gitlab"
        html = docmaker.gitlabmd2html( md );
        doc = docmaker.gitlabhtml2xml( html );
        return
end

doc = docmaker.html2xml( html );

end % md2xml
