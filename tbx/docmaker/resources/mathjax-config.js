// MathJax configuration
window.MathJax = {
    tex: {
        inlineMath: [['$', '$'], ['\\(', '\\)']],
        displayMath: [['$$', '$$'], ['\\[', '\\]']]
    }
};

// Dynamically load MathJax
(function () {
    const script = document.createElement('script');
    script.src = "mathjax.js";
    script.async = true;
    document.head.appendChild(script);
})();