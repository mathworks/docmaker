function plan = buildfile()
%buildfile  Doc'er buildfile

%   Copyright 2023-2024 The MathWorks, Inc.

import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask

% Create a plan from task functions
plan = buildplan( localfunctions() );

% Add a task to identify code issues
plan( "check" ) = CodeIssuesTask();

% Add a task to run tests
plan( "test" ) = TestTask();

% Set up task dependencies
plan( "package" ).Dependencies = ["check" "test" "doc"];

% Set default task
plan.DefaultTasks = "package";

end % buildfile

function docTask( ~ )
%docTask  Generate documentation

doc = fullfile( fileparts( mfilename( "fullpath" ) ), "tbx", "docerdoc" );
docerdelete( doc )
docerconvert( fullfile( doc, "**/*.md" ) )
docerindex( doc )

end % docTask

function packageTask( ~ )
%packageTask  Package toolbox

% Define name
n = "docer";

% Check environment
d = fileparts( mfilename( "fullpath" ) );
p = matlab.project.currentProject();
if isempty( p ) || p.RootFolder ~= d
    error( "Run the release script from within its project at %s.", d )
end

% Load and tweak metadata
s = jsondecode( fileread( fullfile( d, n + ".json" ) ) );
s.ToolboxMatlabPath = fullfile( d, s.ToolboxMatlabPath );
s.ToolboxFolder = fullfile( d, s.ToolboxFolder );
s.ToolboxImageFile = fullfile( d, s.ToolboxImageFile );
v = feval( @(s)s(1).Version, ver( n ) ); %#ok<FVAL>
s.ToolboxVersion = v;
s.OutputFile = fullfile( d, "releases", s.ToolboxName + " " + v + ".mltbx" );

% Create options object
f = s.ToolboxFolder; % mandatory
id = s.Identifier; % mandatory
s = rmfield( s, ["Identifier", "ToolboxFolder"] ); % mandatory
pv = [fieldnames( s ), struct2cell( s )]'; % optional
o = matlab.addons.toolbox.ToolboxOptions( f, id, pv{:} );
o.ToolboxVersion = string( o.ToolboxVersion ); % g3079185

% Package
matlab.addons.toolbox.packageToolbox( o )
fprintf( 1, "[+] %s\n", o.OutputFile );

% Add license
lic = fileread( fullfile( d, "LICENSE" ) );
mlAddonSetLicense( char( o.OutputFile ), struct( "type", 'MLL', "text", lic ) );

end % packageTask