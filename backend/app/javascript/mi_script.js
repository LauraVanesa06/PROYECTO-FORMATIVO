window.addEventListener('DOMContentLoaded', () => {
    const navbar = document.querySelector('.navbar');
    const links = document.querySelector('.navbar-links');

    let logo = null;

    window.addEventListener('scroll', () => {
        const rect = navbar.getBoundingClientRect();

        if (rect.top <= 1 && !logo) {
            const template = document.querySelector('.header-logo2');
            logo = template.cloneNode(true); 
            logo.style.display = 'flex';
            logo.classList.add('fade-in');
            links.insertBefore(logo, links.firstChild);
        } else if (rect.top > 1 && logo) {
            logo.classList.remove('fade-in');
            logo.classList.add('fade-out');

            logo.addEventListener('animationend', () => {
            if (logo && logo.parentElement === links) {
                links.removeChild(logo);
                logo = null;
            }
            }, { once: true });
        }
    });

})