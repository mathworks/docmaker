classdef ( Abstract ) Converter < handle
    %docmaker.Converter  Markdown converter
    %
    %   docmaker.Converter is an adapter API to facilitate conversion from
    %   Markdown to XML.

    %   Copyright 2024-2026 The MathWorks, Inc.

    methods
        xml = md2xml( md )
    end

end % classdef