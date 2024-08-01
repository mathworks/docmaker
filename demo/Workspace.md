# docer.Workspace :astronaut:

Workspace

## Syntax

`w = docer.Workspace()`

`assignin(w,n,v)`

`assignin(w,n1,v1,n2,v2,...)`

`evalin(w,s)`

`c = evalinc(w,b)`

`[c,o1,o2,...] = evalinc(w,s)`





## Description

## Examples

Create a workspace, assign some variables, and evaluate an expression:

```matlab
w = docer.Workspace();
assignin(w,"a",2,"b",3)
evalin(w,"c=a+b;")
w
```

### Capturing output

Evaluate an expression without capturing the output:

```matlab
evalin(w,"d=a*b+c")
```

Capture the output and it is returned to the caller:

```matlab
evalinc(w,"e=a+b*c")
```

### Loading and saving

Assign the result of an expression *in* the workspace to a variable in the *caller*:

```matlab
x = evalin(w,"a*b+c")
```




There is nothing special about the `.mat` files that `docer.Workspace` can load and save.  Let's save a `.mat` file from the *base* workspace and load it to a workspace *object*:

```matlab
clear
a = -1; b = "mickey"; % data in base
save data.mat % save from base to .mat
w = docer.Workspace(); % create new workspace
assignin(w,"b",-3,"c","pluto"); % data in workspace
load(w,"data.mat") % load from .mat to workspace
delete("data.mat")
w
```