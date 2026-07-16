classdef tDocMakerTask < matlab.unittest.TestCase
    %TDOCMAKERTASK Tests for DocMakerTask.

    properties ( Access = private )
        % Custom build task.
        Task(:, 1) matlab.buildtool.Task {mustBeScalarOrEmpty}
        % Tests folder.
        TestsFolder(:, 1) string {mustBeFolder, mustBeScalarOrEmpty}
        % Test file name.
        TestFile(1, 1) string = "Example.md"
    end % properties ( Access = private )

    methods ( TestClassSetup )

        function filterVersion( testCase )
            
            testCase.assumeTrue( ~isMATLABReleaseOlderThan( "R2025a" ), ...
                "This test is for R2025a or later." )

        end % filterVersion        

        function setTestsFolder( testCase )

            testCase.TestsFolder = fileparts( mfilename( "fullpath" ) );

        end % setTestsFolder

    end % methods ( TestClassSetup )

    methods ( TestMethodSetup )

        function setupTask( testCase )
                   
            md = fullfile( testCase.TestsFolder, testCase.TestFile );
            testCase.Task = DocMakerTask( md, ...
                "Theme", "light", ...
                "FigureTheme", "light", ...
                "FigureSize", [600, 400] );           

        end % setupTask
        
    end % methods ( TestMethodSetup )

    methods ( Test )

        function tTaskArgumentsAreSetCorrectly( testCase )
            
            % Write down the expected task inputs and outputs.
            md = fullfile( testCase.TestsFolder, testCase.TestFile );
            [~, name] = fileparts( testCase.TestFile );
            html = fullfile( testCase.TestsFolder, name + ".html" );
            xml = fullfile( testCase.TestsFolder, ...
                ["info.xml", "helptoc.xml"] );
            res = fullfile( testCase.TestsFolder, "resources" );
            ind = fullfile( testCase.TestsFolder, "helpsearch-v*" );

            % Check that the task arguments have been set correctly.
            fc = @matlab.buildtool.io.FileCollection.fromPaths;
            testCase.verifyEqual( testCase.Task.MarkdownFiles, ...
                fc( md ), ...
                "The task input files were not set correctly." )
            testCase.verifyEqual( testCase.Task.HTMLFiles, ...
                fc( html ), ...
                "The task output HTML files were not set correctly." )
            testCase.verifyEqual( testCase.Task.XMLFiles, ...
                fc( xml ), ...
                "The task output XML files were not set correctly." )
            testCase.verifyEqual( testCase.Task.Resources, ...
                fc( res ), ...
                "The task output resources folder was not set correctly." )
            testCase.verifyEqual( testCase.Task.SearchIndex, ...
                fc( ind ), ...
                "The task output search index folder was not set " + ...
                "correctly." )

        end % tTaskArgumentsAreSetCorrectly

        function tExecutingTaskIsWarningFree( testCase )

            taskRunner = @() testCase.Task.buildDoc();
            tests = string( fileparts( mfilename( "fullpath" ) ) ); 
            html = fullfile( tests, "Example.html" );
            xml = fullfile( tests, "*.xml" );            
            resources = fullfile( tests, "resources" );
            helpsearch = fullfile( tests, "helpsearch-v*" );

            ci = strcmp( getenv( "GITHUB_ACTIONS" ), "true" );
            if ~ci
                testCase.addTeardown( @() delete( html ) )
                testCase.addTeardown( @() delete( xml ) )
                testCase.addTeardown( @() rmdir( resources, ...
                    "Recursive", true ) )
                testCase.addTeardown( @() rmdir( helpsearch, ...
                    "Recursive", true ) )
            end % if

            testCase.verifyWarningFree( taskRunner, ...
                "Running the DocMakerTask was not warning-free." )

        end % tExecutingTaskIsWarningFree

    end % methods ( Test )

end % classdef