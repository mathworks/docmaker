function plan = buildfile()
%buildfile  Doc'er buildfile

%  Copyright 2023-2024 The MathWorks, Inc.

import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask

% Create a plan from task functions
plan = buildplan( localfunctions() );

% Add a task to identify code issues
plan( "check" ) = CodeIssuesTask();

% Add a task to run tests
plan( "test" ) = TestTask();

% Set up task dependencies
plan( "package" ).Dependencies = ["check" "test" "doc"];

% Set default task
plan.DefaultTasks = "package";

end % buildfile

function docTask( ~ )
%docTask  Generate documentation

doc = fullfile( fileparts( mfilename( "fullpath" ) ), "tbx", "docerdoc" );
docerdelete( doc )
docerconvert( fullfile( doc, "**/*.md" ) )
docerindex( doc )

end % docTask

function packageTask( ~ )
%packageTask  Package toolbox

docerrelease()

end % packageTask