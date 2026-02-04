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
        Hostname (1,1) string
    end

    properties ( SetAccess = immutable, Dependent )
        Token
    end

    properties ( Access = private )
        Token_ (1,1) string
    end

    methods

        function obj = GitHub( hostname, token )
            %GitHub  GitHub Markdown converter

            obj.Hostname = hostname;
            obj.Token_ = token;

        end % constructor

        function value = get.Token( obj )

            value = string( repmat( '*', [1 strlength( obj.Token_ )] ) ); % mask

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
            method = matlab.net.http.RequestMethod.POST;
            request = matlab.net.http.RequestMessage( method, [], md );
            request = addFields( request, "Content-Type", "text/plain" );
            request = addFields( request, "Authorization", "Bearer " + obj.Token_ );
            uri = matlab.net.URI( "https://" + obj.Hostname + "/markdown/raw" );
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
            xml = docmaker.Converter.closetag( xml, "img" );
            xml = docmaker.Converter.closetag( xml, "hr" );
            xml = docmaker.Converter.closetag( xml, "br" );

            % Wrap in div
            parser = matlab.io.xml.dom.Parser();
            doc = parser.parseString( "<div>" + xml + "</div>" );
            doc.XMLStandalone = true;

        end % md2xml

    end % methods

end % classdef