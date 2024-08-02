# docerrun :runner:

Run MATLAB code in HTML documents and insert output

## Syntax

`docerrun(html)` runs MATLAB code blocks in the HTML document(s) `html`, and inserts the textual and graphical output.

Multiple documents may also be specified using `docerrun(html1,html2,...)`.
 
`docerrun(...,"Level",b)` specifies the batching level `l`.  With level `0` (default), all blocks in a document are run in a single batch. With level `n`, each level-n heading is run as a separate batch, with the workspace cleared and figures closed between batches.

## Inputs

| Input | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `html` | HTML document(s), as an absolute or relative path; wildcards are [supported](https://www.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | yes |
| `b` | Batching level, from 0 to 6; default is 0 | double | :test_tube: |

## Examples

```matlab
docerrun("mickey/pluto.html") 
```
processes a single HTML document `mickey/pluto.html`.  Note that this path is *relative*.

```matlab
docerrun("C:\daisy\mickey\pluto.html") 
```
also processes a single HTML document, this time specified using an *absolute* path.

```matlab
docerrun("mickey/*.html") 
```
processes *all* HTML documents in `mickey`.

```matlab
docerrun("mickey/**/*.html") 
```
processes all HTML documents in `mickey` *and its subfolders*.

```matlab
docerrun(["mickey/pluto.html" "mickey/donald.html"]) 
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

[`docerconvert`](docerconvert.md) transforms MATLAB code blocks in Markdown documents into `<div>`s with `class` `highlight-source-matlab` in HTML documents.

### Executing MATLAB code

`docerrun` evaluates each code block in turn in a MATLAB [workspace](workspace.md) that is *private* to the document.  Variables created in earlier blocks are available for use in later blocks.

If an error occurs in one block then `docerrun` moves on to the next block.  However, it is likely that an error in an earlier block will lead to further errors in later blocks.

If you wish to display *but not evaluate* MATLAB code, add trailing whitespace to the last line of the code block, and `docerrun` will leave it be.

### Inserting MATLAB output

`docerrun` captures messages to the command window, and monitors creation of new figures and changes to existing figures.

After *each* code block is executed, `docerrun` inserts the messages and figure screenshots into the HTML document, immediately after the corresponding code block.

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

`docerrun` inserts MATLAB outputs into HTML documents in `<div>`s with `class` `highlight-output-matlab`.  Previous outputs are removed.

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024