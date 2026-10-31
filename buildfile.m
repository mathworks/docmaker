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

% cmark-gfm MEX build inputs and outputs
sourceDir = fullfile( prj, "src" );
vendorDir = fullfile( prj, "vendor" );
cmarkDir = fullfile( vendorDir, "cmark-gfm" );
gemojiDir = fullfile( vendorDir, "gemoji" );
generatedDir = fullfile( prj, "build", "cmark-gfm" );
mexDir = fullfile( api, "+docmaker" );
mexFile = fullfile( mexDir, "cmarkgfm2html." + mexext() );
generatedFiles = [ ...
    fullfile( generatedDir, "cmark-gfm_version.h" )
    fullfile( generatedDir, "emoji_map.c" ) ];

mexInputs = cmarkSourceFiles( cmarkDir, sourceDir, generatedDir );
mexInputs(mexInputs == fullfile( generatedDir, "emoji_map.c" )) = [];
mexInputs = [ ...
    mexInputs
    folderFiles( fullfile( cmarkDir, "src" ), "*.h" )
    folderFiles( fullfile( cmarkDir, "extensions" ), "*.h" )
    folderFiles( sourceDir, "*.h" )
    fullfile( prj, "buildfile.m" )
    fullfile( cmarkDir, "CMakeLists.txt" )
    fullfile( cmarkDir, "src", "cmark-gfm_version.h.in" )
    fullfile( gemojiDir, "db", "emoji.json" )
    fullfile( sourceDir, "emoji_map.c.in" ) ];
mexInputs = mexInputs(isfile(mexInputs));

% Clean task
plan("clean") = matlab.buildtool.tasks.CleanTask;

% Check task
plan("check").Inputs = api;

% MEX task: generate its sources, then compile for this MATLAB platform
plan("mex").Description = ...
    "Generate and build the cmark-gfm MEX";
plan("mex").Inputs = mexInputs;
plan("mex").Outputs = [generatedFiles; mexFile];

% Test task
plan("test") = matlab.buildtool.tasks.TestTask( test, ...
    "SourceFiles", tbx, "Strict", true );
plan("test").Inputs = [api test];
plan("test").Dependencies = ["check", "mex"];

% Documentation task
plan("doc") = DocMakerTask( fullfile( doc, "**", "*.md" ), ...
    "Theme", "light", ...
    "FigureSize", [600, 400], ...
    "FigureTheme", "light" );
plan("doc").Dependencies = "mex";

% Package task
plan("package").Inputs = tbx;
plan("package").Dependencies = ["test", "doc"];

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

function mexTask( ~ )
% Build cmark-gfm and its generated emoji lookup table

root = fileparts( mfilename( "fullpath" ) );
sourceDir = fullfile( root, "src" );
vendorDir = fullfile( root, "vendor" );
cmarkDir = fullfile( vendorDir, "cmark-gfm" );
generatedDir = fullfile( root, "build", "cmark-gfm" );
mexDir = fullfile( root, "tbx", "docmaker", "+docmaker" );

generateSources( root );

sourceFiles = cmarkSourceFiles( cmarkDir, sourceDir, generatedDir );
options = [ ...
    "-R2018a"
    "-I" + sourceDir
    "-I" + generatedDir
    "-I" + fullfile( cmarkDir, "src" )
    "-I" + fullfile( cmarkDir, "extensions" ) ];

mexArgs = [ ...
    cellstr(options)
    cellstr(sourceFiles)
    { "-outdir"; char(mexDir); "-output"; "cmarkgfm2html" } ];
mex( mexArgs{:} );

end % mexTask

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

function files = cmarkSourceFiles( cmarkDir, sourceDir, generatedDir )

srcNames = [ ...
    "cmark.c"; "node.c"; "iterator.c"; "blocks.c"; "inlines.c"; ...
    "scanners.c"; "utf8.c"; "buffer.c"; "references.c"; "footnotes.c"; ...
    "map.c"; "render.c"; "man.c"; "xml.c"; "html.c"; "commonmark.c"; ...
    "plaintext.c"; "latex.c"; "houdini_href_e.c"; "houdini_html_e.c"; ...
    "houdini_html_u.c"; "cmark_ctype.c"; "arena.c"; "linked_list.c"; ...
    "syntax_extension.c"; "registry.c"; "plugin.c" ];
extensionNames = [ ...
    "core-extensions.c"; "table.c"; "strikethrough.c"; "autolink.c"; ...
    "tagfilter.c"; "ext_scanners.c"; "tasklist.c" ];

files = [ ...
    fullfile( cmarkDir, "src", srcNames )
    fullfile( cmarkDir, "extensions", extensionNames )
    fullfile( sourceDir, "emoji.c" )
    fullfile( sourceDir, "cmark-gfm_mex.c" )
    fullfile( generatedDir, "emoji_map.c" ) ];

end % cmarkSourceFiles

function generateSources( root )

