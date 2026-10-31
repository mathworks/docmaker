classdef CMarkGFM < docmaker.MarkdownConverter
    %docmaker.CMarkGFM  CommonMark Markdown converter
    %
    %   docmaker.CMarkGFM is an adapter to cmark-gfm to facilitate
    %   conversion from Markdown to XML. Conversion works offline and does
    %   not require internet access.
    %
    %   c = docmaker.CMarkGFM() creates a CommonMark adapter.
    %
    %   For details on cmark-gfm, see: https://github.com/github/cmark-gfm

    %   Copyright 2026 The MathWorks, Inc.

    methods

        function doc = md2xml( obj, md )
            %md2xml  Convert Markdown to XML
            %
            %   x = md2xml(c,md) converts the Markdown md to the XML
            %   document x using the cmark-gfm adapter.

            arguments
                obj (1,1) docmaker.CMarkGFM %#ok<INUSA>
                md (1,1) string
            end

            % Check for a MEX binary built for this platform.
            mexFile = fullfile( fileparts( mfilename( "fullpath" ) ), ...
                "cmarkgfm2html." + mexext() );
            if ~isfile( mexFile )
                error( "docmaker:CMarkGFM:MissingMEX", ...
                    ["The cmark-gfm converter requires a MEX binary " ...
                    "for this platform. Set DOCMAKER_CONVERTER to " ...
                    """github"" or ""gitlab"" to use another converter."] )
            end

            % Convert Markdown to HTML.
            html = string( docmaker.cmarkgfm2html( md ) );
            html = strtrim( html );

            % Close HTML void elements to ensure valid XML.
            html = docmaker.closetags( html, "img" );
            html = docmaker.closetags( html, "hr" );
            html = docmaker.closetags( html, "br" );
            html = docmaker.closetags( html, "input" );

            % Wrap in div.
            parser = matlab.io.xml.dom.Parser();
            doc = parser.parseString( "<div>" + html + "</div>" );
            doc.XMLStandalone = true;

            % Normalize MATLAB code blocks for docrun.
            pres = docmaker.list2array( doc.getElementsByTagName( "pre" ) );
            for ii = 1:numel( pres )
                pre = pres(ii);
                codes = docmaker.list2array( ...
                    pre.getElementsByTagName( "code" ) );
                if isempty( codes ) || ...
                        ~docmaker.hasclass( codes(1), "language-matlab" )
                    continue
                end

                % cmark-gfm adds a final newline to fenced code blocks.
                code = codes(1);
                content = string( code.TextContent );
                if endsWith( content, newline() )
                    code.TextContent = ...
                        extractBefore( content, strlength( content ) );
                end

                % docrun identifies MATLAB source by this wrapper class.
                div = doc.createElement( "div" );
                div.setAttribute( "class", ...
                    "highlight highlight-source-matlab" );
                parent = pre.getParentNode();
                parent.insertBefore( div, pre );
                div.appendChild( pre );
            end

        end % md2xml

    end % methods

end % classdef
