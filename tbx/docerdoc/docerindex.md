# docerindex :scroll:

Create documentation index files

## Syntax

`docerindex(d)` generates documentation index files in the folder `d`:
* `info.xml`, from the level-1 heading in `helptoc.md`
* `helptoc.xml`, from the list item links in `helptoc.md`

The [documentation index file requirements](https://uk.mathworks.com/help/matlab/matlab_prog/display-custom-documentation.html) are described in detail in the MATLAB documentation.  With Doc'er, you can generate rather than hand-write these files.

## Inputs

| Input | Type | Description |
| --- | --- | --- |
| `d` | string | Documentation folder |

## Examples

```matlab
docerindex("tbx/mydoc")
```

creates documentation index files in the folder `tbx/mydoc`.

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://uk.mathworks.com/services/consulting.html) 2024