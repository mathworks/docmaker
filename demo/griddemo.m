f = figure();
g = uix.Grid('Parent',f,'Padding',5,'Spacing',5);
uicontrol('Parent',g,'Background','r')
uicontrol('Parent',g,'Background','b')
uicontrol('Parent',g,'Background','g')
uix.Empty('Parent',g);
uicontrol('Parent',g,'Background','c')
uicontrol('Parent',g,'Background','y')
set(g,'Widths',[-1 100 -2],'Heights',[-1 100])