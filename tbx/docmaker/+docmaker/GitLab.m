classdef GitLab < docmaker.Converter
    %docmaker.GitLab  GitLab Markdown converter
    %
    %   docmaker.GitLab is an adapter to GitLab to facilitate conversion
    %   from Markdown to XML.
    %
    %   g = docmaker.GitLab(h,t) creates a GitLab adapter with the hostname
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

        function obj = GitLab( hostname, token )
            %GitLab  GitLab Markdown converter

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
            %   For more details of the GitLab Markdown API, see:
            %   https://docs.gitlab.com/api/markdown/

            arguments
                obj (1,1) docmaker.GitLab
                md (1,1) string
            end

            % Submit request
            method = matlab.net.http.RequestMethod.POST;
            body = struct( "text", md, "gfm", true );
            request = matlab.net.http.RequestMessage( method, [], body );
            request = addFields( request, "Content-Type", "application/json" );
            request = addFields( request, "PRIVATE-TOKEN", obj.Token_ );
            uri = matlab.net.URI( "https://" + obj.Hostname + "/api/v4/markdown" );
            response = request.send( uri );

            % Handle response
            switch response.StatusCode
                case matlab.net.http.StatusCode.Created
                    xml = response.Body.Data.html;
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

            % Remove anchors
            anchors = docmaker.list2array( doc.getElementsByTagName( "a" ) );
            for ii = 1:numel( anchors )
                anchor = anchors(ii);
                if anchor.hasChildNodes == false
                    anchor.getParentNode().removeChild( anchor );
                end
            end

            % Fix MATLAB code blocks
            pres = docmaker.list2array( doc.getElementsByTagName( "pre" ) );
            for ii = 1:numel( pres )
                pre = pres(ii);
                if docmaker.hasclass( pre, "highlight" ) && ...
                        docmaker.hasclass( pre, "language-matlab" )
                    div = getCodeBlock( pre );
                    if ~isequal( div, [] )
                        docmaker.addclass( div, "highlight" )
                        docmaker.addclass( div, "highlight-source-matlab" )
                    end
                end
            end

        end % md2xml

        function ok = ping( obj )
            %ping  Ping GitLab
            %
            %   ok = ping(g) pings the GitLab g and returns true if OK and
            %   false otherwise.

            % Submit request
            method = matlab.net.http.RequestMethod.GET;
            request = matlab.net.http.RequestMessage( method, [], [] );
            request = addFields( request, "PRIVATE-TOKEN", obj.Token_ );
            uri = matlab.net.URI( "https://" + obj.Hostname + "/api/v4/user" );
            response = request.send( uri );

            % Handle response
            ok = response.StatusCode == matlab.net.http.StatusCode.OK && ...
                isstruct( response.Body.Data );

        end % ping

    end % methods

end % classdef

function div = getCodeBlock( element )
%getCodeBlock  Get code block of element
%
%   d = getCodeBlock(e) gets the code block of the element e, that is, the
%   closest div ancestor with class "markdown-code-block".

if ~isa( element, "matlab.io.xml.dom.Element" )
    div = []; % give up
elseif element.TagName == "div" && ...
        docmaker.hasclass( element, "markdown-code-block" )
    div = element; % found it
else
    div = getCodeBlock( element.getParentNode() ); % keep looking
end

end % getCodeBlock