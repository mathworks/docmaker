// MathJax configuration
//
// Copyright 2026 The MathWorks, Inc.
window.MathJax = {
    tex: {
        inlineMath: [['$', '$']],
        displayMath: [['$$', '$$']]
    }
};

// Dynamically load MathJax
(function () {
    const script = document.createElement('script');    
    script.src = "tex-mml-chtml.js";
    script.async = true;
    document.head.appendChild(script);
})();
