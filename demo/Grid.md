# :symbols: uix.Grid, uix.GridFlex

Arrange contents in a grid

## Description

`uix.Grid` arranges contents in a grid.

The number of rows and columns are *dynamic* with the number of contents:
* Changing the number of rows may change the number of columns, and vice versa.
* Adding and removing contents may increase and decrease the number of columns.

Contents are laid out dynamically, top-to-bottom then left-to-right.  To interleave empty space, use [`uix.Empty`](Empty.md).

Row heights and column widths can be fixed or variable, with minima.  Variable-sized rows and columns fill available container space, subject to minima, accoring to specified weights.

`uix.GridFlex` extends `uix.Grid`, adding draggable dividers between the rows and columns.

## Syntax

`g = uix.Grid()` creates a new, default, *unparented* grid.

`g = uix.Grid(p1,v1,...)` also sets one or more property values.

`g = uix.GridFlex(...)` creates a new flexible grid.

## Properties

| Property | Value | Description |
| --- | --- | --- |
| `BackgroundColor` | [color](https://uk.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) | Background color |
| `Contents` | graphics vector | Children, in layout order (top-to-bottom, then left-to-right), regardless of `HandleVisibility` |
| `Heights` | double vector | Row heights; positive entries denote fixed sizes in pixels; negative entries denote weights for variable sizing |
| `Padding` | positive integer | Space around contents, in pixels |
| `Parent` | figure, panel, [etc.](https://uk.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) | Parent figure or container |
| `Position` | `[left bottom width height]` | Position within parent figure or container, in `Units` |
| `Spacing` | positive integer | Space between rows and columns, in pixels |
| `Units` | `normalized`, `pixels`, [etc.](https://uk.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#bub8wap-1_sep_shared-Position) | Position units; default is `normalized` |
| `Visible` | `on` or `off` | Visibility; default is `on` |
| `Widths` | double vector | Column widths; positive entries denote fixed sizes in pixels; negative entries denote weights for variable sizing |

plus other [container properties](https://uk.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

### :warning: Deprecated

| Property | Value | Alternative | Notes |
| --- | --- | --- | --- |
| `FontName` | string | none | Not supportable in a `uitab`-backed implementation; removed in version 2.4 |
| `Widths` | double vector | `Width` | Was one entry per child; now one entry for all |

## Examples

```matlab
f = figure();
g = uix.Grid('Parent',f,'Padding',5,'Spacing',5);
uicontrol('Parent',g,'Background','r')
uicontrol('Parent',g,'Background','b')
uicontrol('Parent',g,'Background','g')
uix.Empty('Parent',g);
uicontrol('Parent',g,'Background','c')
uicontrol('Parent',g,'Background','y')
set(g,'Widths',[-1 100 -2],'Heights',[-1 100])
```

![Output](griddemo1.png)

## See also

:house: | :arrow_right: [HBox](hbox.md) | :arrow_down: [VBox](vbox.md) | :symbols: [Grid](grid.md) | :card_index: [CardPanel](CardPanel.md) | :point_right: [TabPanel](TabPanel.md) | :scroll: [ScrollingPanel](ScrollingPanel.md) | :white_square_button: [BoxPanel](BoxPanel.md) | :vertical_traffic_light: [VButtonBox](VButtonBox.md) | :traffic_light: [HButtonBox](VButtonBox.md)

:copyright: 2009-2024 [The MathWorks, Inc.](https://www.mathworks.com/services/consulting.html)