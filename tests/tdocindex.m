classdef tdocindex < tDocMaker
    %TDOCINDEX Tests for docindex.

    methods ( Test )

        function tIndexCreatesExpectedFiles( testCase )

            outputFile = docconvert( testCase.ExampleFile, ...
                "Root", testCase.Folder );
            docrun( outputFile )
            [files, folders] = docindex( testCase.Folder );
            testCase.verifyEqual( files(1), ...
                fullfile( testCase.Folder, "info.xml" ), ...
                "docindex did not generate info.xml." )
            testCase.verifyEqual( files(2), ...
                fullfile( testCase.Folder, "helptoc.xml" ), ...
                "docindex did not generate helptoc.xml." )
            testCase.verifyEqual( folders, ...
                fullfile( testCase.Folder, "helpsearch-v4_en" ), ...
                "docindex did not generate the " + ...
                "documentation search database." )

        end % tIndexCreatesExpectedFiles

    end % methods ( Test )

end % classdef