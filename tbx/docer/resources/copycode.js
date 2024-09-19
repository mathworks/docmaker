document.querySelectorAll('.highlight-source-matlab pre button').forEach(button => {
    pre = button.parentNode;
    button.addEventListener('click', async () => {
        try {
            const originalText = button.textContent;
            await navigator.clipboard.writeText(button.textContent.trim());
            button.classList.toggle('checked');
            setTimeout(() => {
                button.classList.toggle('checked');
            }, 1000);

        } catch (err) {
            console.error('Failed to copy: ', err);
        }
    });
});
