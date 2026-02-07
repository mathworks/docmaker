function c = converter()
%docmaker.converter  Get Markdown converter
%
%   c = docmaker.converter() returns the current Markdown converter.
%
%   The converter can be "GitHub" (default) or "GitLab" and is controlled
%   by the environment variable DOCMAKER_CONVERTER, the secret "DocMaker
%   converter" or the preference "converter".
%
%   The GitHub hostname and token are stored in DOCMAKER_GITHUB_HOSTNAME
%   and DOCMAKER_GITHUB_TOKEN, "DocMaker GitHub hostname" and "DocMaker
%   GitHub token", or "github_hostname" and "github_token". The same naming
%   convention applies to GitLab.

%   Copyright 2024-2026 The MathWorks, Inc.

n = getValue( "converter", "GitHub" );
switch lower( n )
    case "github"
        h = getValue( "GitHub hostname", "api.github.com" );
        t = getValue( "GitHub token", "" );
        c = docmaker.GitHub( h, t );
    case "gitlab"
        h = getValue( "GitLab hostname", "www.gitlab.com" );
        t = getValue( "GitLab token", "" );
        c = docmaker.GitLab( h, t );
    otherwise
        error( "docmaker:Unhandled", "Unknown converter ""%s"".", n )
end

end % getDefaultConverter

function value = getValue( shortName, defaultValue )
%getValue  Get value from environment variables, secrets, or preferences
%
%   v = getValue(n,d) gets the value of the variable n from environment
%   variables, secrets, or preferences. If not found the default value d is
%   used.

envName = "DOCMAKER_" + upper( strrep( shortName, " ", "_" ) );
secretName = "DocMaker " + shortName;
prefName = lower( strrep( shortName, " ", "_" ) );
if isenv( envName )
    value = getenv( envName );
elseif hasSecrets() && isSecret( secretName )
    value = getSecret( secretName );
elseif ispref( "docmaker", prefName )
    value = getpref( "docmaker", prefName );
else
    value = defaultValue;
end

end % getValue

function tf = hasSecrets()
%hasSecrets  Test whether MATLAB has secrets
%
%   tf = hasSecrets() returns true if MATLAB has secrets, and false
%   otherwise.
%
%   MATLAB Vault is not available prior to R2024a and in some environments.

if isMATLABReleaseOlderThan( "R2024a" )
    tf = false;
else
    try
        [~] = listSecrets();
        tf = true;
    catch
        tf = false;
    end
end

end % hasSecrets