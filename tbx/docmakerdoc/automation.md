# Automating documentation generation

In this age of DevOps, you will want to automate the generation of documentation as part of toolbox publishing.  This is achieved best by using projects, source control integration, and (from R2022b) the [MATLAB Build Tool](https://www.mathworks.com/help/matlab/matlab_prog/overview-of-matlab-build-tool.html).

Here we set out an example using DocMaker itself.  You can adapt this example to your needs.

## Tracking files

Add only source artifacts (`*.md`, `*.m`) -- not generated artifacts (`*.html`, `*.xml`) -- to Git via `.gitignore`:

```
tbx/docmakerdoc/**/*.html
tbx/docmakerdoc/info.xml
tbx/docmakerdoc/helptoc.xml
tbx/docmakerdoc/custom_toolbox.json
tbx/docmakerdoc/resources
tbx/docmakerdoc/helpsearch-v*
```

## Generating documentation

Create a build task to generate the documentation:

```matlab
function docTask(c)

doc = c.Task.Inputs.Path; % source folder
md = fullfile(doc,"**","*.md"); % Markdown files
html = docconvert(md); % convert to HTML
docrun(html) % run code and insert output
docindex(doc) % index

end 
```

Specify the task inputs and outputs:

```matlab
plan("doc").Inputs = doc; % source folder
plan("doc").Outputs = [fullfile(doc,"**","*.html"), ... % output HTML
    fullfile(doc,"*.xml"), ... % helptoc.xml and info.xml
    fullfile(doc,"resources"), ... % stylesheets and scripts
    fullfile(doc,"helpsearch-v4*")]; % search database 
```

Specifying the outputs in this way enables:
1. incremental build: the task will be skipped if the input and output have not changed since the task last ran successfully
2. output clean: `buildtool clean` will remove generated artifacts, without the need to call `docdelete` explicitly

## FAQs

How do I ensure that MATLAB&#174; DocMaker is available in my developer and build environments?
* You can check that DocMaker is available using `ver`.  :point_right: `ver("docmaker")`.
* You could script installation from a known location in the project setup or the `buildfile`.  :point_right: `matlab.addons.install("path/to/DocMaker.mltbx")`
* You could use a package manager such as [Package Jockey](https://insidelabs-git.mathworks.com/dsampson/pj) from [MathWorks Consulting](https://www.mathworks.com/consulting/).  :point_right: `pjadd docmaker`

Where in my project should I put my documentation source?
* You could put your Markdown files under the toolbox root.  This is useful when you are including examples that need to be on the path.  You may then wish to exclude the Markdown files from packaging.
```matlab
function packageTask( c )
% Package toolbox

...

% Create toolbox packaging options
opts = matlab.addons.toolbox.ToolboxOptions( .. );

% Identify Markdown files under the toolbox root
[folder, ~, ext] = fileparts( opts.ToolboxFiles );
prjRoot = c.Plan.RootFolder;

% Replace the following with your toolbox doc folder
docRoot = fullfile( prjRoot, "tbx", "docmakerdoc" ); 

% Exclude Markdown files from packaging
mdIdx = (folder == docRoot) & (ext == ".md");
opts.ToolboxFiles(mdIdx) = [];

...

end % packageTask 
```
* You can put your Markdown files outside the toolbox root.  You will need to move the generated HTML and other artifacts to under the toolbox root for packaging.  You should adapt the `docTask` in the build file and its outputs accordingly.
```matlab
function docTask(c)

doc = c.Task.Inputs.Path; % source folder
md = fullfile(doc,"**","*.md"); % Markdown files
html = docconvert(md); % convert to HTML
docrun(html) % run code and insert output
[indexFiles, databaseFolder] = docindex(doc); % index

% Move the HTML files
destinationFolder = c.Plan.Task.Outputs.paths;
for fileIdx = 1:numel(html)
    movefile(html(fileIdx), destinationFolder)
end

% Move the index files
movefile(indexFiles(1), destinationFolder) % info.xml
movefile(indexFiles(2), destinationFolder) % helptoc.xml
movefile(databaseFolder, destinationFolder) % helpsearch-v4*

% Move the resouces folder
movefile(fullfile(doc, "resources"), destinationFolder)

end % moveTask 
```
Adapt the task outputs:
```matlab
plan("doc").Inputs = doc; % source folder
mydoc = fullfile("tbx", "mydoc"); % Specify doc target folder under tbx
plan("doc").Outputs = [fullfile(mydoc,"**","*.html"), ... % output HTML
    fullfile(mydoc,"*.xml"), ... % helptoc.xml and info.xml
    fullfile(mydoc,"resources"), ... % stylesheets and scripts
    fullfile(mydoc,"helpsearch-v4*")]; % search database 
```

Should I generate responsive documentation?
* For viewing as part of the MATLAB documentation, especially prior to R2025a, light mode works best.  :point_right: `docconvert ... Theme light`, `docrun ... Theme light`
* For viewing standalone, responsive mode works well.  :point_right: `docconvert ... Theme auto`, `docrun ... Theme auto`
