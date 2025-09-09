# docmaker.Workspace :astronaut:

Workspace

## Syntax

### Creation

`w = docmaker.Workspace()` creates a new, empty workspace `w`.

### Assignment and evaluation

`assignin(w,n,v)` assigns the variable `n` to value `v` in the workspace `w`.

`assignin(w,n1,v1,n2,v2,...)` assigns variable `n1` to value `v1`, variable `n2` to value `v2`, etc. in the workspace `w`.

`evalin(w,b)` evaluates the code block `b` in the workspace `w`.

`[o1,o2,...] = evalin(w,s)` evaluates the statement `s` in the workspace `w`, and returns the outputs `o1`, `o2`, etc.

`c = evalinc(w,b)` evaluates the code block `b` in the workspace `w`, and returns the command window output `c`.

`[c,o1,o2,...] = evalinc(w,s)` evaluates the statement `s` in the workspace `w`, and returns the outputs `o1`, `o2`, etc. and the command window output `c`.

`clearvars(w,n1,n2,...)` clears the variables `n1`, `n2`, etc. from the workspace `w`.

### Loading and saving

`save(w,f)` saves *all* variables in the workspace `w` to the file `f`.

`save(w,f,n1,n2,...)` saves the variables `n1`, `n2`, etc. in the workspace `w` to the file `f`.

`load(w,f)` loads *all* variables from the file `f` into the workspace `w`.

`load(w,f,n1,n2,...)` loads the variables `n1`, `n2`, etc. from the file `f` into the workspace `w`.





## Description

## Examples

Create a workspace, assign some variables, and evaluate an expression:

```matlab
w = docmaker.Workspace();
assignin(w,"a",2,"b",3)
evalin(w,"c=a+b;")
w
```

### Capturing output

Evaluate an expression without capturing the output:

```matlab
evalin(w,"d=a*b+c")
```

Evaluate an expression *in* the workspace and assign the result to a variable in the *caller*:

```matlab
x = evalin(w,"a*b+c")
```

Capture the output and it is returned to the caller:

```matlab
evalinc(w,"e=a+b*c")
```

### Loading and saving

There is nothing special about the `.mat` files that `docmaker.Workspace` can load and save.  Let's save a `.mat` file from the *base* workspace and load it to a workspace *object*:

```matlab
clear
a = -1; b = "mickey"; % data in base
save data.mat % save from base to .mat
w = docmaker.Workspace(); % create new workspace
assignin(w,"b",-3,"c","pluto"); % data in workspace
load(w,"data.mat") % load from .mat to workspace
w
delete("data.mat") % clean up
```