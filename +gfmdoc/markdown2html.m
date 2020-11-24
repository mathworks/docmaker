function html = markdown2html( md )
%markdown2html  Create GitLab issue discussion note
%
%  html = markdown2html(md)

% Handle inputs
narginchk( 1, 1 )

% Request
data = struct( "text", md, "gfm", true );
[status, body] = request( "POST", "/markdown", data );

% Return
switch status
    case matlab.net.http.StatusCode.Created
        html = body.html;
    otherwise
        throwAsCaller( exception( "create", body ) )
end

end % markdown2html

function [status, body] = request( method, endpoint, varargin )
%request  Send GitLab request and return response
%
%  [status,body] = gitlab.request(method,endpoint)
%  [status,body] = gitlab.request(method,endpoint,data)
%
%  This helper function uses the hostname and access token preferences to
%  construct and issue a request and return the response.  The optional
%  request data should be a struct.

% Retrieve preferences
[hostname, token] = gitlab.setup();

% Create RequestMessage
method = matlab.net.http.RequestMethod.( method );
switch method
    case matlab.net.http.RequestMethod.GET
        header = matlab.net.http.HeaderField( ...
            "PRIVATE-TOKEN", token );
    otherwise
        header = matlab.net.http.HeaderField( ...
            "Content-Type", "application/json", "PRIVATE-TOKEN", token );
end
request = matlab.net.http.RequestMessage( method, header, varargin{:} );

% Send request
uri = matlab.net.URI( "https://" + hostname + "/api/v4" + endpoint );
responses = []; % initialize
while true
    response = request.send( uri );
    responses = [responses response]; %#ok<AGROW>
    [tf, uri] = isfinal( response ); % more?
    if tf == true, break, end % break if done
end

% Return
status = responses(end).StatusCode;
data = arrayfun( @(r)r.Body.Data, responses, 'UniformOutput', false ); % extract
body = vertcat( data{:} ); % combine

end % request

function [tf, uri] = isfinal( response )
%isfinal  Test whether response is final
%
%  [tf,uri] = isfinal(response) tests whether the specified response is
%  final by inspecting the headers for links.  If not then the URI of the
%  next part of the response is returned.

header = getFields( response, "Link" ); % get links from header
if isempty( header ) % no links
    tf = true;
    uri = [];
else % links, look for "next"
    links = textscan( header.Value, "%s" ); % parse into labels and URLs
    links = string( flipud( reshape( links{:}, 2, [] ) ) ); % reshape
    links(1,:) = extractBetween( links(1,:), """", """" ); % labels
    links(2,:) = extractBetween( links(2,:), "<", ">;" ); % URLs
    links = cellstr( links );
    links = struct( links{:} );
    if isfield( links, "next" )
        tf = false;
        uri = matlab.net.URI( links.next );
    else
        tf = true;
        uri = [];
    end
end

end % isfinal

function e = exception( identifier, body )
%exception  Create exception from identifier and response body
%
%  e = exception(identifier,body)

if isfield( body, "error" )
    message = body.error;
elseif isfield( body, "message" )
    message = body.message;
else
    message = "Unknown error.";
end
e = MException( "gitlab:" + identifier, message );

end % exception