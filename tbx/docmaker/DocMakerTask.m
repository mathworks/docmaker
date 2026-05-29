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
        Root(1, :) string {mustBeFolder, mustBeScalarOrEmpty}
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
        % Folder containing documentation files in Markdown format.
        MarkdownFolder(1, :) matlab.buildtool.io.FileCollection
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

        function task = DocMakerTask( markdownFolder, namedArgs )
            %DOCMAKERTASK Construct the DocMaker build task.

            arguments ( Input )
                markdownFolder
                namedArgs.?DocMakerTask
            end % arguments ( Input )

            % Assign the markdown folder and task outputs.
            task.MarkdownFolder = markdownFolder;
            task.HTMLFiles = fullfile( markdownFolder, "**", "*.html" );
            task.XMLFiles = fullfile( markdownFolder, "*.xml" );
            task.Resources = fullfile( markdownFolder, "resources" );
            task.HelpSearchIndex = ...
                fullfile( markdownFolder, "helpsearch-v*" );

            % Add the task metadata.
            task.Description = ...
                "Generate toolbox documentation using DocMaker";

            % Assign any user-specified properties.
            props = string( fieldnames( namedArgs ).' );
            for prop = props
                task.(prop) = namedArgs.(prop);
            end % for

        end % constructor

    end % methods

    methods ( TaskAction )

        function buildDoc( task, ~ )
            %BUILDDOC Build the toolbox documentation.
            %
            % * Convert Markdown documents to HTML
            % * Run MATLAB code in HTML documents and insert output
            % * Create info.xml and helptoc.xml from helptoc.md

            markdownFolder = task.MarkdownFolder.paths();
            markdownFiles = fullfile( markdownFolder, "**", "*.md" );
            html = docconvert( markdownFiles, ...
                "Theme", task.DocTheme, ...
                "Stylesheets", task.Stylesheets, ...
                "Scripts", task.Scripts, ...
                "Root", task.Root, ...
                "MathRenderer", task.MathRenderer );
            fprintf( 1, "** Converted Markdown doc to HTML\n" )

            docrun( html, ...
                "Level", task.Level, ...
                "Theme", task.FigureTheme, ...
                "FigureSize", task.FigureSize )
            fprintf( 1, "** Inserted MATLAB output into doc\n" )

            docindex( markdownFolder )
            fprintf( 1, "** Indexed doc\n" )

        end % buildDoc

    end % methods ( TaskAction )

end % classdef