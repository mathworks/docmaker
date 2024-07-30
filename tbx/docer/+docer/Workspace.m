classdef Workspace < handle
    %docer.Workspace  Private workspace
    %
    %   docer.Workspace is a private workspace for assigning variables and
    %   evaluating expressions.
    %
    %   w = docer.Workspace() creates a private workspace.

    %   Copyright 2007-2024 The MathWorks, Inc.

    properties ( SetAccess = private )
        Names = strings( 1, 0 ); % variable names
        Values = cell( 1, 0 ); % variable values
    end

    methods

        function varargout = evalin( obj, expr )
            %evalin  Evaluate expression in workspace
            %
            %   evalin(w,e) evaluates the expression e in the workspace w.
            %
            %   [o1,o2,...] = evalin(w,e) returns the outputs from the
            %   evaluation.

            arguments
                obj (1,1)
                expr (1,1) string
            end

            % Evaluate
            try % show but do not return output
                [~, varargout{1:nargout}] = ... % do not return output
                    evalin_gateway( obj, expr, false ); % but do show
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % evalin

        function varargout = evalinc( obj, t )
            %evalinc  Evaluate expression in workspace and capture output
            %
            %   s = evalinc(w,e) evaluates the expression e in the
            %   workspace w and returns the console output s.
            %
            %   [s,o1,o2,...] = evalinc(w,e) also returns the outputs from
            %   the evaluation.

            arguments
                obj (1,1)
                t (1,1) string
            end

            try % hide but return output
                [varargout{1:max( nargout, 1 )}] = ... % return output
                    evalin_gateway( obj, t, true ); % but do not show
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % evalinc

        function assignin( obj, name, value )
            %assignin  Assign variable in workspace
            %
            %   assignin(w,n,v) assigns the value v to the variable n in
            %   the workspace w.

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

        function clearvars( obj, varargin )

            % Check inputs
            try
                varargin = string( varargin );
            catch
                e = MException( "docer:InvalidArgument", ...
                    "Variable names must be strings." );
                throwAsCaller( e )
            end

            % Form expression
            expr = "clearvars" + sprintf( " %s", varargin{:} );

            % Evaluate
            try
                evalin_clean( obj, expr )
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % clearvars

        function save( obj, varargin )
            %save  Save workspace variables to file
            %
            %   save(w,f) saves all variables in the workspace w to the
            %   file f.

            % Check inputs
            try
                varargin = string( varargin );
            catch
                e = MException( "docer:InvalidArgument", ...
                    "Variable names must be strings." );
                throwAsCaller( e )
            end

            % Form expression
            expr = "save" + sprintf( " %s", varargin{:} );

            % Evaluate
            try
                evalin_clean( obj, expr )
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % save

    end

    methods ( Hidden )

        function keyboard( obj )
            %keyboard  Prompt in workspace
            %
            %   keyboard(w) provides a debug prompt in the workspace w.
            %
            %   To quit debugging and commit changes: dbcont
            %
            %   To quit debugging without committing: dbquit

            % Debug
            try
                [obj.Names, obj.Values] = keyboard_do( obj );
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % keyboard

    end % public methods

    methods ( Static )

        function obj = load( varargin )

            % Check inputs
            try
                varargin = string( varargin );
            catch
                e = MException( "docer:InvalidArgument", ...
                    "Variable names must be strings." );
                throwAsCaller( e )
            end

            % Form expression
            expr = "load" + sprintf( " %s", varargin{:} );

            % Create
            obj = docer.Workspace();

            % Evaluate
            try
                evalin_clean( obj, expr )
            catch e
                throwAsCaller( e ) % trim stack
            end

        end % load

    end % static methods

    methods ( Access = private )

        function varargout = evalin_gateway( obj, t, h )
            %evalin_gateway  Evaluate expression in workspace
            %
            %   evalin_gateway provides the core implementation for evalin
            %   and evalinc.
            %
            %   o = evalin_gateway(w,t,c) evaluates the text t in the
            %   workspace and returns the command window output o.  The
            %   flag h controls whether the command window output is hidden
            %   (true) or shown (false).
            %
            %   [o,x,y,...] = evalin_gateway(w,t,c) also returns the
            %   outputs x, y, ... from the evaluation.

            arguments
                obj (1,1) % workspace
                t (1,1) string % text
                h (1,1) matlab.lang.OnOffSwitchState % hide output
            end

            % Split into statements
            tr = mtree( t ); % parse text
            if count( tr ) == 1 && iskind( tr, "ERR" )
                error( "docer:InvalidArgument", ...
                    "Cannot parse text ""%s"".", t )
            end
            s = tree2str( tr ); % convert back to statements
            s = strsplit( s, newline ); % split lines
            s(strlength( s ) == 0) = []; % remove empty lines
            s = string( s(:) ); % convert and reshape

            % Evaluate
            if isempty( s ) % no statements
                assert( nargout == 1, "docer:InvalidArgument", ...
                    "Cannot return output(s) from no statements." )
                varargout{1} = ""; % return empty string
            elseif isscalar( s ) % single statement
                es = sprintf( "builtin(""evalc"",""%s"")", ...
                    strrep( s, """", """""" ) ); % escape and wrap
                [varargout{1:nargout}] = evalin_clean( obj, es ); % evaluate
                varargout{1} = string( varargout{1} ); % return string
                if h == false % do not hide
                    fprintf( 1, "%s", varargout{1} ); % echo
                end
            else % multiple statements
                assert( nargout == 1, "docer:InvalidArgument", ...
                    "Cannot return output(s) from multiple statements." )
                varargout{1} = strings( size( s ) ); % preallocate
                for ii = 1:numel( s ) % loop over statements
                    varargout{1}(ii) = evalin_gateway( obj, s(ii), h );
                end
                varargout{1} = strjoin( varargout{1}, "" ); % combine
            end

        end % evalinc_gateway

        function varargout = evalin_clean( obj, expr )
            %evalin_clean  Middle level of the evalin chain
            %
            %   evalin_clean is the workspace scope in which expressions
            %   are evaluated.  evalin_clean bubbles down to evalin_do,
            %   which then uses evalin("caller",...) to unpack, evaluate,
            %   repack, and bubble up outputs.

            [varargout{1:nargout}] = evalin_do( obj, expr ); % bubble down

        end % evalin_clean

        function varargout = evalin_do( obj, expr )
            %evalin_do  Bottom level of the evalin chain
            %
            %   evalin_do uses assignin("caller",...) and
            %   evalin("caller",...) to unpack, evaluate, and repack.

            % Unpack
            builtin( "evalin", "caller", "clear" )
            oldNames = obj.Names;
            oldValues = obj.Values;
            for ii = 1:numel( oldNames )
                builtin( "assignin", "caller", oldNames(ii), oldValues{ii} )
            end

            % Evaluate
            [varargout{1:nargout}] = builtin( "evalin", "caller", expr ); % bubbles up

            % Repack
            newNames = reshape( string( evalin( "caller", "who" ) ), 1, [] );
            newValues = cell( size( newNames ) ); % preallocate
            for ii = 1:numel( newNames )
                newValues{ii} = builtin( "evalin", "caller", newNames(ii) );
            end
            obj.Names = newNames;
            obj.Values = newValues;

        end % evalin_do

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
            keyboard() %#ok<KEYBOARDFUN>

            % Repack
            assert( ~exist( "db16a6c786", "var" ) && ~exist( "db2ccd973c", "var" ), ...
                "docer:InvalidArgument", "%s", ...
                "Cannot commit workspace with reserved variable name(s)." )
            db16a6c786 = reshape( who(), 1, [] );
            db2ccd973c = eval( "{" + strjoin( db16a6c786, " " ) + "}" );

        end % keyboard_do

    end % methods

end % classdef