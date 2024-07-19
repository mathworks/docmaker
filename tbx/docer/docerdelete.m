function docerdelete( pRoot )
%docerdelete  Delete Doc'er artifacts
%
%  docerdelete(d) deletes the Doc'er artifacts in the folder d:
%  * HTML documents corresponding to Markdown documents
%  * image files corresponding to MATLAB scripts
%  * the resources subfolder, "resources"
%  * the index files, "info.xml" and "helptoc.xml"
%  * the search database subfolder, "helpsearch-v4"
%
%  See also: docerconvert, docerrun, docerindex

%  Copyright 2020-2024 The MathWorks, Inc.

% Check inputs
arguments
    pRoot (1,1) string {mustBeFolder}
end

% Delete HTML files corresponding to Markdown files
sMd = dir( fullfile( pRoot, '**', '*.md' ) ); % Markdown
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

% Delete JSON files
nJson = "custom_toolbox.json"; % names
sJson = dirstruct( fullfile( pRoot, nJson ) ); % jsons
for ii = 1:numel( sJson ) % loop
    fJson = fullfile( sJson(ii).folder, sJson(ii).name ); % this json
    if isfile( fJson )
        delete( fJson ) % delete
        fprintf( 1, '[-] %s\n', fJson ); % echo
    end
end

% Delete resources folder
sRoot = dirstruct( pRoot );
fRez = fullfile( sRoot(1).folder, "resources" ); % folder
if isfolder( fRez )
    rmdir( fRez, "s" ) % delete
    fprintf( 1, "[-] %s\n", fRez ); % echo
end

% Delete helpsearch folders
sHelp = dirstruct( fullfile( pRoot, "helpsearch-v*" ) ); % indices
for ii = 1:numel( sHelp ) % loop
    if sHelp(ii).isdir
        fHelp = fullfile( sHelp(ii).folder, sHelp(ii).name ); % this index
        rmdir( fHelp, "s" ) % delete
        fprintf( 1, "[-] %s\n", fHelp ); % echo
    end
end

end % docerdelete