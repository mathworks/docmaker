/*
 * Project-owned export shim for the MEX's static cmark-gfm build.
 * Upstream CMake normally generates this header with GenerateExportHeader;
 * the MEX does not need shared-library export annotations.
 */
#ifndef CMARK_GFM_EXPORT_H
#define CMARK_GFM_EXPORT_H
#define CMARK_GFM_EXPORT
#endif
