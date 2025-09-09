# docrun :runner:

Run MATLAB code in HTML documents and insert output

## Syntax

`docrun(html)` runs MATLAB code blocks in the HTML document(s) `html`, and inserts the textual and graphical output.

Multiple documents may also be specified using `docrun(html1,html2,...)`.
 
`docrun(...,"Level",n)` specifies the batching level `n`.  With level 0 (default), all blocks in a document are run in a single batch. With level `n`, each level-n heading is run as a separate batch, with the workspace cleared and figures closed between batches.  With level 7, each block is run as a separate batch.

`files = docrun(...)` returns the names of the files modified.

| Name | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `html`:arrow_right: | HTML document(s), as an absolute or relative path; wildcards are [supported](https://www.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | yes |
| `n`:arrow_right: | batching level, from 0 to 7; default is 0 | double | :test_tube: |
| :arrow_right:`files` | HTML document(s) modified, as an absolute path | string(s) | |

## Examples

```matlab
docrun("mickey/pluto.html") 
```
processes a single HTML document `mickey/pluto.html`.  Note that this path is *relative*.

```matlab
docrun("C:\daisy\mickey\pluto.html") 
```
also processes a single HTML document, this time specified using an *absolute* path.

```matlab
docrun("mickey/*.html") 
```
processes *all* HTML documents in `mickey`.

```matlab
docrun("mickey/**/*.html") 
```
processes all HTML documents in `mickey` *and its subfolders*.

```matlab
docrun(["mickey/pluto.html" "mickey/donald.html"]) 
```
processes *multiple* HTML documents.

## Description

### Steps

Each run consists of 6 steps:
1. Note pre-existing figures
2. Read the HTML document
3. Remove previous MATLAB output
4. Process each MATLAB code block in turn
   1. Run the code
   2. Insert textual output
   3. Insert graphical output
5. Write the modified HTML document
6. Close non-pre-existing figures

### Including MATLAB code

You can include MATLAB [code blocks](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks) in Markdown documents using ` ```matlab `.  The raw Markdown looks like:

````
```matlab
x = 0:0.1:10;
plot(x,sin(x))
```
````

These blocks are rendered with MATLAB syntax highlighting:

```matlab
x = 0:0.1:10;
plot(x,sin(x)) 
```

[`docconvert`](docconvert.md) transforms MATLAB code blocks in Markdown documents into `<div>`s with `class` `highlight-source-matlab` in HTML documents.

### Executing MATLAB code

`docrun` evaluates each code block in turn in a MATLAB [workspace](workspace.md) that is *private* to the document.  Variables created in earlier blocks are available for use in later blocks.

If an error occurs in one block then `docrun` rethrows the error as a warning (identifier `docmaker:EvalError`) and moves on to the next block.  However, it is likely that an error in an earlier block will lead to further errors in later blocks.

If you wish to display *but not evaluate* MATLAB code, add trailing whitespace to the last line of the code block, and `docrun` will leave it be.

### Inserting MATLAB output

`docrun` captures messages to the command window, and monitors creation of new figures and changes to existing figures.

After *each* code block is executed, `docrun` inserts the messages and figure screenshots into the HTML document, immediately after the corresponding code block.

Messages are inserted as plain text, with markup removed.

```matlab
m = magic(4)
```

Figures are inserted, at the on-screen size.

```matlab
f = figure("Color",[213 80 0]/255,"Position",[1 1 400 300]);
movegui(f,"center")
peaks
```

Error messages are also inserted, with the offending statement indicated.

```matlab
m = magick(4)
```

`docrun` inserts MATLAB outputs into HTML documents in `<div>`s with `class` `highlight-output-matlab`.  Previous outputs are removed.

### Display scaling

Display scaling is a feature that adjusts the size of elements on screen to ensure they are easily readable and usable, regardless of the resolution of your display. This is particularly useful for high-resolution displays, where elements can appear too small to see comfortably at the native resolution.

`docrun` uses `getframe` to capture screenshots.  `getframe` captures screenshots using native resolution, to maximize quality.  In versions prior to 0.4, this led to inconsistencies in image sizes between applications and machines.  From version 0.4, `docrun` includes scaled image sizes in the generated HTML.

___

[home](index.md) :house: | [convert](docconvert.md) :arrow_right: | [run](docrun.md) :runner: | [index](docindex.md) :scroll: | [delete](docdelete.md) :recycle: | [workspace](workspace.md) :construction_worker: | [about](about.md) :hatching_chick: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2025