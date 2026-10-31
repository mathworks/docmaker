/*
 * Thin MATLAB MEX gateway for cmark-gfm.
 *
 * cmark-gfm remains an unmodified BSD-2-Clause licensed submodule in
 * vendor/cmark-gfm. This file contains only project-owned integration code.
 */

#include "mex.h"

#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "cmark-gfm.h"
#include "cmark-gfm-core-extensions.h"

char *cmark_gfm_expand_emojis(const char *markdown, size_t length,
    size_t *expanded_length);

static int is_scalar_text(const mxArray *value)
{
    if (mxIsClass(value, "string")) {
        return mxIsScalar(value);
    }
    if (mxIsChar(value)) {
        return mxGetNumberOfElements(value) == 0 ||
            mxGetM(value) == 1 || mxGetN(value) == 1;
    }
    return 0;
}

static char *input_as_utf8(const mxArray *input, mxArray **temporary_char)
{
    const mxArray *char_input = input;

    *temporary_char = NULL;
    if (mxIsClass(input, "string")) {
        if (mexCallMATLAB(1, temporary_char, 1, (mxArray **)&input, "char") != 0) {
            mexErrMsgIdAndTxt("cmarkgfm2html:ConversionFailed",
                "Unable to convert the MATLAB string input to a character vector.");
        }
        char_input = *temporary_char;
    }

    return mxArrayToUTF8String(char_input);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    char *markdown;
    char *expanded_markdown;
    char *html;
    mxArray *html_char;
    mxArray *temporary_char;
    size_t expanded_length;
    cmark_parser *parser;
    cmark_node *document;
    cmark_syntax_extension *extension;
    static const char *extension_names[] = {
        "table", "strikethrough", "autolink", "tasklist"
    };
    size_t i;
    int input_is_string;

    if (nrhs != 1) {
        mexErrMsgIdAndTxt("cmarkgfm2html:InvalidNumInputs",
            "cmarkgfm2html requires exactly one input.");
    }
    if (nlhs > 1) {
        mexErrMsgIdAndTxt("cmarkgfm2html:InvalidNumOutputs",
            "cmarkgfm2html returns exactly one output.");
    }
    if (!is_scalar_text(prhs[0])) {
        mexErrMsgIdAndTxt("cmarkgfm2html:InvalidInput",
            "Input must be a scalar MATLAB string or character vector.");
    }
    input_is_string = mxIsClass(prhs[0], "string");

    markdown = input_as_utf8(prhs[0], &temporary_char);
    if (markdown == NULL) {
        if (temporary_char != NULL) {
            mxDestroyArray(temporary_char);
        }
        mexErrMsgIdAndTxt("cmarkgfm2html:ConversionFailed",
            "Unable to convert the Markdown input to UTF-8.");
    }

    expanded_markdown = cmark_gfm_expand_emojis(markdown, strlen(markdown),
        &expanded_length);
    mxFree(markdown);
    if (temporary_char != NULL) {
        mxDestroyArray(temporary_char);
    }
    if (expanded_markdown == NULL) {
        mexErrMsgIdAndTxt("cmarkgfm2html:AllocationFailed",
            "Unable to expand Markdown emoji shortcodes.");
    }

    cmark_gfm_core_extensions_ensure_registered();
    parser = cmark_parser_new(CMARK_OPT_DEFAULT);
    if (parser == NULL) {
        free(expanded_markdown);
        mexErrMsgIdAndTxt("cmarkgfm2html:AllocationFailed",
            "Unable to allocate a cmark-gfm parser.");
    }

    for (i = 0; i < sizeof(extension_names) / sizeof(extension_names[0]); ++i) {
        extension = cmark_find_syntax_extension(extension_names[i]);
        if (extension == NULL || !cmark_parser_attach_syntax_extension(parser, extension)) {
            cmark_parser_free(parser);
            free(expanded_markdown);
            mexErrMsgIdAndTxt("cmarkgfm2html:ExtensionUnavailable",
                "Unable to enable the requested cmark-gfm extension.");
        }
    }

    cmark_parser_feed(parser, expanded_markdown, expanded_length);
    document = cmark_parser_finish(parser);
    free(expanded_markdown);

    if (document == NULL) {
        cmark_parser_free(parser);
        mexErrMsgIdAndTxt("cmarkgfm2html:ParseFailed",
            "cmark-gfm was unable to parse the Markdown input.");
    }

    html = cmark_render_html(document, CMARK_OPT_DEFAULT,
        cmark_parser_get_syntax_extensions(parser));
    cmark_parser_free(parser);
    cmark_node_free(document);
    if (html == NULL) {
        mexErrMsgIdAndTxt("cmarkgfm2html:RenderFailed",
            "cmark-gfm was unable to render HTML.");
    }

    html_char = mxCreateString(html);
    free(html);
    if (html_char == NULL) {
        mexErrMsgIdAndTxt("cmarkgfm2html:AllocationFailed",
            "Unable to allocate the MATLAB HTML output.");
    }

    if (!input_is_string) {
        plhs[0] = html_char;
        return;
    }

    plhs[0] = NULL;
    if (mexCallMATLAB(1, &plhs[0], 1, &html_char, "string") != 0) {
        mxDestroyArray(html_char);
        if (plhs[0] != NULL) {
            mxDestroyArray(plhs[0]);
            plhs[0] = NULL;
        }
        mexErrMsgIdAndTxt("cmarkgfm2html:ConversionFailed",
            "Unable to convert the HTML output to a MATLAB string.");
    }
    mxDestroyArray(html_char);
    if (plhs[0] == NULL) {
        mexErrMsgIdAndTxt("cmarkgfm2html:AllocationFailed",
            "Unable to allocate the MATLAB string output.");
    }
}
