# Elements

The MATLAB command window tries to be clever by rendering what looks like HTML in output.

## Strings

```matlab
s = "vanilla"
```

With `<a>`; note the escaped double quotes:

```matlab
s = "vanilla <a href=""https://www.ice.org/"">ice</a> cream"
```

With `<strong>`:

```matlab
s = "vanilla <strong>ice</strong> cream"
```

Unclosed `<a>`:

```matlab
s = "vanilla <a href=""https://www.ice.org/"">ice cream"
```

Unclosed `<strong>`:

```matlab
s = "vanilla <strong>ice cream"
```

Nested:

```matlab
s = "vanilla <a href=""https://www.ice.org/""><strong>ice</strong></a> cream"
```

Nested out of order:

```matlab
s = "vanilla <a href=""https://www.ice.org/""><strong>ice</a></strong> cream"
```

The last example :point_up: behaves differently in MATLAB, which tries to render the `<a>`, and discards the `<strong>` within it, but does render the `</strong>`.  DocMaker first discards the `<a>`, and then matches and discards the `<strong>` that spanned the `<a>` boundary.  We won't bother trying to address this edge case.

## Tables

Here is a table.  The variable names are rendered as `<strong>` and this needs to be stripped out.

```matlab
t = table([1;2;3],["a";"b";"c"],VariableNames=["foo","bar"])
```

If the table data contains `<strong>` then MATLAB gets confused

```matlab
t = table([1;2;3],["<strong>";"b";"</strong>"],VariableNames=["foo","bar"])
```

but not if the `<strong>` is not closed.

```matlab
t = table([1;2;3],["<strong>";"b";"c"],VariableNames=["foo","bar"])
```

What about if we have links in the table data?

```matlab
t = table([1;2;3],["<a href=""https://www.ice.org"">ice";"b";"</a>"],VariableNames=["foo","bar"])
```

DocMaker matches the plain text appearance of MATLAB in this case :point_up:.

The end.  :hatching_chick: