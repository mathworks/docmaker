# docerdelete :recycle:

Delete Doc'er artifacts

## Syntax

`docerdelete(d)` deletes Doc'er artifacts in the folder `d`.

## Description

`docerdelete` deletes:
* HTML files corresponding to Markdown files
* PNG files corresponding MATLAB scripts
* the resources subfolder, `resources`, containing stylesheets and scripts
* index files `info.xml` and `helptoc.xml`
* the search database subfolder, `helpsearch-v4`

## Inputs

| Input | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `d` | Documentation folder | string | required |

## Examples

```matlab
docerdelete("tbx/mydoc")
```

deletes Doc'er artifacts in the folder `tbx/mydoc`.

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://uk.mathworks.com/services/consulting.html) 2024