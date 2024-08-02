# Workspace :construction_worker:

Private workspace for assigning variables and evaluating expressions

## Properties

`docer.Workspace` has no public properties.

## Methods

### Creation

`w = docer.Workspace()` creates a new, empty workspace `w`.

`w = docer.Workspace(n1,v1,n2,v2,...)` creates a workspace `w`, and assigns variable `n1` to value `v1`, variable `n2` to value `v2`, etc.

| Name | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `n`:arrow_right: | variable name(s) | string(s) | |
| `v`:arrow_right: | variable value(s) | any | |
| :arrow_right:`w` | workspace | `docer.Workspace` | |

### Assignment

`assignin(w,n,v)` assigns the variable `n` to value `v` in the workspace `w`.

`assignin(w,n1,v1,n2,v2,...)` assigns variable `n1` to value `v1`, variable `n2` to value `v2`, etc. in the workspace `w`.

| Name | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `w`:arrow_right: | workspace | `docer.Workspace` | yes |
| `n`:arrow_right: | variable name(s) | string(s) | |
| `v`:arrow_right: | variable value(s) | any | |

### Evaluation

`evalin(w,s)` evaluates the statement(s) `s` in the workspace `w`.

`[o1,o2,...] = evalin(w,s)` evaluates the statement `s` in the workspace `w`, and returns the outputs `o1`, `o2`, etc.  It is not possible to return outputs from multiple statements or assignments.

`c = evalinc(w,s)` evaluates the statement(s) `s` in the workspace `w`, and returns the command window output `c`.

`[c,o1,o2,...] = evalinc(w,s)` evaluates the statement `s` in the workspace `w`, and returns the outputs `o1`, `o2`, etc. and the command window output `c`.

| Name | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `w`:arrow_right: | workspace | `docer.Workspace` | yes |
| `s`:arrow_right: | statement(s) | string | yes |
| :arrow_right:`c` | command window output | string | |
| :arrow_right:`o` | output(s) | any | |

`clearvars(w,n1,n2,...)` clears the variables `n1`, `n2`, etc. from the workspace `w`.

`clearvars(w)` clears *all* variables from the workspace `w`.

| Name | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `w`:arrow_right: | workspace | `docer.Workspace` | yes |
| `n`:arrow_right: | variable name(s) | string(s) | |

### Loading and saving

`save(w,f)` saves *all* variables in the workspace `w` to the file `f`.

`save(w,f,n1,n2,...)` saves the variables `n1`, `n2`, etc. in the workspace `w` to the file `f`.

`load(w,f)` loads *all* variables from the file `f` into the workspace `w`.

`load(w,f,n1,n2,...)` loads the variables `n1`, `n2`, etc. from the file `f` into the workspace `w`.

| Name | Description | Type | Required |
| :-: | --- | :-: | :-: |
| `w`:arrow_right: | workspace | `docer.Workspace` | yes |
| `f`:arrow_right: | filename | string | yes |
| `n`:arrow_right: | variable name(s) | string(s) | |

## Examples

### Creation, evaluation, and assignment

Create a workspace, assign some variables, and evaluate an expression:

```matlab
w = docer.Workspace("a",2,"b",3);
evalin(w,"c=a+b;")
w
```

Evaluate an expression without capturing the output:

```matlab
evalin(w,"d=a*b+c")
```

Here, the variable `d` is in `w`, and is shown in the output because the statement `d=a*b+c` is not terminated.

Evaluate an expression *in* the workspace and assign the result to a variable:

```matlab
x = evalin(w,"a*b+c")
```

Here, the variable `x` is *not* in `w`, it is in the *caller* workspace.

You can also *capture* the output using `evalinc`, and return it to the caller.

```matlab
evalinc(w,"e=a+b*c")
```

### Loading and saving

Create a workspace, and assign some variables:

```matlab
w1 = docer.Workspace("a",-1,"b","mickey")
```

Save the workspace contents to a `.mat` file:

```matlab
f = tempname() + ".mat";
save(w1,f)
```

Create a second workspace, and assign some variables:

```matlab
w2 = docer.Workspace("b",2,"c","pluto")
```

Load the contents of the first workspace into the second:

```matlab
load(w2,f)
w2
```

## Details

`docer.Workspace` extends [`assignin`](https://www.mathworks.com/help/matlab/ref/assignin.html) and [`evalin`](https://www.mathworks.com/help/matlab/ref/evalin.html) from `base` and `caller` to workspace *objects*.

`docer.Workspace` also adds `evalinc` -- "`evalin` with capture".  `evalin` is to `evalinc` as [`eval`](https://www.mathworks.com/help/matlab/ref/eval.html) is to [`evalc`](https://www.mathworks.com/help/matlab/ref/evalc.html).

`docer.Workspace` was previously a standalone implementation, first implemented 20 years ago, but now uses `matlab.lang.internal.WorkspaceData` :heart:.

___

[home](index.md) :house: | [convert](docerconvert.md) :arrow_right: | [run](docerrun.md) :runner: | [index](docerindex.md) :scroll: | [delete](docerdelete.md) :recycle: | [workspace](workspace.md) :construction_worker: | [about](about.md) :hippopotamus: | :copyright: [MathWorks](https://www.mathworks.com/services/consulting.html) 2024