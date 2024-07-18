# docerconvert :arrow_right:

Convert Markdown files to HTML

## Syntax

`docerconvert(md)` converts the Markdown documents in the specification `md` to HTML.

`docerconvert(...,"Stylesheets",css)` includes the stylesheet(s) `css`.  Stylesheets `github-markdown.css` and `matlaby.css` are always included.

`docerconvert(...,"Scripts",js)` includes the script(s) `js`.

`docerconvert(...,"Root",d)` publishes to the root folder `d`, placing stylesheets and scripts in the subfolder `resources`.  The root folder must be a common ancestor of the Markdown files.  If not specified, the root folder is the lowest common ancestor.

## Description

## Inputs

| Input | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `md` | Markdown document(s), as filename(s) or [dirspec](https://uk.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | required |
| `css` | CSS stylesheets, as filename(s) or [dirspec](https://uk.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | `Stylesheets` |
| `js` | JavaScript scripts, as filename(s) or [dirspec](https://uk.mathworks.com/help/matlab/ref/dir.html#bsnswnx-1-name) | string(s) | `Scripts` |
| `d` | Root folder; default is the superfolder of `md` | string | `Root` |

## Examples

```matlab
docerconvert("tbx/mydoc/foo.md")
```
converts a single Markdown document `tbx/mydoc/foo.md` to HTML.  Note that this path is *relative*.

```matlab
docerconvert("C:\path\to\bar.md")
```
also converts a single Markdown document, this time specified using an *absolute* path.

```matlab
docerconvert("tbx/mydoc/*.md")
```
converts *all* Markdown documents in `tbx/mydoc` to HTML.

```matlab
docerconvert("tbx/mydoc/**/*.md")
```
converts all Markdown documents in `tbx/mydoc` *and its subfolders* to HTML.



## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://uk.mathworks.com/services/consulting.html) 2024