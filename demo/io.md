# MATLAB live documents

## Random numbers

MATLAB can generate random numbers.

```matlab
randi(10,[1 5])
```

## String parsing

MATLAB can also parse strings.

```matlab
s = "The rain in Spain falls mainly on the plain";
w = split( s )
```

And MATLAB can plot surfaces.
```matlab
f = figure();
a = axes("Parent",f);
[x,y] = meshgrid(-1:0.1:3);
z = peaks(x,y);
surf(a,x,y,z)
```

# Foobar

## See also
:house:

This block will not be executed because it ends with whitespace:

```matlab
rand(5,5)
x = 0:0.1:10
plot(x,sin(x)) 
```

Here is the same block without the whitespace:

```matlab
rand(5,5)
x = 0:0.1:10
plot(x,sin(x))
```

```matlab
why
```