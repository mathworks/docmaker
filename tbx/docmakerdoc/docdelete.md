# docdelete :recycle:

Delete DocMaker artifacts

## Syntax

`docdelete(d)` deletes DocMaker artifacts in the folder `d`.

`[files,folders] = docdelete(...)` returns the names of the files and folders deleted.

| Name | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `d`:arrow_right: | documentation folder, as an absolute or relative path | string | yes |
| :arrow_right:`files` | files(s) deleted, as an absolute path | string(s) | |
| :arrow_right:`folders` | folders(s) deleted, as an absolute path | string(s) | |

## Examples

```matlab
docdelete("mickey/goofy") 
```
deletes artifacts in the folder `mickey/goofy`.  Note that this path is *relative*.

```matlab
docconvert("C:\daisy\mickey\goofy") 
```
also deletes artifacts, this time specified using an *absolute* path.

## Details

The deletion consists of 4 steps:
1. Delete HTML documents corresponding to Markdown documents
2. Delete the resources subfolder, `resources`, containing stylesheets and scripts
3. Delete the index files `info.xml` and `helptoc.xml`
4. Delete the search database subfolder, `helpsearch-v4`

___

[home](index.md) :house: | [convert](docconvert.md) :arrow_right: | [run](docrun.md) :runner: | [index](docindex.md) :scroll: | [delete](docdelete.md) :recycle: | [workspace](workspace.md) :construction_worker: | [about](about.md) :hatching_chick: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2025