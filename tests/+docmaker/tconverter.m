classdef tconverter < matlab.unittest.TestCase
    %TCONVERTER Tests for DocMaker converter configuration.

    methods ( Test )

        function tEmptyGitHubTokenIsMissing( testCase )

            converter = docmaker.GitHub( "api.github.com", "" );

            testCase.verifyClass( converter, "docmaker.GitHub" )
            testCase.verifyTrue( ismissing( converter.Token ), ...
                "An empty GitHub token should not authenticate requests." )

        end % tEmptyGitHubTokenIsMissing

        function tEmptyGitLabTokenIsMissing( testCase )

            converter = docmaker.GitLab( "gitlab.com", "" );

            testCase.verifyClass( converter, "docmaker.GitLab" )
            testCase.verifyTrue( ismissing( converter.Token ), ...
                "An empty GitLab token should not authenticate requests." )

        end % tEmptyGitLabTokenIsMissing

    end % methods ( Test )

end % classdef
