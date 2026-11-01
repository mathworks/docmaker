/*
 * Project-owned configuration shim for compiling cmark-gfm sources directly
 * with MATLAB mex. Upstream CMake normally generates this header from
 * ext/cmark-gfm/src/config.h.in; these definitions encode the feature
 * assumptions and compiler conditionals used by this project.
 */
#ifndef CMARK_CONFIG_H
#define CMARK_CONFIG_H
#define HAVE_STDBOOL_H 1
#include <stdbool.h>
#if defined(__GNUC__) || defined(__clang__)
#define HAVE___ATTRIBUTE__ 1
#define CMARK_ATTRIBUTE(list) __attribute__ (list)
#else
#define CMARK_ATTRIBUTE(list)
#endif
#ifndef CMARK_INLINE
#if defined(_MSC_VER) && !defined(__cplusplus)
#define CMARK_INLINE __inline
#else
#define CMARK_INLINE inline
#endif
#endif
#endif
