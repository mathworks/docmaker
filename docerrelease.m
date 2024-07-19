function varargout = docerrelease()
%docerrelease  Release Doc'er as a toolbox
%
%  docerrelease() packages Doc'er as a toolbox using the metadata in
%  docer.json.
%
%  o = docerrelease() returns the ToolboxOptions used to package the
%  toolbox.

%   Copyright 2023-2024 The MathWorks, Inc.

% Check environment
d = fileparts( mfilename( "fullpath" ) );
p = matlab.project.currentProject();
if isempty( p ) || p.RootFolder ~= d
    error( "Run the release script from within its project at %s.", d )
end

% Load and tweak metadata
s = jsondecode( fileread( fullfile( d, "docer.json" ) ) );
s.ToolboxMatlabPath = fullfile( d, s.ToolboxMatlabPath );
s.ToolboxFolder = fullfile( d, s.ToolboxFolder );
s.ToolboxImageFile = fullfile( d, s.ToolboxImageFile );
n = extractBefore( mfilename(), "release" );
v = feval( @(s)s(1).Version, ver( n ) ); %#ok<FVAL>
s.ToolboxVersion = v;
s.OutputFile = fullfile( d, "releases", "docer.mltbx" );

% Create options object
f = s.ToolboxFolder; % mandatory
id = s.Identifier; % mandatory
s = rmfield( s, ["Identifier", "ToolboxFolder"] ); % mandatory
pv = [fieldnames( s ), struct2cell( s )]'; % optional
o = matlab.addons.toolbox.ToolboxOptions( f, id, pv{:} );
o.ToolboxVersion = string( o.ToolboxVersion ); % g3079185

% Package   
fprintf( 1, "Packaging ""%s"" version %s to ""%s""... ", ...
    o.ToolboxName, o.ToolboxVersion, o.OutputFile );
try
    matlab.addons.toolbox.packageToolbox( o )
    fprintf( 1, "OK.\n" )
catch e
    fprintf( 1, "failed.\n" )
    rethrow( e )
end

% Add license
lic = fileread( fullfile( d, "LICENSE" ) );
mlAddonSetLicense( char( o.OutputFile ), struct( "type", 'MLL', "text", lic ) );

% Return
if nargout == 1, varargout = {o}; end

end % docerrelease