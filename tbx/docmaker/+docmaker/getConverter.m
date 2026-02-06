function converter = getConverter()

converterName = getValue( "converter", "GitHub" );
switch lower( converterName )
    case "github"
        hostname = getValue( "GitHub hostname", "api.github.com" );
        token = getValue( "GitHub token", "" );
        converter = docmaker.GitHub( hostname, token );
    case "gitlab"
        hostname = getValue( "GitLab hostname", "www.gitlab.com" );
        token = getValue( "GitLab token", "" );
        converter = docmaker.GitLab( hostname, token );
    otherwise
        error( "docmaker:Unhandled", "Unknown converter ""%s"".", converterName )
end

end % getDefaultConverter

function value = getValue( shortName, defaultValue )

envName = "DOCMAKER_" + upper( strrep( shortName, " ", "_" ) );
secretName = "DocMaker " + shortName;
prefName = lower( strrep( shortName, " ", "_" ) );
if isenv( envName )
    value = getenv( envName );
elseif isSecret( secretName )
    value = getSecret( secretName );
elseif ispref( "docmaker", prefName )
    value = getpref( "docmaker", prefName );
else
    value = defaultValue;
end

end % getValue