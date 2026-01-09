function plan = buildfile()
%buildfile  DocMaker buildfile

%  Copyright 2023-2026 The MathWorks, Inc.

% Create a plan from task functions
plan = buildplan( localfunctions() );

% Add standard tasks
plan( "clean" ) = matlab.buildtool.tasks.CleanTask;

% Set up task inputs and dependencies
projectRoot = plan.RootFolder;
testFolder = fullfile( projectRoot, "tests" );
codeFolder = fullfile( projectRoot, "tbx" );
plan( "test" ) = matlab.buildtool.tasks.TestTask( testFolder, ...
    "Strict", true, ...
    "SourceFiles", codeFolder );
plan( "test" ).Dependencies = "check";
plan( "doc" ).Inputs = fullfile( projectRoot, "tbx", "docmakerdoc" );
plan( "package" ).Dependencies = ["test", "doc"];

% Set default task
plan.DefaultTasks = "package";

end % buildfile

function checkTask( c )
% Identify code and project issues

% Check code
t = matlab.buildtool.tasks.CodeIssuesTask( c.Plan.RootFolder, ...
    "Configuration", "factory", ...
    "IncludeSubfolders", true, ...
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
    error( "build:Project", "Project check(s) failed." )
else
    fprintf( 1, "** Project checks passed\n" )
end

end % checkTask

function docTask( c )
% Generate documentation

% Documentation folder
d = c.Task.Inputs.Path;

% Remove old documentation
docdelete( d )
fprintf( 1, "** Deleted old doc\n" )

% Convert Markdown to HTML
docconvert( fullfile( d, "**/*.md" ), "Theme", "light" )
fprintf( 1, "** Converted Markdown doc to HTML\n" )

% Temporarily override graphics defaults
g = groot();
st = get( g, "DefaultFigureWindowStyle" ); % capture default
po = get( g, "DefaultFigurePosition" ); % capture default
cl = onCleanup( @()set(g,"DefaultFigureWindowStyle",st,"DefaultFigurePosition",po) ); % reset defaults
set( g, "DefaultFigureWindowStyle", "normal", "DefaultFigurePosition", [100 100 400 300] ) % override defaults

% Run code and insert output
undo = setTemporaryTheme( "Light" ); %#ok<NASGU>
docrun( fullfile( d, "**/*.html" ) )
fprintf( 1, "** Inserted MATLAB output into doc\n" )

% Index documentation
docindex( d )
fprintf( 1, "** Indexed doc\n" )

end % docTask

function packageTask( c )
% Package toolbox

% Toolbox short name
n = "docmaker";

% Root folder
d = c.Plan.RootFolder;

% Load and tweak metadata
s = jsondecode( fileread( fullfile( d, n + ".json" ) ) );
s.ToolboxMatlabPath = fullfile( d, s.ToolboxMatlabPath );
s.ToolboxFolder = fullfile( d, s.ToolboxFolder );
s.ToolboxImageFile = fullfile( d, s.ToolboxImageFile );
v = feval( @(s)s(1), ver( n ) ); %#ok<FVAL>
s.ToolboxName = v.Name;
s.ToolboxVersion = v.Version;
s.OutputFile = fullfile( d, "releases", v.Name + " " + v.Version + ".mltbx" );

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

function undo = setTemporaryTheme( t )

s = settings();
if s.matlab.hasGroup( 'appearance' ) && s.matlab.appearance.hasSetting( 'MATLABTheme' )
    s.matlab.appearance.MATLABTheme.TemporaryValue = t;
    undo = onCleanup( @()clearTemporaryValue(s.matlab.appearance.MATLABTheme) );
else
    undo = [];
end

end % unsetTheme