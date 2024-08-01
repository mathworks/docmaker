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

MATLAB code blocks are designated with ` ```matlab `.  These blocks are syntax highlighted.

MATLAB code blocks that end with whitespace are not executed, but are syntax highlighted.

### Steps

Each run consists of 5 steps:
1. Read the HTML document
2. Remove previous MATLAB output
3. Run each MATLAB code block in turn
4. After each code block, insert textual and graphical output
5. Write the modified HTML document

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024