document.querySelectorAll('.highlight-source-matlab pre').forEach(pre => {
    const button = document.createElement('button');
    button.className = 'copy-button';
    pre.appendChild(button);
    button.addEventListener('click', async () => {
        try {
            await navigator.clipboard.writeText(pre.textContent.trim());
            button.classList.add('checked');
            setTimeout(() => {
                button.classList.remove('checked');
            }, 1000);
        } catch (err) {
            console.error('Failed to copy: ', err);
        }
    });
});