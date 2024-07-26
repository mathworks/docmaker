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

            try
                [varargout{1:nargout}] = evalin1( obj, expr );
            catch e
                throwAsCaller( e )
            end

        end % evalin

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
                obj.Names{end+1} = name;
                obj.Values{end+1} = value;
            end

        end % assignin

    end % public methods

    methods ( Access = private )

        function varargout = evalin1( obj, expr )
            %evalin1  Middle level of the evalin chain
            %
            %   evalin1 is the workspace scope in which expressions are
            %   evaluated.  evalin1 bubbles down to evalin2, which then
            %   uses evalin("caller",...) to unpack, evaluate, repack, and
            %   bubble up outputs.

            [varargout{1:nargout}] = evalin2( obj, expr ); % bubble down

        end % evalin1

        function varargout = evalin2( obj, expr )
            %evalin2  Bottom level of the evalin chain
            %
            %   evalin2 uses assignin("caller",...) and
            %   evalin("caller",...) to unpack, evaluate, and repack.

            % Unpack
            evalin( "caller", "clear" )
            oldNames = obj.Names;
            oldValues = obj.Values;
            for ii = 1:numel( oldNames )
                assignin( "caller", oldNames(ii), oldValues{ii} )
            end

            % Evaluate
            [varargout{1:nargout}] = evalin( "caller", expr ); % bubbles up

            % Repack
            newNames = string( evalin( "caller", "who" ) );
            newValues = cell( size( newNames ) ); % preallocate
            for ii = 1:numel( newNames )
                newValues{ii} = evalin( "caller", newNames(ii) );
            end
            obj.Names = newNames;
            obj.Values = newValues;

        end % evalin2

    end % methods

end % classdef