cmarkDir = fullfile( root, "vendor", "cmark-gfm" );
gemojiDir = fullfile( root, "vendor", "gemoji" );
cmarkCMakeFile = fullfile( cmarkDir, "CMakeLists.txt" );
cmarkVersionTemplate = fullfile( cmarkDir, "src", "cmark-gfm_version.h.in" );
emojiJsonFile = fullfile( gemojiDir, "db", "emoji.json" );
generatedDir = fullfile( root, "build", "cmark-gfm" );

missingSubmodules = strings( 0, 1 );
if ~isfile( cmarkCMakeFile ) || ~isfile( cmarkVersionTemplate )
    missingSubmodules(end + 1, 1) = "vendor/cmark-gfm";
end
if ~isfile( emojiJsonFile )
    missingSubmodules(end + 1, 1) = "vendor/gemoji";
end
if ~isempty( missingSubmodules )
    error( "cmark_gfm:MissingSubmodule", ...
        "Missing or uninitialized submodule content: %s. Run " + ...
        "git submodule update --init --recursive before building.", ...
        strjoin( missingSubmodules, ", " ) )
end
if ~isfolder( generatedDir )
    mkdir( generatedDir );
end

version = read_cmark_version( cmarkCMakeFile );
write_cmark_version( ...
    fullfile( generatedDir, "cmark-gfm_version.h" ), version );
write_emoji_map( emojiJsonFile, generatedDir, ...
    fullfile( root, "src", "emoji_map.c.in" ) );

end % generateSources

function version = read_cmark_version( file )

text = fileread( file );
names = ["major", "minor", "patch", "gfm"];
version = struct;
for name = names
    expression = sprintf( "set\\(PROJECT_VERSION_%s\\s+(\\d+)\\)", ...
        upper( name ) );
    token = regexp( text, expression, "tokens", "once" );
    if isempty( token )
        error( "cmark_gfm:VersionMetadata", ...
            "Unable to find PROJECT_VERSION_%s in %s.", upper( name ), file );
    end
    version.(name) = str2double( token{1} );
end

end % read_cmark_version

function write_cmark_version( file, version )

root = fileparts( mfilename( "fullpath" ) );
template = fullfile( root, "vendor", "cmark-gfm", ...
    "src", "cmark-gfm_version.h.in" );
headerText = fileread( template );
names = ["major", "minor", "patch", "gfm"];
for name = names
    token = "@PROJECT_VERSION_" + upper( name ) + "@";
    value = sprintf( "%d", version.(name) );
    headerText = strrep( headerText, char( token ), value );
end
write_text( file, headerText );

end % write_cmark_version

function files = folderFiles( folder, pattern )

listing = dir( fullfile( folder, pattern ) );
files = fullfile( string( {listing.folder} ), string( {listing.name} ) )';

end % folderFiles

function write_text( file, text )

fileId = fopen( file, "w" );
if fileId < 0
    error( "cmark_gfm:GeneratedHeader", "Unable to create %s.", file );
end
cleanup = onCleanup( @() fclose( fileId ) );
fprintf( fileId, "%s", text );

end % write_text

function write_emoji_map( jsonFile, outputDir, templateFile )

entries = jsondecode( read_utf8_text( jsonFile ) );
aliases = strings( 0, 1 );
emojis = strings( 0, 1 );

for entry = entries'
    for alias = entry{1}.aliases
        aliases(end + 1, 1) = string( alias{1} ); %#ok<AGROW>
        emojis(end + 1, 1) = string( entry{1}.emoji ); %#ok<AGROW>
    end
end

[aliases, order] = sort( aliases );
emojis = emojis(order);
[aliases, uniqueIndices] = unique( aliases, "stable" );
emojis = emojis(uniqueIndices);

entryLines = cell( numel( aliases ), 1 );
for index = 1:numel( aliases )
    entryLines{index} = sprintf( '  {"%s", "%s"},', ...
        c_string( aliases(index) ), c_utf8_string( emojis(index) ) );
end

templateText = fileread( templateFile );
placeholder = "@EMOJI_ENTRIES@";
if numel( strfind( templateText, placeholder ) ) ~= 1
    error( "cmark_gfm:EmojiTemplate", ...
        "Expected exactly one %s placeholder in %s.", ...
        placeholder, templateFile );
end
sourceText = strrep( templateText, placeholder, ...
    strjoin( entryLines, newline() ) );

sourceFile = fullfile( outputDir, "emoji_map.c" );
write_text( sourceFile, sourceText );

end % write_emoji_map

function text = read_utf8_text( file )

fileId = fopen( file, "r", "n", "ISO-8859-1" );
if fileId == -1
    error( "cmark_gfm:EmojiData", "Unable to read emoji data: %s", file );
end
cleanup = onCleanup( @() fclose( fileId ) );
bytes = fread( fileId, "*uint8" )';
text = native2unicode( bytes, "UTF-8" );

end % read_utf8_text

function text = c_string( value )

text = char( value );
text = strrep( text, '\', '\\' );
text = strrep( text, '"', '\"' );

end % c_string

function text = c_utf8_string( value )

bytes = unicode2native( char( value ), "UTF-8" );
text = char( strjoin( compose( "\\x%02X", bytes ), "" ) );

end % c_utf8_string