document.querySelectorAll('pre').forEach(pre => {
    // Check if the <pre> element has an ancestor with the class 'highlight-output'
    if (pre.closest('.highlight-output')) { 
        return; // skip
    }

    // Create a new button element
    const button = document.createElement('button');
    button.className = 'copy-button'; // assign class for styling
    button.setAttribute('aria-label', 'Copy code to clipboard'); // accessibility label for screen readers

    // Set the inner HTML of the button to include an SVG icon
    button.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="copy-button-icon">
            <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
            <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
        </svg>
    `;

    // Set up the onclick event handler for the button
    button.onclick = function () {
        docerCopyCode(pre, button);
    };

    // Append the button to the <pre> element
    pre.appendChild(button);
});

function docerCopyCode(pre, button) {
    // Extract the full text content from the <pre> element
    let code = pre.textContent;

    // Trim trailing spaces from each line and remove extra whitespace at the end
    code = code.split('\n')
        .map(line => line.replace(/\s+$/, ''))
        .join('\n')
        .trim();

    navigator.clipboard.writeText(code).then(() => {
        const originalIcon = button.innerHTML;
        button.innerHTML = '&#10003;'; // Unicode check mark
        setTimeout(() => {
            button.innerHTML = originalIcon;
        }, 1000);
    }).catch(err => {
        console.error('Error copying text: ', err);
    });
}