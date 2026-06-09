classdef tDocMakerTask < matlab.unittest.TestCase
    %TDOCMAKERTASK Tests for DocMakerTask.

    properties ( Access = private )
        % Custom build task.
        Task(:, 1) matlab.buildtool.Task {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods ( TestClassSetup )

        function filterVersion( testCase )
            
            testCase.assumeTrue( ~isMATLABReleaseOlderThan( "R2025a" ), ...
                "This test is for R2025a or later." )

        end % filterVersion        

    end % methods ( TestClassSetup )

    methods ( TestMethodSetup )

        function setupTask( testCase )

            tests = fileparts( mfilename( "fullpath" ) );            
            md = fullfile( tests, "Example.md" );
            testCase.Task = DocMakerTask( md, ...
                "Theme", "light", ...
                "FigureTheme", "light", ...
                "FigureSize", [600, 400] );
            testCase.Task.Outputs = [ ...
                fullfile( tests, "Example.html" ), ...
                fullfile( tests, "*.xml" ), ...
                fullfile( tests, "resources" ), ...
                fullfile( tests, "helpsearch-v*" )];

        end % setupTask
        
    end % methods ( TestMethodSetup )

    methods ( Test )

        function tExecutingTaskIsWarningFree( testCase )

            taskRunner = @() testCase.Task.buildDoc();
            tests = string( fileparts( mfilename( "fullpath" ) ) ); 
            html = fullfile( tests, "Example.html" );
            xml = fullfile( tests, "*.xml" );            
            resources = fullfile( tests, "resources" );
            helpsearch = fullfile( tests, "helpsearch-v*" );
            disp( resources )
            disp( helpsearch )

            testCase.addTeardown( @() delete( html ) )
            testCase.addTeardown( @() delete( xml ) )
            testCase.addTeardown( @() rmdir( resources, ...
                "Recursive", true ) )
            testCase.addTeardown( @() rmdir( helpsearch, ...
                "Recursive", true ) )
            testCase.verifyWarningFree( taskRunner, ...
                "Running the DocMakerTask was not warning-free." )

        end % tExecutingTaskIsWarningFree

    end % methods ( Test )

end % classdef