function doc = md2xml( md, options )
%docmaker.md2xml  Convert Markdown to XML
%
%   doc = docmaker.md2xml(md) converts Markdown md using the cmark-gfm MEX.
%   This is the default and runs offline.
%
%   doc = docmaker.md2xml(md,"Converter","github") uses GitHub's Markdown
%   API. The hostname defaults to "api.github.com"; set
%   DOCMAKER_GITHUB_HOSTNAME to override it. The token
%   DOCMAKER_GITHUB_TOKEN is optional.
%
%   doc = docmaker.md2xml(md,"Converter","gitlab") uses GitLab's Markdown
%   API. The hostname defaults to "gitlab.com"; set
%   DOCMAKER_GITLAB_HOSTNAME to override it. The token
%   DOCMAKER_GITLAB_TOKEN is required.
%
%   See also: docconvert, docmaker.apimd2html

%   Copyright 2026 The MathWorks, Inc.

arguments
    md (1,1) string
    options.Converter (1,1) string {mustBeMember( ...
        options.Converter, ["cmark", "github", "gitlab"])} = "cmark"
end

% Convert Markdown to HTML
switch options.Converter
    case "cmark"
        % Check for a MEX binary built for this platform.
        mex = fullfile( fileparts( mfilename( "fullpath" ) ), ...
            "cmarkmd2html." + mexext() );
        if ~isfile( mex )
            error( "docmaker:NotFound", ...
                "cmark-gfm converter not found: %s " + newline + ...
                "Run `buildtool mex` to build from source for this platform", ...
                mex )
        end
        html = string( docmaker.cmarkmd2html( md ) );
    case {"github", "gitlab"}
        html = docmaker.apimd2html( md, options.Converter );
end

% Convert HTML to XML
doc = docmaker.html2xml( html );

% Fix XML
switch options.Converter
    case "gitlab"
        docmaker.gitlabfixxml( doc )
end

end % md2xml
