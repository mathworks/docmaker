Here is a table...

```matlab
t = table([1;2;3],["a";"b";"c"],VariableNames=["foo","bar"])
```

And here is an odd one with `<strong>` elements in the table data.  This confuses the MATLAB command window.

```matlab
t = table([1;2;3],["<strong>";"b";"</strong>"],VariableNames=["foo","bar"])
```

The end.