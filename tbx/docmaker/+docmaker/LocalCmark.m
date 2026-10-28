classdef LocalCmark < docmaker.MarkdownConverter
    %docmaker.LocalCmark  Local cmark-gfm Markdown converter
    %
    %   docmaker.LocalCmark uses the local cmark-gfm binary to convert
    %   Markdown to HTML without making network calls.
    %
    %   c = docmaker.LocalCmark() creates a converter using cmark-gfm on
    %   the system path.
    %
    %   c = docmaker.LocalCmark(b) uses the binary at path b.

    %   Copyright 2026 The MathWorks, Inc.

    properties ( SetAccess = immutable )
        Binary(1, 1) string
    end % properties ( SetAccess = immutable )

    methods

        function obj = LocalCmark( binary )
            %LocalCmark  Local cmark-gfm Markdown converter

            arguments ( Input )
                binary(1, 1) string = "cmark-gfm"
            end % arguments ( Input )

            validateBinary( binary )
            obj.Binary = binary;

        end % constructor

        function doc = md2xml( obj, md )
            %md2xml  Convert Markdown to XML
            %
            %   x = md2xml(c,md) converts the Markdown md to the XML
            %   document x using the local cmark-gfm binary.

            arguments ( Input )
                obj(1, 1) docmaker.LocalCmark
                md(1, 1) string
            end % arguments ( Input )

            % Write Markdown content to a temporary file.
            tmpIn = tempname() + ".md";
            cleaner = onCleanup( @() cleanupTempFile( tmpIn ) );
            writelines( md, tmpIn, "Encoding", "UTF-8" );

            % Invoke the binary on the temporary file.
            command = sprintf( [ ...
                '"%s" --extension table --extension strikethrough ' ...
                '--extension autolink --extension tasklist ' ...
                '--extension tagfilter --to html "%s" 2>&1' ], ...
                obj.Binary, tmpIn );
            [status, output] = system( command );
            xml = strip( string( output ) );

            if status ~= 0
                if xml == ""
                    xml = "No diagnostic output was returned.";
                end
                error( "docmaker:LocalCmark:ProcessFailed", ...
                    "Unable to run cmark-gfm binary ""%s"" " + ...
                    "(status %d): %s", ...
                    obj.Binary, status, xml )
            end % if

            % Close tags and parse.
            xml = docmaker.closetags( xml, "img" );
            xml = docmaker.closetags( xml, "hr" );
            xml = docmaker.closetags( xml, "br" );
            parser = matlab.io.xml.dom.Parser();
            doc = parser.parseString( "<div>" + xml + "</div>" );
            doc.XMLStandalone = true;

        end % md2xml

    end % methods

end % classdef

function validateBinary( binary )
%validateBinary  Reject binary values unsafe for shell invocation.

unsafeCharacters = ["""", "$", "`", "&", "|", "<", ">", "^", ...
    "%", "!", ";", newline, string( char( 13 ) )];
if any( contains( binary, unsafeCharacters ) )
    error( "docmaker:LocalCmark:InvalidBinary", ...
        "Binary must not contain shell metacharacters." )
end % if

end % validateBinary

function cleanupTempFile( filePath )
%cleanupTempFile  Delete a temporary file when it exists.

if isfile( filePath )
    delete( filePath )
end % if

end % cleanupTempFile
