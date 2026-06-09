classdef DocMakerTask < matlab.buildtool.Task
    %DOCMAKERTASK Generate toolbox documentation using DocMaker.
    %
    % See also docconvert, docrun, docindex

    properties
        % Documentation theme.
        Theme(1, 1) string {mustBeMember( Theme, ...
            ["light", "dark", "auto"] )} = "auto"
        % Stylesheets to include.
        Stylesheets(1, :) string {mustBeFile}
        % Scripts to include.
        Scripts(1, :) string {mustBeFile}
        % Root folder for publishing.
        Root(1, :) string {mustBeFolder, mustBeScalarOrEmpty}
        % LaTeX interpreter.
        Interpreter(1, 1) string {mustBeMember( Interpreter, ...
            ["latex", "none"] )} = "none"        
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
        % Documentation files in Markdown format.
        MarkdownFiles(1, :) cell
    end % properties ( TaskInput )

    methods

        function task = DocMakerTask( markdownFiles, namedArgs )
            %DOCMAKERTASK Construct the DocMaker build task.

            arguments ( Input, Repeating )
                markdownFiles
            end % arguments ( Input, Repeating )

            arguments ( Input )
                namedArgs.?DocMakerTask
            end % arguments ( Input )

            % Assign the markdown files.
            task.MarkdownFiles = markdownFiles;

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

            % Prepare docconvert argument list.
            convertArgs = {};
            if ~isempty( task.Stylesheets )
                convertArgs = {"Stylesheets", task.Stylesheets};
            end % if
            
            if ~isempty( task.Scripts )
                convertArgs = [convertArgs, {"Scripts", task.Scripts}];
            end % if

            if ~isempty( task.Root )
                convertArgs = [convertArgs, {"Root", task.Root}];
            end % if

            % Convert Markdown to HTML.
            html = docconvert( task.MarkdownFiles{:}, ...
                "Theme", task.Theme, ...
                "Interpreter", task.Interpreter, ...
                convertArgs{:} );
            fprintf( 1, "** Converted Markdown doc to HTML\n" )

            % Execute MATLAB code and insert output into the HTML.
            docrun( html, ...
                "Level", task.Level, ...
                "Theme", task.FigureTheme, ...
                "FigureSize", task.FigureSize )
            fprintf( 1, "** Inserted MATLAB output into doc\n" )

            % Build the documentation search index.
            if ~isempty( task.Root )            
                docindex( task.Root )
            else
                sMd = docmaker.dir( task.MarkdownFiles{:} );
                pMd = reshape( {sMd.folder}, size( sMd ) );
                pRoot = docmaker.superfolder( pMd{:} );
                docindex( pRoot )
            end % if
            fprintf( 1, "** Indexed doc\n" )

        end % buildDoc

    end % methods ( TaskAction )

end % classdef