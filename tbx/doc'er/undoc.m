function undoc( pRoot )
%undoc  Unpublish Markdown files
%
%  undoc(f) unpublishes the documentation in the folder f by deleting:
%  * HTML files corresponding to Markdown files
%  * PNG files corresponding to MATLAB scripts
%  * the resources folder, <f>/resources
%
%  See also: docpages, docdemos

%  Copyright 2020-2024 The MathWorks, Inc.

% Check inputs
arguments
    pRoot (1,1) string {mustBeFolder}
end

% Delete HTML files corresponding to Markdown files
sMd = dir( fullfile( pRoot, '**', '*.md' ) ); % Markdown files
for ii = 1:numel( sMd ) % loop
    fMd = fullfile( sMd(ii).folder, sMd(ii).name ); % this Markdown
    [pMd, nMd, ~] = fileparts( fMd ); % path and name
    fHtml = fullfile( pMd, nMd + ".html" ); % this HTML
    if exist( fHtml, "file" ) % corresponding
        delete( fHtml ) % delete
        fprintf( 1, '[-] %s\n', fHtml ); % echo
    end
end

% Delete PNG files corresponding to MATLAB scripts
sM = dir( fullfile( pRoot, '**', '*.m' ) ); % MATLAB scripts
for ii = 1:numel( sM ) % loop
    fM = fullfile( sM(ii).folder, sM(ii).name ); % this script
    [pM, nM, ~] = fileparts( fM ); % path and name
    for jj = 1:1e2
        fPng = fullfile( pM, nM + string( jj ) + ".png" ); % this PNG
        if exist( fPng, "file" ) % corresponding
            delete( fPng ) % delete
            fprintf( 1, '[-] %s\n', fPng ); % echo
        else
            break % not found, next script
        end
    end
end

% Delete helptoc.xml
sHelp = dir( fullfile( pRoot, 'helptoc.xml' ) ); % helptoc
for ii = 1:numel( sHelp ) % loop
    fHelp = fullfile( sHelp(ii).folder, sHelp(ii).name ); % one-and-only
    if exist( fHtml, "file" )
        delete( fHelp ) % delete
        fprintf( 1, '[-] %s\n', fHelp ); % echo
    end
end

% Delete resources folder
sRes = dir( fullfile( pRoot, 'resources' ) ); % resources folder
for ii = 1:numel( sRes ) % loop
    if sRes(ii).name == "." && sRes(ii).isdir == true % match
        fRes = sRes(ii).folder; % absolute path
        rmdir( fRes, "s" ) % delete
        fprintf( 1, "[-] %s\n", fRes ); % echo
        break % only one
    end
end

end % undoc