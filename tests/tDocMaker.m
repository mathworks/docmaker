classdef tDocMaker < matlab.unittest.TestCase
    %TDOCMAKER Infrastructure for DocMaker tests.

    properties ( Access = protected )
        % Temporary folder.
        Folder(:, 1) string {mustBeFolder}
        % Example Markdown file.
        ExampleFile(:, 1) string {mustBeFile}
        % Example help table of contents file.
        HelpTOCFile(:, 1) string {mustBeFile}
    end % properties ( Access = protected )

    methods ( TestClassSetup )

        function setToken( testCase )
            %SETTOKEN Set the required token for use in BaT.

            token = "github_pat_11AVHHRSQ0glxgp2SgWJ0i_" + ...
                "5kHWdoDiAcaLFIi7DML84IKPefC68YUx85" + ...
                "gM7lkNlQSYLG2MSRFNS6MIhzK";
            name = "DOCMAKER_GITHUB_TOKEN";
            existingToken = getenv( name );
            testCase.addTeardown( @() setenv( name, existingToken ) )
            setenv( name, token )

        end % setToken

    end % methods ( TestClassSetup )

    methods ( TestMethodSetup )

        function applyFolderFixture( testCase )

            fixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.WorkingFolderFixture() );
            testCase.Folder = fixture.Folder;

        end % applyFolderFixture

        function copyExampleMarkdownFiles( testCase )

            testsFolder = fileparts( mfilename( "fullpath" ) );
            exampleMD = fullfile( testsFolder, "Example.md" );
            helptocMD = fullfile( testsFolder, "helptoc.md" );
            copyfile( exampleMD, testCase.Folder )
            copyfile( helptocMD, testCase.Folder )
            testCase.ExampleFile = ...
                fullfile( testCase.Folder, "Example.md" );
            testCase.HelpTOCFile = ...
                fullfile( testCase.Folder, "helptoc.md" );

        end % copyExampleMarkdownFiles

    end % methods ( TestMethodSetup )

end % classdef