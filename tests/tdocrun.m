classdef tdocrun < tDocMaker
    %TDOCRUN Tests for docrun.

    methods ( Test )

        function tRunningModifiesHTMLFile( testCase )

            outputFile = docconvert( testCase.ExampleFile, ...
                "Root", testCase.Folder );
            copiedOutputFile = fullfile( testCase.Folder, ...
                "CopiedExample.html" );
            copyfile( outputFile, copiedOutputFile )
            docrun( outputFile )

            originalContents = fileread( copiedOutputFile );
            newContents = fileread( outputFile );
            testCase.verifyNotEqual( originalContents, newContents, ...
                "docrun did not modify the example HTML file." )
            
        end % tRunningModifiesHTMLFile

    end % methods ( Test )

end % classdef