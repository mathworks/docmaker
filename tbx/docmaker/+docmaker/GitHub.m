classdef GitHub < docmaker.Converter
    %docmaker.GitHub  GitHub Markdown converter
    %
    %   docmaker.GitHub is an adapter to GitHub to facilitate conversion
    %   from Markdown to XML.
    %
    %   g = docmaker.GitHub(h,t) creates a GitHub adapter with the hostname
    %   h and the access token t.

    %   Copyright 2024-2026 The MathWorks, Inc.

    properties ( SetAccess = immutable )
        Hostname
    end

    properties ( SetAccess = immutable, Dependent )
        Token
    end

    properties ( Access = private )
        Token_
    end

    methods

        function obj = GitHub( hostname, token )
            %GitHub  GitHub Markdown converter

            arguments
                hostname (1,1) string = "api.github.com"
                token (1,1) string = missing
            end

            obj.Hostname = hostname;
            obj.Token_ = token;

        end % constructor

        function value = get.Token( obj )

            value = obj.Token_;
            if ~ismissing( value )
                value = string( repmat( '*', size( char( value ) ) ) ); % mask
            end

        end % get.Token

        function doc = md2xml( obj, md )
            %md2xml  Convert Markdown to XML
            %
            %   x = md2xml(g,md) converts the Markdown md to the XML
            %   document x using the adapter g.
            %
            %   For more details of the GitHub Markdown API, see:
            %   https://docs.github.com/en/rest/markdown

            arguments
                obj (1,1) docmaker.GitHub
                md (1,1) string
            end

            % Submit request
            hostname = obj.Hostname;
            token = obj.Token_;
            method = matlab.net.http.RequestMethod.POST;
            request = matlab.net.http.RequestMessage( method, [], md );
            request = addFields( request, "Content-Type", "text/plain" );
            if ~ismissing( token )
                request = addFields( request, "Authorization", "Bearer " + token );
            end
            uri = matlab.net.URI( "https://" + hostname + "/markdown/raw" );
            response = request.send( uri );

            % Handle response
            switch response.StatusCode
                case matlab.net.http.StatusCode.OK
                    xml = response.Body.Data;
                    xml = strtrim( xml );
                otherwise
                    throw( MException( "docmaker:UnhandledError", "[%s] %s", ...
                        string( response.StatusLine ), response.Body.Data.message ) )
            end

            % Close self-closing to ensure valid XML
            xml = docmaker.closetag( xml, "img" );
            xml = docmaker.closetag( xml, "hr" );
            xml = docmaker.closetag( xml, "br" );

            % Wrap in div
            parser = matlab.io.xml.dom.Parser();
            doc = parser.parseString( "<div>" + xml + "</div>" );
            doc.XMLStandalone = true;

        end % md2xml

    end % methods

end % classdef