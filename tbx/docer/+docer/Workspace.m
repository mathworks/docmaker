classdef Workspace < handle
    %docer.Workspace  Private workspace
    %
    %   docer.Workspace is a private workspace for assigning variables and
    %   evaluating expressions.
    %
    %   w = docer.Workspace() creates a private workspace.

    %   Copyright 2007-2024 The MathWorks, Inc.

    properties ( SetAccess = private )
        Names (1,:) string % variable names
        Values (1,:) cell % variable values
    end

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
                [~, varargout{1:nargout}] = ... % do not return output
                    evalc_multi( obj, block, true ); % but do show
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % evalin

        function varargout = evalinc( obj, block )
            %evalinc  Evaluate block in workspace and capture output
            %
            %   c = evalinc(w,b) evaluates the block b in the
            %   workspace w, and returns the command window output c.
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
                [varargout{1:max( nargout, 1 )}] = ... % return output
                    evalc_multi( obj, block, false ); % but do not show
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
            %   See also: assignin

            arguments
                obj (1,1)
                name (1,1) string
                value
            end

            if ismember( name, obj.Names ) % existing
                obj.Values{obj.Names == name} = value;
            else % new
                obj.Names(end+1) = name;
                obj.Values{end+1} = value;
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
                eval_single( obj, expr )
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
                eval_single( obj, expr )
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
                eval_single( obj, expr )
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
                [obj.Names, obj.Values] = keyboard_do( obj );
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % keyboard

    end % public methods

    methods ( Access = private )

        function varargout = evalc_multi( obj, block, show )
            %evalc_multi  Evaluate multiple statements and capture output
            %
            %   c = evalc_multi(w,b) evaluates the block b in the
            %   workspace w, and returns the command window output o.
            %
            %   c = evalc_multi(w,b,true) also shows the command window
            %   output.
            %
            %   [c,o1,o2,...] = evalc_multi(...) also returns the outputs
            %   from the evaluation, if the block contains a single
            %   statement.
            %
            %   evalc_multi splits the block b into statements, prepares
            %   the statements for evaluation with capture, and forwards
            %   each statement in turn to eval_single.

            arguments
                obj (1,1) % workspace
                block (1,1) string % text
                show (1,1) matlab.lang.OnOffSwitchState = false % hide output
            end

            % Split into statements
            tree = mtree( block ); % parse text
            if count( tree ) == 1 && iskind( tree, "ERR" )
                error( "docer:InvalidArgument", ...
                    "Cannot parse text ""%s"".", block )
            end
            statements = tree2str( tree ); % convert back to statements
            statements = strsplit( statements, newline ); % split lines
            statements(strlength( statements ) == 0) = []; % remove empty lines
            statements = string( statements(:) ); % convert and reshape

            % Evaluate
            if isempty( statements ) % no statements
                assert( nargout == 1, "docer:InvalidArgument", ...
                    "Cannot return output(s) from no statements." )
                varargout{1} = ""; % no output
            elseif isscalar( statements ) % single statement
                escapedStatement = sprintf( "builtin(""evalc"",""%s"")", ...
                    strrep( statements, """", """""" ) ); % escape and wrap
                [varargout{1:nargout}] = ...
                    eval_single( obj, escapedStatement ); % evaluate
                varargout{1} = string( varargout{1} ); % convert
                if show, fprintf( 1, "%s", varargout{1} ); end % echo
            else % multiple statements
                assert( nargout == 1, "docer:InvalidArgument", ...
                    "Cannot return output(s) from multiple statements." )
                varargout{1} = strings( size( statements ) ); % preallocate
                for ii = 1:numel( statements ) % loop over statements
                    varargout{1}(ii) = evalc_multi( obj, statements(ii), show ); % recurse
                end
                varargout{1} = strjoin( varargout{1}, "" ); % combine outputs
            end

        end % evalc_multi

        function varargout = eval_single( obj, statement )
            %eval_single  Evaluate a single statement
            %
            %   eval_single(w,s) evaluates the statement s in the
            %   workspace w.
            %
            %   [o1,o2,...] = eval_single(...) returns outputs o1, o2, ...
            %   of the evaluation.
            %
            %   eval_single works in tandem with eval_do to evaluate the
            %   statement in a context containing only the workspace
            %   variables.

            [varargout{1:nargout}] = eval_do( obj, statement ); % do

        end % eval_single

        function varargout = eval_do( obj, statement )
            %eval_do  Evaluate a single statement in caller workspace
            %
            %   eval_do(w,s) evaluates unpacks the workspace w, evaluates
            %   the statement s, and repacks the workspace, all in scope of
            %   the caller function.
            %
            %   [o1,o2,...] = eval_do(...) returns outputs o1, o2, ... of
            %   the evaluation.
            %
            %   eval_do is part of the implementation of eval_single and
            %   should not be called directly.

            % Unpack
            builtin( "evalin", "caller", "clear" )
            oldNames = obj.Names;
            oldValues = obj.Values;
            for ii = 1:numel( oldNames )
                builtin( "assignin", "caller", oldNames(ii), oldValues{ii} )
            end

            % Evaluate
            [varargout{1:nargout}] = builtin( "evalin", "caller", statement );

            % Repack
            newNames = reshape( string( evalin( "caller", "who" ) ), 1, [] );
            newValues = cell( size( newNames ) ); % preallocate
            for ii = 1:numel( newNames )
                newValues{ii} = builtin( "evalin", "caller", newNames(ii) );
            end
            obj.Names = newNames;
            obj.Values = newValues;

        end % eval_do

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
            assert( ~any( ismember( db16a6c786.Names, ["db16a6c786", "db2ccd973c"] ) ), ...
                "docer:InvalidArgument", "%s", ...
                "Cannot debug workspace with reserved variable name(s)." )
            for db2ccd973c = 1:numel( db16a6c786.Names )
                eval( db16a6c786.Names(db2ccd973c) + ...
                    " = db16a6c786.Values{db2ccd973c};" )
            end
            clear( "db16a6c786", "db2ccd973c" ) % temporary variables

            % Prompt
            fprintf( 1, "%s\n", "In debug mode.  To exit, type " + ...
                "dbcont to keep changes, and dbquit to discard changes." )
            keyboard() %#ok<KEYBOARDFUN>

            % Repack
            assert( ~exist( "db16a6c786", "var" ) && ~exist( "db2ccd973c", "var" ), ...
                "docer:InvalidArgument", "%s", ...
                "Cannot commit workspace with reserved variable name(s)." )
            db16a6c786 = who(); % variable names
            db16a6c786 = reshape( string( db16a6c786 ), 1, [] );
            db2ccd973c = eval( "{" + strjoin( db16a6c786, " " ) + "}" );

        end % keyboard_do

    end % methods

end % classdef