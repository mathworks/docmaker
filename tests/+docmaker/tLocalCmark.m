classdef tLocalCmark < matlab.unittest.TestCase
    %TLOCALCMARK Tests for the local cmark-gfm converter.

    methods ( Test )

        function tConstructorStoresBinary( testCase )

            converter = docmaker.LocalCmark( "test-cmark" );

            testCase.verifyEqual( converter.Binary, "test-cmark" )

        end % tConstructorStoresBinary

        function tConstructorRejectsShellMetacharacters( testCase )

            testCase.verifyError( ...
                @() docmaker.LocalCmark( "cmark-gfm & other-command" ), ...
                "docmaker:LocalCmark:InvalidBinary" )

        end % tConstructorRejectsShellMetacharacters

        function tConverterUsesConfiguredBinary( testCase )

            converterWasSet = isenv( "DOCMAKER_CONVERTER" );
            binaryWasSet = isenv( "DOCMAKER_LOCALCMARK_BINARY" );
            originalConverter = getenv( "DOCMAKER_CONVERTER" );
            originalBinary = getenv( "DOCMAKER_LOCALCMARK_BINARY" );
            cleanup = onCleanup( @() restoreEnvironment( ...
                converterWasSet, originalConverter, ...
                binaryWasSet, originalBinary ) );
            setenv( "DOCMAKER_CONVERTER", "LocalCmark" )
            setenv( "DOCMAKER_LOCALCMARK_BINARY", "test-cmark" )

            converter = docmaker.converter();

            testCase.verifyClass( converter, "docmaker.LocalCmark" )
            testCase.verifyEqual( converter.Binary, "test-cmark" )

        end % tConverterUsesConfiguredBinary

        function tUnavailableBinaryFailsClearly( testCase )

            converter = docmaker.LocalCmark( "missing-cmark-gfm-binary" );

            testCase.verifyError( @() converter.md2xml( "# Heading" ), ...
                "docmaker:LocalCmark:ProcessFailed" )

        end % tUnavailableBinaryFailsClearly

        function tConvertsGfmExtensions( testCase )

            assumeCmarkAvailable( testCase )
            converter = docmaker.LocalCmark();
            markdown = ...
                "# Heading" + newline + ...
                "| A | B |" + newline + ...
                "| - | - |" + newline + ...
                "| 1 | 2 |" + newline + ...
                "~~old~~ <https://example.com>" + newline + ...
                "- [ ] Task" + newline + ...
                "<script>alert('x')</script>";

            document = converter.md2xml( markdown );
            testCase.verifyTrue( hasElement( document, "table" ) )
            testCase.verifyTrue( hasElement( document, "del" ) )
            testCase.verifyTrue( hasElement( document, "input" ) )
            testCase.verifyFalse( hasElement( document, "script" ) )

        end % tConvertsGfmExtensions

        function tDocconvertCleansLaTeXExpressions( testCase )

            assumeCmarkAvailable( testCase )
            converterWasSet = isenv( "DOCMAKER_CONVERTER" );
            binaryWasSet = isenv( "DOCMAKER_LOCALCMARK_BINARY" );
            originalConverter = getenv( "DOCMAKER_CONVERTER" );
            originalBinary = getenv( "DOCMAKER_LOCALCMARK_BINARY" );
            cleanup = onCleanup( @() restoreEnvironment( ...
                converterWasSet, originalConverter, ...
                binaryWasSet, originalBinary ) );
            setenv( "DOCMAKER_CONVERTER", "LocalCmark" )
            setenv( "DOCMAKER_LOCALCMARK_BINARY", "cmark-gfm" )
            fixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.WorkingFolderFixture() );
            markdownFile = fullfile( fixture.Folder, "LaTeX.md" );
            markdown = "$$ \Phi = \frac{\dot{m}_{th}}{2} $$";
            writelines( markdown, markdownFile )

            output = docconvert( markdownFile, "Root", fixture.Folder, ...
                "Interpreter", "latex" );
            html = string( fileread( output ) );

            testCase.verifyTrue( contains( html, "\dot{m}_{th}" ) )
            testCase.verifyFalse( contains( html, "<em>" ) )

        end % tDocconvertCleansLaTeXExpressions

    end % methods ( Test )

end % classdef

function assumeCmarkAvailable( testCase )
%assumeCmarkAvailable  Skip integration coverage without cmark-gfm.

[status, ~] = system( '"cmark-gfm" --version 2>&1' );
testCase.assumeEqual( status, 0, ...
    "cmark-gfm is required for LocalCmark integration tests." )

end % assumeCmarkAvailable

function tf = hasElement( document, name )
%hasElement  Return true when a DOM document contains an element.

tf = document.getElementsByTagName( name ).getLength() > 0;

end % hasElement

function restoreEnvironment( converterWasSet, converter, binaryWasSet, binary )
%restoreEnvironment  Restore LocalCmark converter environment variables.

if converterWasSet
    setenv( "DOCMAKER_CONVERTER", converter )
else
    unsetenv( "DOCMAKER_CONVERTER" )
end

if binaryWasSet
    setenv( "DOCMAKER_LOCALCMARK_BINARY", binary )
else
    unsetenv( "DOCMAKER_LOCALCMARK_BINARY" )
end

end % restoreEnvironment
