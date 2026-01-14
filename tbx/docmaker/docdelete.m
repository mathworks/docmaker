function varargout = docdelete( pRoot )
%docdelete  Delete generated artifacts
%
%   docdelete(d) deletes the generated artifacts in the folder d:
%   * HTML documents corresponding to Markdown documents
%   * the resources subfolder, "resources"
%   * the index files, "info.xml" and "helptoc.xml"
%   * the search database subfolder, "helpsearch-v4"
%
%   [files,folders] = docdelete(...) returns the names of the files and
%   folders deleted.
%
%   See also: docconvert, docrun, docindex

%   Copyright 2024-2026 The MathWorks, Inc.

arguments
    pRoot (1,1) string {mustBeFolder}
end

% Initialize output
oFiles = strings( 0, 1 );
oFolders = strings( 0, 1 );

% Delete HTML documents corresponding to Markdown documents
sMd = dir( fullfile( pRoot, '**', '*.md' ) ); % Markdown
for ii = 1:numel( sMd ) % loop
    fMd = fullfile( sMd(ii).folder, sMd(ii).name ); % this Markdown
    [pMd, nMd, ~] = fileparts( fMd ); % path and name
    fHtml = fullfile( pMd, nMd + ".html" ); % this HTML
    if isfile( fHtml ) % corresponding
        delete( fHtml ) % delete
        fprintf( 1, '[-] %s\n', fHtml ); % echo
        oFiles(end+1,:) = fHtml; %#ok<AGROW>
    end
end

% Delete XML files
nXml = ["info.xml" "helptoc.xml" "helpindex.xml"]; % names
sXml = docmaker.dir( fullfile( pRoot, nXml ) ); % xmls
for ii = 1:numel( sXml ) % loop
    fXml = fullfile( sXml(ii).folder, sXml(ii).name ); % this xml
    if isfile( fXml )
        delete( fXml ) % delete
        fprintf( 1, '[-] %s\n', fXml ); % echo
        oFiles(end+1,:) = fXml; %#ok<AGROW>
    end
end

% Delete JSON files
nJson = "custom_toolbox.json"; % names
sJson = docmaker.dir( fullfile( pRoot, nJson ) ); % jsons
for ii = 1:numel( sJson ) % loop
    fJson = fullfile( sJson(ii).folder, sJson(ii).name ); % this json
    if isfile( fJson )
        delete( fJson ) % delete
        fprintf( 1, '[-] %s\n', fJson ); % echo
        oFiles(end+1,:) = fJson; %#ok<AGROW>
    end
end

% Delete resources folder
sRoot = docmaker.dir( pRoot );
fRez = fullfile( sRoot(1).folder, "resources" ); % folder
if isfolder( fRez )
    rmdir( fRez, "s" ) % delete
    fprintf( 1, "[-] %s\n", fRez ); % echo
    oFolders(end+1,:) = fRez;
end

% Delete helpsearch folders
sHelp = docmaker.dir( fullfile( pRoot, "helpsearch-v*" ) ); % indices
for ii = 1:numel( sHelp ) % loop
    if sHelp(ii).isdir
        fHelp = fullfile( sHelp(ii).folder, sHelp(ii).name ); % this index
        rmdir( fHelp, "s" ) % delete
        fprintf( 1, "[-] %s\n", fHelp ); % echo
        oFolders(end+1,:) = fHelp; %#ok<AGROW>
    end
end

% Return outputs
if nargout > 0
    varargout{1} = oFiles;
    varargout{2} = oFolders;
end

end % docdelete