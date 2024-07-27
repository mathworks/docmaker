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

        function varargout = evalin( obj, expr, cap )
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

        function varargout = evalc( obj, expr )
            %evalc  Evaluate expression in workspace and capture output

            % Wrap expression in evalc
            expr = "evalc(""" + strrep( expr, """", """""" ) + """)";

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

        end % evalc

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

    end % public methods

    methods ( Access = private )

        function varargout = evalin_clean( obj, expr )
            %evalin_clean  Middle level of the evalin chain
            %
            %   evalin_clean is the workspace scope in which expressions
            %   are evaluated.  evalin_clean bubbles down to evalin2, which
            %   then uses evalin("caller",...) to unpack, evaluate, repack,
            %   and bubble up outputs.

            [varargout{1:nargout}] = evalin_do( obj, expr ); % bubble down

        end % evalin1

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

        end % evalin2

    end % methods

end % classdef