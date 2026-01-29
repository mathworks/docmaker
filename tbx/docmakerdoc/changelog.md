# Release notes

## Version 0.6

* Changed name from "Doc_er" to "MATLAB&#174; DocMaker"
* Changed function names from `docer...` to `doc...`
* Added theme support to `docrun`
* Specify default figure size for `docrun`
* Return HTML document(s) and resources folder created from `docconvert`
* Return HTML document(s) modified from `docrun`
* Return index files and search database folder created from `docindex`
* Added documentation on build automation
* Changed token secret to `DocMaker GitHub token`

## Version 0.5.1

* Changed token secret to `Doc_er GitHub token`
* Documented token search order

## Version 0.5

* Added theme support to `docerconvert`

## Version 0.4.1

* `docerconvert` copies [third-party license](https://github.com/sindresorhus/github-markdown-css) into output

## Version 0.4

* `docerrun` inserts screenshot at correct size, irrespective of display scaling

## Version 0.3.1

* `docerrun` works when console output contains `<`

## Version 0.3

* Added copy button to code blocks
* Added support for custom JavaScript scripts to `docerconvert`
* Works with MATLAB in the system browser from R2024b

## Version 0.2

* Initial limited release within MathWorks :tada:.
* Core functionality is in place: `docerconvert`, `docerrun`, `docerindex`, and `docerdelete`.  This version of Doc_er uses the [GitHub Markdown API](https://docs.github.com/en/rest/markdown) to convert Markdown to HTML.

___

[home](index.md) :house: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024-2026