classdef tDocMaker < matlab.unittest.TestCase
    %TDOCMAKER Infrastructure for DocMaker tests.

    properties ( Access = protected )
        % Temporary folder.
        Folder(:, 1) string {mustBeFolder}
        % Example Markdown document.
        ExampleFile(:, 1) string {mustBeFile}
        % Example help table of contents file.
        HelpTOCFile(:, 1) string {mustBeFile}
    end % properties ( Access = protected )

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