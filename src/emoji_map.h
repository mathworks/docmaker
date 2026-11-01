/*
 * Project-owned interface for the generated emoji lookup table.
 * buildfile.m generates its implementation in build/cmark-gfm/emoji_map.c
 * from ext/gemoji/db/emoji.json.
 */
#ifndef CMARK_GFM_EMOJI_MAP_H
#define CMARK_GFM_EMOJI_MAP_H
#include <stddef.h>
const char *cmark_gfm_emoji_lookup(const char *alias, size_t length);
#endif
