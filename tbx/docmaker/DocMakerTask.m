classdef DocMakerTask < matlab.buildtool.Task
    %DOCMAKERTASK Generate toolbox documentation using DocMaker.
    %
    % See also docconvert, docrun, docindex

    properties
        % Documentation theme.
        DocTheme(1, 1) string {mustBeMember( DocTheme, ...
            ["light", "dark", "auto"] )} = "auto"
        % Stylesheets to include.
        Stylesheets(1, :) string {mustBeFile}
        % Scripts to include.
        Scripts(1, :) string {mustBeFile}
        % Root folder for publishing.
        Root(1, 1) string {mustBeFolder}
        % Renderer for LaTeX expressions.
        MathRenderer(1, 1) string {mustBeMember( MathRenderer, ...
            ["GitHub", "GitLab", "auto", "none"] )} = "none"
        % Batching level.
        Level(1, 1) double {mustBeInteger, ...
            mustBeInRange( Level, 0, 7 )} = 0
        % Figure theme.
        FigureTheme {docmaker.mustBeTheme( FigureTheme )} = "none"
        % Figure size.
        FigureSize(1, 2) double {mustBePositive, mustBeReal} = ...
            docmaker.getDefaultFigureSize()
    end % properties

    properties ( TaskInput )
        % Documentation files, in Markdown format.
        MarkdownFiles(1, :) matlab.buildtool.io.FileCollection
    end % properties ( TaskInput )

    properties ( TaskOutput, SetAccess = private )
        % Documentation files, in HTML format.
        HTMLFiles(1, :) matlab.buildtool.io.FileCollection        
        % Table of contents and doc metadata: helptoc.xml and info.xml.
        XMLFiles(1, :) matlab.buildtool.io.FileCollection
        % Documentation resources folder.
        Resources(1, :) matlab.buildtool.io.FileCollection
        % Documentation search index.
        HelpSearchIndex(1, :) matlab.buildtool.io.FileCollection
    end % properties ( TaskOutput, SetAccess = private )    

    methods

        function task = DocMakerTask( markdownFiles, namedArgs )
            %DOCMAKERTASK 

            arguments ( Input, Repeating )
                markdownFiles
            end % arguments ( Input, Repeating )

            arguments ( Input )
                namedArgs.?DocMakerTask
            end % arguments ( Input )

            task.MarkdownFiles = markdownFiles;
            task.Name = "doc";
            task.Description = ...
                "Generate toolbox documentation using DocMaker";


            
        end % constructor

        function outputArg = method1(obj,inputArg)
            %METHOD1 undefined
            %   undefined
            outputArg = obj.Property1 + inputArg;
        end
    end

    methods ( TaskAction )


    end % methods ( TaskAction )

end % classdef

function s = getDefaultFigureSize()
%getDefaultFigureSize  Default figure size

p = get( 0, "DefaultFigurePosition" ); % [x y w h]
s = p(3:4); % [w h]

end % getDefaultFigureSize