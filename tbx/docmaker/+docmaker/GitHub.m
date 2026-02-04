classdef GitHub < docmaker.Converter

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

            obj.Hostname = hostname;
            obj.Token_ = token;

        end

        function value = get.Token( obj )

            value = string( repmat( '*', [1 strlength( obj.Token_ )] ) );

        end

        function doc = md2xml( obj, md )
            %md2xml  Convert Markdown to XML
            %
            %   x = docmaker.md2xml(md) converts the Markdown md to the XML document x
            %   using the GitHub API at: https://docs.github.com/en/rest/markdown
            %
            %   Authenticated requests get a higher API rate limit.  To authenticate,
            %   set the secret or preference using:
            %   * setSecret("DocMaker GitHub token"), or
            %   * setpref("docmaker","token",t)

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