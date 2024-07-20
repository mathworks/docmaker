# docerdelete :recycle:

Delete Doc_er artifacts

## Syntax

`docerdelete(d)` deletes Doc_er artifacts in the folder `d`.

## Inputs

| Input | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `d` | Documentation folder, as an absolute or relative path | string | yes |

## Examples

```matlab
docerdelete("mickey/goofy")
```
deletes artifacts in the folder `mickey/goofy`.  Note that this path is *relative*.

```matlab
docerconvert("C:\daisy\mickey\goofy")
```
also deletes artifacts, this time specified using an *absolute* path.

## Details

The deletion consists of 5 steps:
1. Delete HTML documents corresponding to Markdown documents
2. Delete image files corresponding to MATLAB scripts
3. Delete the resources subfolder, `resources`, containing stylesheets and scripts
4. Delete the index files `info.xml` and `helptoc.xml`
5. Delete the search database subfolder, `helpsearch-v4`

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024