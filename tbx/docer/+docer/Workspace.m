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
            try
                [varargout{1:nargout}] = evalin_clean( obj, expr );
            catch e
                throwAsCaller( e )
            end

        end % evalin

        function varargout = evalinc( obj, expr )
            %evalinc  Evaluate expression in workspace and capture output

            % Wrap expression in evalc
            expr = sprintf( "builtin(""evalc"",""%s"")", ...
                strrep( expr, """", """""" ) );

            % Evaluate
            try
                [varargout{1:nargout}] = evalin_clean( obj, expr );
            catch e
                throwAsCaller( e )
            end

            % Return
            if nargout > 0
                varargout{1} = string( varargout{1} );
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
                throwAsCaller( e )
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
                throwAsCaller( e )
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
                throwAsCaller( e )
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
                throwAsCaller( e )
            end

        end % load

    end % static methods

    methods ( Access = private )

        function varargout = evalin_clean( obj, expr )
            %evalin_clean  Middle level of the evalin chain
            %
            %   evalin_clean is the workspace scope in which expressions
            %   are evaluated.  evalin_clean bubbles down to evalin2, which
            %   then uses evalin("caller",...) to unpack, evaluate, repack,
            %   and bubble up outputs.

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