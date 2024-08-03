classdef Workspace < handle & matlab.mixin.CustomDisplay
    %docer.Workspace  Private workspace
    %
    %   docer.Workspace is a private workspace for assigning variables and
    %   evaluating expressions.
    %
    %   w = docer.Workspace() creates a private workspace.

    %   Copyright 2007-2024 The MathWorks, Inc.

    properties ( Access = private )
        Data % workspace data
    end

    methods

        function obj = Workspace( varargin )
            %Workspace  Private workspace
            %
            %   w = docer.Workspace() creates an empty private workspace.
            %
            %   w = docer.Workspace(n1,v1,n2,v2,...) assigns the values v1,
            %   v2, ... to the variables n1, n2, ...

            % Create store
            if isMATLABReleaseOlderThan( "R2024a" )
                obj.Data = matlab.internal.lang.WorkspaceData;
            else
                obj.Data = matlab.lang.internal.WorkspaceData;
            end

            % Assign variables
            try
                obj.assignin( varargin{:} )
            catch e
                throwAsCaller( e )
            end

        end % constructor

    end % structors

    methods ( Access = protected )

        function displayScalarObject( obj )
            %displayScalarObject  Display scalar object
            %
            %   displayScalarObject(w) displays a scalar workspace, showing
            %   the class and number of variables.

            % Header -- class and number of variables
            c = matlab.mixin.CustomDisplay.getClassNameForHeader( obj );
            n = obj.Data.listVariables();
            switch numel( n )
                case 0
                    vs = "variables.";
                case 1
                    vs = "variable:";
                otherwise
                    vs = "variables:";
            end
            fprintf( 1, "  %s with %d %s\n\n", c, numel( n ), vs );

            % Body -- struct-style display of variables and values
            if numel( n ) > 0
                s = struct();
                for ii = 1:numel( n )
                    s.( n(ii) ) = obj.Data.getValue( n(ii) );
                end
                disp( s )
            end

        end % displayScalarObject

    end % display methods

    methods

        function varargout = evalin( obj, block )
            %evalin  Evaluate block in workspace
            %
            %   evalin(w,b) evaluates the block b in the workspace w.
            %
            %   [o1,o2,...] = evalin(w,b) returns the outputs from the
            %   evaluation, if the block contains a single statement.
            %
            %   See also: evalin

            arguments
                obj (1,1)
                block (1,1) string
            end

            % Evaluate
            try
                [varargout{1:nargout}] = obj.Data.evaluateIn( block );
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % evalin

        function varargout = evalinc( obj, block )
            %evalinc  Evaluate block in workspace and capture output
            %
            %   c = evalinc(w,b) evaluates the block b in the workspace w,
            %   and returns the command window output c.
            %
            %   [c,o1,o2,...] = evalinc(w,e) also returns the outputs from
            %   the evaluation, if the block contains a single statement.
            %
            %   See also: evalc

            arguments
                obj (1,1)
                block (1,1) string
            end

            % Evaluate
            try
                no = max( nargout, 1 ); % return at least 1 argument
                [varargout{1:no}] = evalc( obj, block ); %#ok<*EVLC>
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % evalinc

        function assignin( obj, name, value )
            %assignin  Assign variable in workspace
            %
            %   assignin(w,n,v) assigns the value v to the variable n in
            %   the workspace w.
            %
            %   assignin(w,n1,v1,n2,v2,...) assigns the values v1, v2, ...
            %   to the variables n1, n2, ... in the workspace w.
            %
            %   See also: assignin

            arguments
                obj (1,1)
            end

            arguments ( Repeating )
                name (1,1) string {mustBeValidVariableName}
                value
            end

            for ii = 1:numel( name ) % loop over assignments
                obj.Data.assignVariable( name{ii}, value{ii} )
            end

        end % assignin

        function clearvars( obj, args )
            %clearvars  Clear workspace variables
            %
            %   clearvars(w,v1,v2,...) clears the variables v1, v2, ...
            %   from the workspace w.
            %
            %   clearvars(w,"*") clears all variables.
            %
            %   clearvars(w,"x*") clears all variables beginning with x.
            %
            %   clearvars(w,"-except",v1,v2,...) clears all variables
            %   except v1, v2, ...
            %
            %   Other options of clearvars are also supported.
            %
            %   See also: clearvars

            arguments
                obj (1,1)
            end

            arguments ( Repeating )
                args (1,1) string
            end

            % Form expression
            expr = "clearvars" + sprintf( " %s", args{:} );

            % Evaluate
            try
                obj.Data.evaluateIn( expr )
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % clearvars

        function save( obj, args )
            %save  Save workspace variables to file
            %
            %   save(w,f) saves all variables in the workspace w to the
            %   file f.
            %
            %   save(w,f,v1,v2,...) saves only the variables v1, v2, ...
            %
            %   Other options of save are also supported.
            %
            %   See also: save

            arguments
                obj (1,1)
            end

            arguments ( Repeating )
                args (1,1) string
            end

            % Form expression
            expr = "save" + sprintf( " %s", args{:} );

            % Evaluate
            try
                obj.Data.evaluateIn( expr )
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % save

        function load( obj, args )
            %load  Load workspace variables from file
            %
            %   load(w,f) loads variables from the file f to the workspace
            %   w.
            %
            %   load(w,f,v1,v2,...) loads the variables v1, v2, ...
            %
            %   Other options of load are also supported.
            %
            %   See also: load

            arguments
                obj (1,1)
            end

            arguments ( Repeating )
                args (1,1) string
            end

            % Form expression
            expr = "load" + sprintf( " %s", args{:} );

            % Evaluate
            try
                obj.Data.evaluateIn( expr )
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % load

    end % methods

    methods ( Hidden )

        function keyboard( obj )
            %keyboard  Prompt in workspace
            %
            %   keyboard(w) provides a debug prompt in the workspace w.
            %
            %   To quit debugging and commit changes: dbcont
            %
            %   To quit debugging without committing: dbquit
            %
            %   See also: keyboard

            % Debug
            try
                [names, values] = keyboard_do( obj );
            catch e
                throwAsCaller( e ) % trim stack
            end

            % Repack
            obj.Data.clearVariables();
            for ii = 1:numel( names )
                obj.Data.assignVariable( names(ii), values{ii} )
            end

        end % keyboard

    end % public methods

    methods ( Access = private )

        function varargout = evalc( obj, block )
            %evalc  Evaluate multiple statements and capture output
            %
            %   c = evalc(w,b) evaluates the block b in the workspace w,
            %   and returns the command window output o.
            %
            %   [c,o1,o2,...] = evalc(...) also returns the outputs from
            %   the evaluation, if the block contains a single statement.
            %
            %   evalc splits the block b into statements, prepares the
            %   statements for evaluation with capture, and evaluates each
            %   statement in turn.

            arguments
                obj (1,1) % workspace
                block (1,1) string % text
            end

            % Split into statements
            tree = mtree( block ); % parse text
            if count( tree ) == 1 && iskind( tree, "ERR" )
                error( "docer:InvalidSyntax", ...
                    "Cannot parse text ""%s"".", block )
            end
            statements = tree2str( tree ); % convert back to statements
            statements = strsplit( statements, newline ); % split lines
            statements(strlength( statements ) == 0) = []; % remove empty lines
            statements = string( statements(:) ); % convert and reshape

            % Evaluate
            if isempty( statements ) % no statements
                assert( nargout == 1, "docer:InvalidSyntax", ...
                    "Cannot return output(s) from no statements." )
                varargout{1} = ""; % no output
            elseif isscalar( statements ) % single statement
                if nargout > 1 && any( iskind( tree, "EQUALS" ) )
                    error( "docer:InvalidArgument", ...
                        "Cannot return output(s) from an assignment." )
                end
                escStatement = strrep( statements, """", """""" );
                try
                    [varargout{1:nargout}] = evalc( ... % with capture
                        "obj.Data.evaluateIn(""" + escStatement + """)" );
                catch e
                    error( e.identifier, ...
                        "Error evaluating statement: %s\n%s", ...
                        statements, e.message ) % add statement to message
                end
                varargout{1} = string( varargout{1} ); % convert
            else % multiple statements
                assert( nargout == 1, "docer:InvalidSyntax", ...
                    "Cannot return output(s) from multiple statements." )
                varargout{1} = strings( size( statements ) ); % preallocate
                for ii = 1:numel( statements ) % loop over statements
                    varargout{1}(ii) = evalc( obj, statements(ii) ); % recurse
                end
                varargout{1} = strjoin( varargout{1}, "" ); % combine outputs
            end

        end % evalc

        function [db16a6c786, db2ccd973c] = keyboard_do( db16a6c786 )
            %keyboard  Prompt in workspace
            %
            %   keyboard(w) provides a debug prompt in the workspace w.
            %
            %   db16a6c786 and db2ccd973c are reserved variable names.
            %   Before debugging, these are used for the workspace and a
            %   loop index respectively.  After debugging, these are used
            %   to return the workspace names and values.

            % Unpack
            assert( ~any( ismember( db16a6c786.Data.listVariables(), ...
                ["db16a6c786", "db2ccd973c"] ) ), ...
                "docer:IllegalOperation", "%s", ...
                "Cannot debug workspace with reserved variable name(s)." )
            for db2ccd973c = db16a6c786.Data.listVariables()'
                eval( "db2ccd973c = db16a6c786.Store.getValue(db2ccd973c);" ) %#ok<EVLCS>
            end
            clear( "db16a6c786", "db2ccd973c" ) % temporary variables

            % Prompt
            fprintf( 1, "%s\n", "In debug mode.  To exit, type " + ...
                "dbcont to keep changes, and dbquit to discard changes." )
            keyboard() %#ok<KEYBOARDFUN>

            % Repack
            assert( ~exist( "db16a6c786", "var" ) && ~exist( "db2ccd973c", "var" ), ...
                "docer:IllegalOperation", "%s", ...
                "Cannot commit workspace with reserved variable name(s)." )
            db16a6c786 = string( who() ); % variable names
            db16a6c786 = db16a6c786(:);
            db2ccd973c = eval( "{" + strjoin( db16a6c786, " " ) + "}" );

        end % keyboard_do

    end % methods

end % classdef