# Build automation

You can automate documentation generation as part of toolbox publishing using projects, source control integration, and (from R2022b) the [MATLAB Build Tool](https://www.mathworks.com/help/matlab/matlab_prog/overview-of-matlab-build-tool.html).

Here we set out an example using DocMaker itself.  You can adapt this example to your needs.

## Provisioning DocMaker

You should install DocMaker in both the developer and automation environments.

A basic option is to script installation from a known location at project startup.  The latest installer is available at:

```
https://github.com/mathworks/docmaker/releases/latest/download/MATLAB_DocMaker.mltbx
```

For specific versions, replace `latest` with the version tag, e.g. `v1.0` for version 1.0.  You can download the installer using [`websave`](https://www.mathworks.com/help/matlab/ref/websave.html), and then install the toolbox using [`matlab.addons.install`](https://www.mathworks.com/help/matlab/ref/matlab.addons.install.html).

A better option is to use a package manager such as [Package Jockey](https://insidelabs-git.mathworks.com/dsampson/pj) from [MathWorks Consulting](https://www.mathworks.com/consulting/).

Check that DocMaker is available using `ver`.

```matlab
s = ver("docmaker")
```

By default, DocMaker uses the [GitHub Markdown API](https://docs.github.com/en/rest/markdown) at `api.github.com` to convert Markdown to HTML.  You can [configure DocMaker](conversion.md) to use another converter technology or service instance or to authenticate with an access token.

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

with Markdown documents in `doc` and generated HTML documents, index files and other resources in `tbx/docmakerdoc`.  Since DocMaker generates output in place, the output needs to be moved to the shipping folder as a second step.

## Generating documentation

Create a build task `docTask` to generate the documentation.  The input is the documentation root folder.  The outputs are the HTML documents, resources folder, index files, and search database folder generated.

```matlab
plan("doc").Inputs = doc; % source folder, /tbx/docmakerdoc
plan("doc").Outputs = [fullfile(doc,"**","*.html"), ... % output HTML
    fullfile(doc,"resources"), ... % stylesheets and scripts
    fullfile(doc,"*.xml"), ... % index files
    fullfile(doc,"helpsearch-v*")]; % search database folder 
```

The task calls `docconvert`, `docrun` and `docindex` in turn:

```matlab
function docTask(c)

doc = c.Task.Inputs.Path; % source folder
md = fullfile(doc,"**","*.md"); % Markdown documents
html = docconvert(md); % convert to HTML
docrun(html) % run code and insert output
docindex(doc) % index

end 
```

The task will be skipped if the input and output have not changed since the last successful run.  Furthermore `buildtool clean` will remove generated artifacts, without the need to call `docerdelete` explicitly.

### Alternative layout

If you separate documentation input from output, you need a build task whose input is the source folder and output is the destination folder.

```matlab
plan("doc").Inputs = docin; % source folder, /doc
plan("doc").Outputs = docout; % destination folder, /tbx/docmakerdoc 
```

The build task begins as before, and then moves the generated artifacts.

```matlab
function docTask(c)

docin = c.Task.Inputs.Path; % source folder
docout = c.Task.Outputs.Path; % destination folder
md = fullfile(docin,"**","*.md"); % Markdown documents
[html,res] = docconvert(md); % convert to HTML
docrun(html) % run code and insert output
[xml,db] = docindex(doc); % index
mkdir(docout) % make destination folder
arrayfun(@movefile,html,fullfile(docout,extractAfter(html,docin))) % move HTML documents
movefile(res,fullfile(docout,extractAfter(res,docin))) % move resources folder
arrayfun(@movefile,xml,fullfile(docout,extractAfter(xml,docin))) % move index files
movefile(db,fullfile(docout,extractAfter(db,docin))) % move search database folder

end 
```

Since [`movefile`](https://www.mathworks.com/help/matlab/ref/movefile.html) is not vectorized, we need to use [`arrayfun`](https://www.mathworks.com/help/matlab/ref/arrayfun.html) :point_up:.

## Packaging the toolbox

Use [`packageToolbox`](https://www.mathworks.com/help/matlab/ref/matlab.addons.toolbox.packagetoolbox.html) with [`ToolboxOptions`](https://www.mathworks.com/help/matlab/ref/matlab.addons.toolbox.toolboxoptions.html) to package the toolbox.  If your documentation source is located under the toolbox root then you may wish to remove the source from the list of packaged files.

```matlab
o = matlab.addons.toolbox.ToolboxOptions("tbx",id,...);
o.ToolboxFiles(o.ToobloxFiles.endsWith(".md")) = []; % remove Markdown documents 
```

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2026