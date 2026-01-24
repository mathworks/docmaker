# Build automation

In this age of DevOps, you will want to automate documentation generation as part of toolbox publishing.  This is achieved best by using projects, source control integration, and (from R2022b) the [MATLAB Build Tool](https://www.mathworks.com/help/matlab/matlab_prog/overview-of-matlab-build-tool.html).

Here we set out an example using DocMaker itself.  You can adapt this example to your needs.

## Provisioning DocMaker

You should install DocMaker in both the developer and automation environments.

A crude option is to script installation from a known location in the project setup.

```matlab
matlab.addons.install("path/to/docmaker.mltbx") 
```

A better option is to use a package manager such as [Package Jockey](https://insidelabs-git.mathworks.com/dsampson/pj) from [MathWorks Consulting](https://www.mathworks.com/consulting/).

```matlab
pjadd docmaker 
```

Check that DocMaker is available using `ver`.

```matlab
s = ver("docmaker")
```


## Organizing files

You should organize your toolbox project files, separating code, documentation, tests, releases, etc. into folders.  For DocMaker, this looks like:

```
docmaker
|- tbx
  |- docmaker
  |- docmakerdoc
|- tests
|- releases
.gitignore
buildfile.m
docmaker.prj
README.md
```

`docmaker.prj` is the MATLAB project file.  `tbx` is the toolbox root folder -- the folder containing the shipping files -- with code in `docmaker`, and documentation in `docmakerdoc`.

Track your files with Git.  Only DocMaker *source* artifacts (`*.md`, `*.m`) should be tracked.  You can exclude *generated* artifacts via `.gitignore` entries:

```
tbx/docmakerdoc/**/*.html
tbx/docmakerdoc/info.xml
tbx/docmakerdoc/helptoc.xml
tbx/docmakerdoc/custom_toolbox.json
tbx/docmakerdoc/resources
tbx/docmakerdoc/helpsearch-v*
```

### Alternative layout

Some authors prefer to separate documentation input from output.  This looks like:

```
docmaker
|- doc
|- tbx
  |- docmaker
  |- docmakerdoc
```

with Markdown files in `doc` and generated HTML files, XML files and other resources in `tbx/docmakerdoc`.  This approach has the advantage of separating the shipping and non-shipping files, but the disadvantage that the generated artifacts need to be moved from the (non-shipping) source to the shipping folder.

## Generating documentation

Create a build task `docTask` to generate the documentation.  The input is the documentation root folder.  The outputs are the HTML documents, resources folder, XML files, and search database folder generated.

```matlab
plan("doc").Inputs = doc; % source folder
plan("doc").Outputs = [fullfile(doc,"**","*.html"), ... % output HTML
    fullfile(doc,"resources"), ... % stylesheets and scripts
    fullfile(doc,"*.xml"), ... % helptoc.xml and info.xml
    fullfile(doc,"helpsearch-v4*")]; % search database 
```

The task calls `docconvert`, `docrun` and `docindex` in turn:

```matlab
function docTask(c)

doc = c.Task.Inputs.Path; % source folder
md = fullfile(doc,"**","*.md"); % Markdown files
html = docconvert(md); % convert to HTML
docrun(html) % run code and insert output
docindex(doc) % index

end 
```

The task will be skipped if the input and output have not changed since the last successful run.  Furthermore `buildtool clean` will remove generated artifacts, without the need to call `docerdelete` explicitly.

### Alternative layout

If you separate documentation input from output, then you need to move the generated files at the end of the documentation task:

```matlab
function docTask(c)

docin = c.Task.Inputs.Path; % source folder
docout = fullfile(docin,"..","")
md = fullfile(doc,"**","*.md"); % Markdown files
[html,res] = docconvert(md); % convert to HTML
docrun(html) % run code and insert output
[xml,db] = docindex(doc) % index
movefile(html,docout)
movefile(res,docout)
movefile(xml,docout)
movefile(db,docout)

end 
```

You should also adjust the task outputs accordingly:

```matlab
plan("doc").Inputs = docin; % source folder
plan("doc").Outputs = [fullfile(docout,"**","*.html"), ... % output HTML
    fullfile(docout,"*.xml"), ... % helptoc.xml and info.xml
    fullfile(docout,"resources"), ... % stylesheets and scripts
    fullfile(docout,"helpsearch-v4*")]; % search database 
```

## Packaging the toolbox

Use [`packageToolbox`](https://www.mathworks.com/help/matlab/ref/matlab.addons.toolbox.packagetoolbox.html) with [`ToolboxOptions`](https://www.mathworks.com/help/matlab/ref/matlab.addons.toolbox.toolboxoptions.html) to package the toolbox.  If your documentation source is located under the toolbox root then you may wish to remove the source from the list of packaged files.

```matlab
o = matlab.addons.toolbox.ToolboxOptions("tbx",id,...);
o.ToolboxFiles(o.ToobloxFiles.endsWith(".md")) = []; % remove Markdown files 
```

## FAQs -- to be deleted

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

___

[home](index.md) :house: | [convert](docconvert.md) :arrow_right: | [run](docrun.md) :runner: | [index](docindex.md) :scroll: | [delete](docdelete.md) :recycle: | [workspace](workspace.md) :construction_worker: | [about](about.md) :hatching_chick: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2026