function plan = buildfile()
%buildfile  DocMaker buildfile

%  Copyright 2023-2026 The MathWorks, Inc.

% Create a plan from task functions
plan = buildplan( localfunctions() );

% Folders of interest
prj = plan.RootFolder;
tbx = fullfile( prj, "tbx" );
api = fullfile( tbx, tbxname() );
doc = fullfile( tbx, tbxname() + "doc" );
test = fullfile( prj, "tests" );

% Clean task
plan( "clean" ) = matlab.buildtool.tasks.CleanTask;

% Check task
plan( "check" ).Inputs = api;

% Test task
plan( "test" ) = matlab.buildtool.tasks.TestTask( test, ...
    "SourceFiles", tbx, "Strict", true );
plan( "test" ).Inputs = [api test];
plan( "test" ).Dependencies = "check";

% Documentation task
plan( "doc" ).Inputs = doc;
plan( "doc" ).Outputs = [ ...
    fullfile( doc, "**", "*.html" ), fullfile( doc, "*.xml" ), ...
    fullfile( doc, "resources" ), fullfile( doc, "helpsearch-v*" )];

% Package task
plan( "package" ).Inputs = tbx;
plan( "package" ).Dependencies = ["test", "doc"];

% Default task
plan.DefaultTasks = "package";

end % buildfile

function n = tbxname()
%tbxname  Toolbox name

n = "docmaker";

end % tbxname

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
    error( "build:check", "Project check(s) failed." )
else
    fprintf( 1, "** Project checks passed\n" )
end

end % checkTask

function docTask( c )
% Generate documentation

% Documentation folder
doc = c.Task.Inputs.Path;

% Convert Markdown to HTML
md = fullfile( doc, "**", "*.md" );
html = docconvert( md, "Theme", "light" );
fprintf( 1, "** Converted Markdown doc to HTML\n" )

% Run code and insert output
docrun( html, "Theme", "light", "FigureSize", [600 400] )
fprintf( 1, "** Inserted MATLAB output into doc\n" )

% Index documentation
docindex( doc )
fprintf( 1, "** Indexed doc\n" )

end % docTask

function packageTask( ~ )
% Package toolbox

% Load and tweak metadata
s = jsondecode( fileread( tbxname() + ".json" ) );
v = ver( tbxname() ); % from Contents.m
assert( isscalar( v ), "build:package", ...
    "Found %d instances of %s on the MATLAB path.", numel( v ), tbxname() )
s.ToolboxName = v.Name;
s.ToolboxVersion = v.Version;

if getenv( "GITHUB_ACTIONS" ) == "true"
    % Check version and tag compatibility for release
    ref = string( getenv( "GITHUB_REF" ) );
    gitTagNumber = extractAfter( ref, "refs/tags/v" );
    assert( v.Version == gitTagNumber, ...
        "build:package:VersionTagMismatch", ...
        "%s Toolbox version %s (from Contents.m) does not " + ...
        "match the current Git tag number (%s).", ...
        v.Name, v.Version, gitTagNumber )
    % Define stable name for GitHub
    stableName = replace( v.Name, " ", "_" ) + ".mltbx";
    s.OutputFile = fullfile( "releases", stableName );
else
    % Include version in toolbox file name
    s.OutputFile = fullfile( ...
        "releases", v.Name + " " + v.Version + ".mltbx" );
end % if

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
lic = fileread( "LICENSE" );
mlAddonSetLicense( char( o.OutputFile ), struct( "type", 'BSD', "text", lic ) );

end % packageTask