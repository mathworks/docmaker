document.querySelectorAll('.highlight-source-matlab').forEach(div => {
    const button = div.querySelector('.copy');
    const pre = div.querySelector('pre');
    console.log(button)
    button.addEventListener('click', async () => {
        try {
            const originalText = button.textContent;
            await navigator.clipboard.writeText(pre.textContent.trim());
            button.textContent = '✔'; // Set to a check mark
            setTimeout(() => {
                button.textContent = originalText;
            }, 1000);

        } catch (err) {
            console.error('Failed to copy: ', err);
        }
    });
});
