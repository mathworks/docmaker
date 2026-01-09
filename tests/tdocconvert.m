classdef tdocconvert < tDocMaker
    %TDOCCONVERT Tests for docconvert.

    methods ( Test )

        function tConversionProducesHTMLFile( testCase )

            output = docconvert( testCase.ExampleFile, ...
                "Root", testCase.Folder );
            testCase.verifyTrue( isfile( output ), ...
                "docconvert failed to produce a file." )

            [~, ~, ext] = fileparts( output );
            testCase.verifyEqual( ext, ".html", ...
                "docconvert failed to produce an HTML file." )

        end % tConversionProducesHTMLFile
        
    end % methods ( Test )

end % classdef