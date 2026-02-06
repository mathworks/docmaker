classdef ( Abstract ) MarkdownConverter < handle
    %docmaker.MarkdownConverter  Markdown converter
    %
    %   docmaker.MarkdownConverter is an adapter API to facilitate
    %   conversion from Markdown to XML.

    %   Copyright 2024-2026 The MathWorks, Inc.

    methods
        xml = md2xml( md )
    end

end % classdef