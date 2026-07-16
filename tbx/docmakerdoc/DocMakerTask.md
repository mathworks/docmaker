# DocMakerTask :factory:

Custom build task for generating documentation

## Syntax

`plan("doc") = DocMakerTask(md)` creates a documentation generation task, named `"doc"`, for the Markdown documents `md`, in the build plan `plan`. 
Multiple documents may also be specified using `DocMakerTask(md1,md2,...)`.

`plan("doc") = DocMakerTask(...,"Theme",t)` sets the theme `t`.  Available themes are `light`, `dark`, and `auto` (responsive, default).  For viewing as part of the MATLAB documentation, especially prior to R2025a, light mode works best.  For viewing standalone, responsive mode works well.

`plan("doc") = DocMakerTask(...,"Stylesheets",css)` includes the stylesheet(s) `css`.

`plan("doc") = DocMakerTask(...,"Scripts",js)` includes the script(s) `js`.  Scripts are included at the end of the body in the order specified to ensure that the HTML content is loaded and rendered before the scripts run.  :test_tube:

`plan("doc") = DocMakerTask(...,"Root",r)` publishes to the root folder `r`, placing stylesheets and scripts in the subfolder `resources`.  The root folder must be a common ancestor of the Markdown documents.  If not specified, the root folder is the lowest common ancestor.

`plan("doc") = DocMakerTask(...,"Interpreter",in)` uses the interpreter `in` to postprocess 
inline or display LaTeX expressions. Available interpreters 
are `latex` or `none` (default). Specify inline LaTeX expressions between 
single dollar symbols (`$`), and display LaTeX expressions between 
double dollar symbols (`$$`).

`plan("doc") = DocMakerTask(...,"Level",n)` specifies the batching level `n`.  With level 0 (default), all blocks in a document are run in a single batch. With level `n`, each level-n heading is run as a separate batch, with the workspace cleared and figures closed between batches.  With level 7, each block is run as a separate batch.

`plan("doc") = DocMakerTask(...,"FigureSize",s)` sets the default figure size `s`.  Size is `[width height]` in default figure `Units`.

`plan("doc") = DocMakerTask(...,"FigureTheme",t)` sets the figure theme `t`.  Available themes are `none` (as is, default), `light`, `dark`, and `auto` (responsive).  For viewing as part of the MATLAB documentation, especially prior to R2025a, light mode works best.  For viewing standalone, responsive mode works well.


| Name | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `md`:arrow_right: | Markdown document(s), as an absolute or relative path; wildcards are [supported](https://www.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | yes |
| `t`:arrow_right: | theme: `light`, `dark`, or `auto`; default is `auto` | string(s) | |
| `css`:arrow_right: | CSS stylesheet(s), as an absolute or relative path; wildcards are [supported](https://www.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | |
| `js`:arrow_right: | JavaScript script(s), as an absolute or relative path; wildcards are [supported](https://www.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | :test_tube: |
| `r`:arrow_right: | root folder, as an absolute or relative path; default is the lowest common ancestor of `md` | string | |
| `in`:arrow_right: | LaTeX interpreter: `latex` or `none`; default is `none` | string | |
| `n`:arrow_right: | batching level, from 0 to 7; default is 0 | double | :test_tube: |
| `s`:arrow_right: | default figure size, in default figure `Units` | double | |
| `t`:arrow_right: | figure theme: `none`, `light`, `dark`, or `auto`; default is `none` | string(s) | |


## Examples
Add a documentation generation task to the build plan for all Markdown documents in the folder `doc`. Use light theme for the 
documentation files and figure snapshots, and specify a figure size of 600-by-400 pixels.
```matlab
md = fullfile(doc, "**", "*.md"); % Markdown documents
plan("doc") = DocMakerTask(md, "Theme", "light", ...
    "FigureSize", [600, 400], ...
    "FigureTheme", "light"); 
```
The `DocMakerTask` automatically assigns the task outputs to enable incremental builds. The task outputs are:

* The HTML files: `fullfile(doc, "**", "*.html")`
* The index files: `fullfile(doc, ["info.xml", "helptoc.xml"])`
* The resources folder: `fullfile(doc, "resources")`
* The search database folder: `fullfile(doc, "helpsearch-v*")`

For further examples of using the task inputs, see [`docconvert`](docconvert.md), [`docrun`](docrun.md), and [`docindex`](docindex.md).

___

[home](index.md) :house: | [convert](docconvert.md) :arrow_right: | [run](docrun.md) :runner: | [index](docindex.md) :scroll: | [delete](docdelete.md) :recycle: | [workspace](workspace.md) :construction_worker: | [about](about.md) :hatching_chick: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2026