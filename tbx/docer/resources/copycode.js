document.querySelectorAll('.highlight-source-matlab pre').forEach(pre => {
    const button = document.createElement('button');
    button.className = 'copy-button';
    button.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="copy-button-icon">
            <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
            <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
        </svg>
    `;

    button.onclick = function() {
        docerCopyCode(pre, button);
    };

    pre.appendChild(button);
});

function docerCopyCode(pre, button) {
    const code = pre.textContent;
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