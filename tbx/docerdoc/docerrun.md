# docerrun :runner:

Run MATLAB code in HTML documents and insert output

## Syntax

`docerrun(html)` runs MATLAB code blocks in the HTML document(s) html, and inserts the textual and graphical output.

Multiple documents may also be specified using `docerrun(html1,html2,...)`.
 
`docerrun(...,"Level",level)` specifies the batching level.  With level `0` (default), all blocks in a document are run in a single batch. With level `n`, each level-n heading is run as a separate batch, with the workspace cleared and figures closed between batches.

`docerrun(...,"Mode",mode)` specifies the execution mode.  With mode `auto` (default), all blocks are run.  With mode `manual`, only blocks under headings marked with :zap: `:zap:` are run.  Higher level :zap:s apply to lower level headings.

## Inputs

| Input | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `html` | HTML document(s), as an absolute or relative path; wildcards are [supported](https://www.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | yes |
| `level` | Batching level, from 0 to 6; default is 0 | double | |
| `mode` | Execution mode; default is `auto` | `auto` or `manual` | |

## Examples

```matlab
docerrun("mickey/pluto.m")
```
runs a single MATLAB script `mickey/pluto.m`.  The file extension `.m` is optional.  Note that this path is *relative*.

```matlab
docerrun("C:\daisy\mickey\pluto.m")
```
also runs a single MATLAB script, this time specified using an *absolute* path.

```matlab
docerrun("mickey/*.m")
```
runs *all* MATLAB scripts in `mickey`.

```matlab
docerrun("mickey/**/*.m")
```
runs all MATLAB scripts in `mickey` *and its subfolders*.

```matlab
docerrun(["mickey/pluto.m" "mickey/donald.m"])
```
runs *multiple* MATLAB scripts.

```matlab
docerrun("mickey/pluto.m","Size",[400 300])
```
sets the figure size to 400-by-300 pixels.

```matlab
docerrun("mickey/pluto.m","Resolution",96)
```
sets the screenshot resolution to 96 dpi.

## Description

## Steps

Each run consists of 4 steps:
1. Run the MATLAB script
2. Resize the generated figure(s) to the specified size
3. Save the figure(s) to image file(s) at the specified resolution next to the original script
4. Close the generated figure(s)

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024