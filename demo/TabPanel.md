# :point_right: `uix.TabPanel`

Arrange contents in a panel with tabs for selecting which is visible

## Description

`uix.TabPanel` arranges contents in a panel with tabs for selecting which is visible.

The number of rows and columns are *dynamic* with the number of contents:
* Changing the number of rows may change the number of columns, and vice versa.
* Adding and removing contents may increase and decrease the number of columns.

Contents are laid out dynamically, top-to-bottom then left-to-right.  To interleave empty space, use [`uix.Empty`](Empty.md).

Row heights and column widths can be fixed or variable, with minima.  Variable-sized rows and columns fill available container space, subject to minima, accoring to specified weights.

`uix.GridFlex` extends `uix.Grid`, adding draggable dividers between the rows and columns.

## Syntax

`g = uix.TabPanel()` creates a new, default, *unparented* tab panel.

`g = uix.TabPanel(p1,v1,...)` also sets one or more property values.

## Properties

| Property | Value | Description |
| --- | --- | --- |
| `BackgroundColor` | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) | Background color |
| `Contents` | graphics vector | Children, in layout order (top-to-bottom, then left-to-right), regardless of `HandleVisibility` |
| `Heights` | double vector | Row heights; positive entries denote fixed sizes in pixels; negative entries denote weights for variable sizing |
| `Padding` | positive integer | Space around contents, in pixels |
| `Parent` | figure, panel, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#mw_e4809363-1f35-4bc7-89f8-36ed9cccb017) | Parent figure or container |
| `Position` | `[left bottom width height]` | Position within parent figure or container, in `Units` |
| `Spacing` | positive integer | Space between rows and columns, in pixels |
| `Units` | `normalized`, `pixels`, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html#bub8wap-1_sep_shared-Position) | Position units; default is `normalized` |
| `Visible` | `on` or `off` | Visibility; default is `on` |
| `Widths` | double vector | Column widths; positive entries denote fixed sizes in pixels; negative entries denote weights for variable sizing |

plus other [container properties](https://www.mathworks.com/help/matlab/ref/matlab.ui.container.panel-properties.html):
* Interactivity: `ContextMenu`
* Callbacks: `SizeChangedFcn`, `ButtonDownFcn`, `CreateFcn`, `DeleteFcn`
* Callback execution control: `Interruptible`, `BusyAction`, `BeingDeleted`, `HitTest`
* Parent/child: `Children`, `HandleVisibility`
* Identifiers: `Type`, `Tag`, `UserData`

### :warning: Deprecated

| Property | Value | Description | Recommendation |
| --- | --- | --- | --- |
| `FontAngle` | `normal` or `italic` | Tab title font angle | `normal`, as per `uitab`, from version 2.4 |
| `FontName` | string | Tab title font name | `MS Sans Serif`, as per `uitab`, from version 2.4 |
| `FontSize` | positive integer | Tab title font size, in `FontUnits` | Not supportable in a `uitab`-backed implementation; removed in version 2.4 |
| `FontUnits` | `points`, `pixels`, [etc.](https://www.mathworks.com/help/matlab/ref/matlab.ui.control.uicontrol-properties.html#bt6ck7c-1_sep_shared-FontUnits) | Tab title font units | Not supportable in a `uitab`-backed implementation; removed in version 2.4 |
| `FontWeight` | `normal` or `bold` | Tab title font weight | Not supportable in a `uitab`-backed implementation; removed in version 2.4 |
| `HighlightColor` | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) | Border highlight color | Was one entry per child; now one entry for all |
| `ShadowColor` | [color](https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html) | Border shadow color | Was one entry per child; now one entry for all |
| `TabWidth` | double | Tab width, in pixels | Was one entry per child; now one entry for all |

## Examples

```matlab
f = figure();
p = uix.TabPanel('Parent',f,'Padding',5);
uicontrol('Parent',p,'Background','r');
uicontrol('Parent',p,'Background','b');
uicontrol('Parent',p,'Background','g');
p.TabTitles = {'Red','Blue','Green'};
p.Selection = 2;
```

![Output](tabpaneldemo1.png)

## See also

[:house:](index.md) | :arrow_right: [HBox](hbox.md) | :arrow_down: [VBox](vbox.md) | :symbols: [Grid](grid.md) | :card_index: [CardPanel](CardPanel.md) | :point_right: [TabPanel](TabPanel.md) | :scroll: [ScrollingPanel](ScrollingPanel.md) | :white_square_button: [BoxPanel](BoxPanel.md) | :vertical_traffic_light: [VButtonBox](VButtonBox.md) | :traffic_light: [HButtonBox](VButtonBox.md)

:copyright: 2009-2024 [The MathWorks, Inc.](https://www.mathworks.com/services/consulting.html)