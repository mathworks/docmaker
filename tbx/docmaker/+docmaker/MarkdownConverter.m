classdef ( Abstract ) MarkdownConverter < handle
    %docmaker.MarkdownConverter  Markdown converter
    %
    %   docmaker.MarkdownConverter is an adapter API to facilitate
    %   conversion from Markdown to XML.

    %   Copyright 2024-2026 The MathWorks, Inc.

    methods
        xml = md2xml( md )
    end

    methods ( Static, Access = protected )

        function token = normalizeToken( token )
            %normalizeToken  Normalize an access token

            arguments
                token(1, 1) string
            end

            if ~ismissing( token ) && strlength( token ) == 0
                token = missing;
            end

        end % normalizeToken

    end % methods ( Access = protected )

end % classdef
