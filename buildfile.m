function plan = buildfile()
%buildfile  Doc_er buildfile

%  Copyright 2023-2024 The MathWorks, Inc.

import matlab.buildtool.tasks.*

% Create a plan from task functions
plan = buildplan( localfunctions() );

% Add standard tasks
plan( "clean" ) = CleanTask;

% Set up task inputs and dependencies
plan( "doc" ).Inputs = fullfile( plan.RootFolder, "tbx", "docerdoc" );
plan( "doc" ).Dependencies = "check";
plan( "package" ).Dependencies = "doc";

% Set default task
plan.DefaultTasks = "package";

end % buildfile

function checkTask( c )
% Identify code and project issues

% Check code
t = matlab.buildtool.tasks.CodeIssuesTask( c.Plan.RootFolder, ...
    "WarningThreshold", 0 );
t.analyze( c )
fprintf( 1, "** Code checks passed\n" )

% Check project
p = currentProject();
p.updateDependencies()
t = table( p.runChecks() );
ok = t.Passed;
if any( ~ok )
    disp( t(~ok,:) )
    error( "buildfile:Project", "Project check(s) failed." )
else
    fprintf( 1, "** Project checks passed\n" )
end

end % checkTask

function docTask( c )
% Generate documentation

% Documentation folder
d = c.Task.Inputs.Path;

% Remove old documentation
docerdelete( d )
fprintf( 1, "** Deleted old doc\n" )

% Convert Markdown to HTML
docerconvert( fullfile( d, "**/*.md" ) )
fprintf( 1, "** Converted Markdown doc to HTML\n" )

% Temporarily override graphics defaults
g = groot();
st = get( g, "DefaultFigureWindowStyle" ); % capture default
po = get( g, "DefaultFigurePosition" ); % capture default
cl = onCleanup( @()set(g,"DefaultFigureWindowStyle",st,"DefaultFigurePosition",po) ); % reset defaults
set( g, "DefaultFigureWindowStyle", "normal", "DefaultFigurePosition", [100 100 400 300] ) % override defaults

% Run code and insert output
docerrun( fullfile( d, "**/*.html" ) )
fprintf( 1, "** Inserted MATLAB output into doc\n" )

% Index documentation
docerindex( d )
fprintf( 1, "** Indexed doc\n" )

end % docTask

function packageTask( c )
% Package toolbox

% Toolbox short name
n = "docer";

% Root folder
d = c.Plan.RootFolder;

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
mlAddonSetLicense( char( o.OutputFile ), struct( "type", 'BSD', "text", lic ) );

end % packageTask