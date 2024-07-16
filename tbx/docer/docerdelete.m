function docerdelete( pRoot )
%docerdelete  Delete Doc'er artifacts
%
%  docerdelete(d) deletes the Doc'er artifacts in the folder d:
%  * HTML files corresponding to Markdown files
%  * PNG files corresponding to MATLAB scripts
%  * the index files, <f>/info.xml, <f>/helptoc.xml, <f>/helpindex.xml
%  * the resources folder, <f>/resources
%  * the search database, <f>/helpsearch-v*
%
%  See also: docerconvert, docerrun, docerindex

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
    if isfile( fHtml ) % corresponding
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
        if isfile( fPng ) % corresponding
            delete( fPng ) % delete
            fprintf( 1, '[-] %s\n', fPng ); % echo
        else
            break % not found, next script
        end
    end
end

% Delete XML files
nXml = ["info.xml" "helptoc.xml" "helpindex.xml"]; % names
sXml = dirstruct( fullfile( pRoot, nXml ) ); % xmls
for ii = 1:numel( sXml ) % loop
    fXml = fullfile( sXml(ii).folder, sXml(ii).name ); % this xml
    if isfile( fXml )
        delete( fXml ) % delete
        fprintf( 1, '[-] %s\n', fXml ); % echo
    end
end

% Delete resources and helpsearch folders
sRoot = dirstruct( pRoot );
sRoot([sRoot.isdir] == false) = []; % remove non-directories
for ii = 1:numel( sRoot )
    nRoot = sRoot(ii).name;
    fRoot = fullfile( sRoot(ii).folder, nRoot );
    if nRoot == "resources" || startsWith( nRoot, "helpsearch-v" )
        rmdir( fRoot, "s" ) % delete
        fprintf( 1, "[-] %s\n", fRoot ); % echo
    end
end

end % docerdelete