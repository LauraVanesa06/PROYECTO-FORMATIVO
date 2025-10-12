// ===== MODERN S.E.I.E JAVASCRIPT =====

document.addEventListener('DOMContentLoaded', function() {
    // ===== SMOOTH SCROLLING =====
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // ===== NAVBAR SCROLL EFFECT =====
    const navbar = document.querySelector('.modern-nav');
    if (navbar) {
        window.addEventListener('scroll', function() {
            if (window.scrollY > 50) {
                navbar.style.background = 'rgba(15, 15, 35, 0.98)';
                navbar.style.backdropFilter = 'blur(30px)';
            } else {
                navbar.style.background = 'rgba(15, 15, 35, 0.95)';
                navbar.style.backdropFilter = 'blur(20px)';
            }
        });
    }

    // ===== ANIMATED ELEMENTS ON SCROLL =====
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Animar elementos al hacer scroll
    document.querySelectorAll('.section').forEach(section => {
        section.style.opacity = '0';
        section.style.transform = 'translateY(30px)';
        section.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(section);
    });

    // ===== HERO BUTTON INTERACTION =====
    const heroButton = document.querySelector('.hero-cta');
    if (heroButton) {
        heroButton.addEventListener('click', function() {
            const aboutSection = document.querySelector('#about');
            if (aboutSection) {
                aboutSection.scrollIntoView({ behavior: 'smooth' });
            }
        });
    }

    // ===== FLOATING ORBS ANIMATION =====
    function createFloatingOrb() {
        const orb = document.createElement('div');
        orb.className = 'floating-orb';
        orb.style.cssText = `
            position: fixed;
            width: 4px;
            height: 4px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            border-radius: 50%;
            pointer-events: none;
            z-index: 1;
            animation: floatUp 15s linear infinite;
        `;
        
        orb.style.left = Math.random() * window.innerWidth + 'px';
        orb.style.animationDelay = Math.random() * 15 + 's';
        
        document.body.appendChild(orb);
        
        setTimeout(() => {
            orb.remove();
        }, 15000);
    }

    // Crear orbs flotantes periódicamente
    setInterval(createFloatingOrb, 3000);

    // ===== PARALLAX EFFECT FOR HERO ORBS =====
    window.addEventListener('scroll', function() {
        const scrolled = window.pageYOffset;
        const orbs = document.querySelectorAll('.gradient-orb');
        
        orbs.forEach((orb, index) => {
            const speed = (index + 1) * 0.1;
            orb.style.transform = `translateY(${scrolled * speed}px)`;
        });
    });

    // ===== TYPEWRITER EFFECT FOR HERO TITLE =====
    function typeWriter(element, text, speed = 100) {
        let i = 0;
        element.innerHTML = '';
        
        function type() {
            if (i < text.length) {
                element.innerHTML += text.charAt(i);
                i++;
                setTimeout(type, speed);
            }
        }
        
        type();
    }

    // ===== LOADING ANIMATION =====
    window.addEventListener('load', function() {
        // Animar elementos del hero
        const heroTitle = document.querySelector('.hero-title');
        const heroSubtitle = document.querySelector('.hero-subtitle');
        const heroButton = document.querySelector('.hero-cta');
        
        if (heroTitle) {
            heroTitle.style.opacity = '0';
            heroTitle.style.transform = 'translateY(30px)';
            
            setTimeout(() => {
                heroTitle.style.transition = 'opacity 0.8s ease, transform 0.8s ease';
                heroTitle.style.opacity = '1';
                heroTitle.style.transform = 'translateY(0)';
            }, 300);
        }
        
        if (heroSubtitle) {
            heroSubtitle.style.opacity = '0';
            heroSubtitle.style.transform = 'translateY(30px)';
            
            setTimeout(() => {
                heroSubtitle.style.transition = 'opacity 0.8s ease, transform 0.8s ease';
                heroSubtitle.style.opacity = '1';
                heroSubtitle.style.transform = 'translateY(0)';
            }, 600);
        }
        
        if (heroButton) {
            heroButton.style.opacity = '0';
            heroButton.style.transform = 'translateY(30px)';
            
            setTimeout(() => {
                heroButton.style.transition = 'opacity 0.8s ease, transform 0.8s ease';
                heroButton.style.opacity = '1';
                heroButton.style.transform = 'translateY(0)';
            }, 900);
        }
    });

    // ===== MOBILE MENU TOGGLE =====
    function createMobileMenu() {
        const navContainer = document.querySelector('.nav-container');
        const navLinks = document.querySelector('.nav-links');
        
        if (navContainer && navLinks && window.innerWidth <= 768) {
            const mobileMenuBtn = document.createElement('button');
            mobileMenuBtn.className = 'mobile-menu-btn';
            mobileMenuBtn.innerHTML = '<i class="fas fa-bars"></i>';
            mobileMenuBtn.style.cssText = `
                background: none;
                border: none;
                color: var(--text-light);
                font-size: 1.5rem;
                cursor: pointer;
                display: none;
            `;
            
            if (window.innerWidth <= 768) {
                mobileMenuBtn.style.display = 'block';
                navLinks.style.display = 'none';
            }
            
            navContainer.appendChild(mobileMenuBtn);
            
            mobileMenuBtn.addEventListener('click', function() {
                const isVisible = navLinks.style.display === 'flex';
                navLinks.style.display = isVisible ? 'none' : 'flex';
                navLinks.style.flexDirection = 'column';
                navLinks.style.position = 'absolute';
                navLinks.style.top = '100%';
                navLinks.style.left = '0';
                navLinks.style.right = '0';
                navLinks.style.background = 'rgba(15, 15, 35, 0.95)';
                navLinks.style.padding = '1rem';
                navLinks.style.borderTop = '1px solid rgba(255,255,255,0.1)';
            });
        }
    }

    // Inicializar menú móvil
    createMobileMenu();
    window.addEventListener('resize', createMobileMenu);
});

// ===== CSS ANIMATIONS =====
const style = document.createElement('style');
style.innerHTML = `
    @keyframes floatUp {
        0% {
            transform: translateY(100vh) rotate(0deg);
            opacity: 0;
        }
        10% {
            opacity: 1;
        }
        90% {
            opacity: 1;
        }
        100% {
            transform: translateY(-100vh) rotate(360deg);
            opacity: 0;
        }
    }
    
    .floating-orb {
        box-shadow: 0 0 10px rgba(102, 126, 234, 0.5);
    }
    
    @keyframes pulse {
        0%, 100% {
            transform: scale(1);
        }
        50% {
            transform: scale(1.05);
        }
    }
    
    .logo-sphere {
        animation: pulse 3s ease-in-out infinite;
    }
`;
document.head.appendChild(style);