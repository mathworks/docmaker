# docerdelete :recycle:

Delete Doc_er artifacts

## Syntax

`docerdelete(d)` deletes Doc_er artifacts in the folder `d`.

`[files,folders] = docerdelete(...)` returns the names of the files and folders deleted.

| Name | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `d`:arrow_right: | Documentation folder, as an absolute or relative path | string | yes |
| :arrow_right:`files` | files(s) deleted, as an absolute path | string(s) | |
| :arrow_right:`folders` | folders(s) deleted, as an absolute path | string(s) | |

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

The deletion consists of 4 steps:
1. Delete HTML documents corresponding to Markdown documents
2. Delete the resources subfolder, `resources`, containing stylesheets and scripts
3. Delete the index files `info.xml` and `helptoc.xml`
4. Delete the search database subfolder, `helpsearch-v4`

___

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [workspace](workspace.md) :construction_worker: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024