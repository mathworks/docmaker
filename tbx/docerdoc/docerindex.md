# docerindex :scroll:

Create documentation index files

## Syntax

`docerindex(d)` creates documentation index files `info.xml` and `helptoc.xml` and search database `helpsearch_v4` in the folder `d`.

## Inputs

| Input | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `d` | Documentation folder, as an absolute or relative path | string | yes |

## Examples

```matlab
docerindex("mickey/goofy") 
```
indexes documentation in the folder `mickey/goofy`.  Note that this path is *relative*.

```matlab
docerindex("C:\daisy\mickey\goofy") 
```
also indexes documentation, this time specified using an *absolute* path.

## Details

### `info.xml` and `helptoc.xml`

`info.xml` enables MATLAB to find and identify your HTML help files.  `helptoc.xml` contains the table of contents for your documentation that is displayed in the Contents sidebar of the Help browser.  The MATLAB documentation contains [further details](https://www.mathworks.com/help/matlab/matlab_prog/display-custom-documentation.html), that you do not need to know about anymore once you are generating rather than hand-writing these files.

### Table of contents requirements

`helptoc.md` should contain:
* a level-1 heading `# Heading` with the name of the toolbox
* a nested list of links `* [text](ref.md)` to your Markdown documents

For example:

```md
# Ducks Toolbox

* [Getting started](index.md)
  * [Huey](huey.md)
  * [Louie](louie.md)
  * [Dewey](dewey.md)
```

If you need a list item to group child items, specify an empty link URL, e.g. `* [Function reference]()`.  Other content in `helptoc.md` -- including additional links and normal text in list items -- is ignored.

### Steps

The indexing consists of 4 steps:
1. Read `helptoc.md` in the specified folder
2. Create `info.xml` in the specified folder with
   * `<name>` content set to the first level-1 heading `# Heading`
3. Create `helptoc.xml` in the specified folder with
   * nested `<tocitem>`s for each list item `* [text](ref.md)`
   * `<tocitem>` attribute `target` set to the list item link reference, with `.md` links replaced by `.html` equivalents
   * `<tocitem>` content set to the list item link text
4. Run [`builddocsearchdb`](https://www.mathworks.com/help/matlab/ref/builddocsearchdb.html) in the specified folder to build the documentation search database.

## See also

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [workspace](workspace.md) :construction_worker: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024