// === OCULTAR SOLO MENSAJES DE AUTENTICACIÓN Y ERROR === 
document.addEventListener('DOMContentLoaded', () => {
  // Ocultar solo mensajes de autenticación y error
  const hideAuthErrorMessages = () => {
    document.querySelectorAll('.alert, .notification, [role="alert"]').forEach(el => {
      const text = el.textContent.toLowerCase();
      const classes = el.className.toLowerCase();
      
      // Ocultar solo si es mensaje de autenticación o error
      if (classes.includes('alert-danger') ||
          text.includes('translation missing') || 
          text.includes('ya estás') || 
          text.includes('already authenticated') ||
          text.includes('authentication') ||
          text.includes('error de autenticación') ||
          text.includes('invalid email') ||
          text.includes('invalid password')) {
        el.style.display = 'none';
        el.style.visibility = 'hidden';
        el.style.height = '0';
        el.style.margin = '0';
        el.style.padding = '0';
        el.remove();
      }
    });
  };
  
  hideAuthErrorMessages();
  
  // Ejecutar cada 100ms para alertas dinámicas
  setInterval(hideAuthErrorMessages, 100);
});

// === CACHE Y PRELOAD DE LOGIN ===
window.loginCache = null;
window.loginCacheLoading = false;

// Helper para animar transiciones de forma limpia
const animateTransition = (el, {
  duration = 400,
  easing = "cubic-bezier(0.4, 0, 0.2, 1)",
  from = {},
  to = {}
} = {}) => {
  return new Promise((resolve) => {
    el.style.transition = `all ${duration}ms ${easing}`;
    
    // Aplicar estilos iniciales
    Object.assign(el.style, from);
    
    // Trigger reflow
    void el.offsetHeight;
    
    // Aplicar estilos finales
    Object.assign(el.style, to);
    
    // Limpiar y resolver
    setTimeout(() => {
      el.style.transition = "";
      resolve();
    }, duration);
  });
};

// Precargar login HTML al cargar la página
const preloadLogin = () => {
  if (window.loginCache === null && !window.loginCacheLoading) {
    window.loginCacheLoading = true;
    fetch("/users/sign_in", { headers: { "X-Requested-Sidebar": "true" } })
      .then(res => res.text())
      .then(html => {
        window.loginCache = html;
        window.loginCacheLoading = false;
      })
      .catch(err => {
        console.warn("⚠️ Error preloading login:", err);
        window.loginCacheLoading = false;
      });
  }
};

// Precargar cuando el usuario interactúa con la página (si no estaba precargado)
document.addEventListener('click', preloadLogin, { once: true });
document.addEventListener('touchstart', preloadLogin, { once: true });
document.addEventListener('mousemove', preloadLogin, { once: true });

window.addEventListener('DOMContentLoaded', () => {
  console.log("✅ mi_script.js cargado correctamente");
  
  // Precargar login en background
  setTimeout(preloadLogin, 500);

  // === NAVBAR SCROLL LOGO ===
  const navbar = document.querySelector('.navbar');
  const links = document.querySelector('.navbar-links');
  let logo = null;

  if (navbar && links) {
    window.addEventListener('scroll', () => {
      const rect = navbar.getBoundingClientRect();
      if (rect.top <= 1 && !logo) {
        const template = document.querySelector('.header-logo2');
        if (template) {
          logo = template.cloneNode(true);
          logo.style.display = 'flex';
          logo.classList.add('fade-in');
          links.insertBefore(logo, links.firstChild);
        }
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
  }

  // === PERFIL Y LOGIN SIDEBAR ===
  const profileBtn = document.querySelector('#userButton');
  const sidebar = document.querySelector('#profileSidebar');
  const overlay = document.querySelector('#overlay');
  const closeSidebar = document.querySelector('#closeSidebar');
  const darkModeToggle = document.querySelector('#darkModeToggle');
  const avatarUpload = document.querySelector('#avatar-upload');
  const profilePic = document.querySelector('#profile-pic');

  // --- FUNCIONES AUXILIARES ---
  const loadSidebarView = (url) => {
    // Si es login y ya está cacheado, retornarlo inmediatamente
    if (url === "/users/sign_in" && window.loginCache) {
      return Promise.resolve(window.loginCache);
    }
    
    return fetch(url, { headers: { "X-Requested-Sidebar": "true" } })
      .then(res => res.text());
  };

  const renderSidebar = (html) => {
    const cleanHTML = html.replace(/<\/?(html|body|head)[^>]*>/gi, "");

    // Obtener container existente (creado por skeleton)
    let container = document.querySelector("#deviseSidebarContainer");
    if (!container) {
      container = document.createElement("div");
      container.id = "deviseSidebarContainer";
      document.body.appendChild(container);
    }

    // Usar template para mejor rendimiento
    const template = document.createElement('template');
    template.innerHTML = `
      <div class="login-sidebar active" style="
        position: fixed;
        top: 0;
        right: 0;
        width: 380px;
        height: 100%;
        background: white;
        box-shadow: -4px 0 20px rgba(0,0,0,0.2);
        z-index: 9999;
        overflow-y: auto;
        transition: transform 0.3s ease;
        transform: translateX(0);
        display: flex;
        flex-direction: column;
      ">
        <button class="close-login" style="
          position: fixed;
          top: 15px;
          right: 15px;
          background: none;
          border: none;
          font-size: 24px;
          cursor: pointer;
          z-index: 11;
          width: 32px;
          height: 32px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: #666;
        ">&times;</button>
        <div class="login-content-wrapper" style="padding: 20px; overflow: hidden; flex: 1; position: relative;">
          <div class="login-inner-content" style="width: 100%; animation: slideInRight 0.4s cubic-bezier(0.4, 0, 0.2, 1) forwards;">
            ${cleanHTML}
          </div>
        </div>
      </div>
      <div id="overlay" style="
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        z-index: 9998;
      "></div>
    `;

    // Reemplazar skeleton con HTML real (con transición suave)
    const oldSidebar = container.querySelector(".login-sidebar");
    if (oldSidebar && oldSidebar.classList.contains("login-skeleton")) {
      oldSidebar.style.opacity = "0";
      oldSidebar.style.transition = "opacity 0.2s ease";
      
      setTimeout(() => {
        container.innerHTML = '';
        container.appendChild(template.content.cloneNode(true));
        const newSidebar = container.querySelector(".login-sidebar");
        newSidebar.style.opacity = "0";
        newSidebar.offsetHeight; // Trigger reflow
        newSidebar.style.opacity = "1";
        newSidebar.style.transition = "opacity 0.2s ease";
        setupLoginHandlers(container);
      }, 200);
    } else {
      container.innerHTML = '';
      container.appendChild(template.content.cloneNode(true));
      setupLoginHandlers(container);
    }
  };

  // Función auxiliar para setup de handlers
  const setupLoginHandlers = (container) => {
    // Cerrar sidebar
    const closeLogin = container.querySelector(".close-login");
    const overlayEl = container.querySelector("#overlay");
    closeLogin.addEventListener("click", () => container.remove());
    overlayEl.addEventListener("click", () => container.remove());

    // Enlaces dentro del sidebar (login/signup/forgot)
    container.querySelectorAll('a[href*="sign_in"], a[href*="sign_up"], a[href*="password/new"]').forEach(link => {
      link.addEventListener("click", (e) => {
        e.preventDefault();
        const innerContent = container.querySelector(".login-inner-content");
        
        if (!innerContent) {
          console.warn("⚠️ No inner content found, reloading page");
          loadSidebarView(link.getAttribute("href")).then(renderSidebar);
          return;
        }
        
        console.log("🎬 Animando slide out...");
        // Slide out actual content
        animateTransition(innerContent, {
          duration: 400,
          to: { opacity: "0", transform: "translateX(-50px)" }
        }).then(() => {
          const url = link.getAttribute("href");
          console.log("📥 Cargando:", url);
          
          // Mostrar spinner de carga
          innerContent.innerHTML = '<div class="login-loading-spinner"><div class="spinner"></div></div>';
          innerContent.style.opacity = "1";
          innerContent.style.transform = "translateX(0)";
          
          loadSidebarView(url).then((html) => {
            // Renderizar nueva vista con animación slide in
            const cleanHTML = html.replace(/<\/?(html|body|head)[^>]*>/gi, "");
            innerContent.innerHTML = cleanHTML;
            
            console.log("🎬 Animando slide in...");
            // Animar entrada desde la derecha
            animateTransition(innerContent, {
              duration: 400,
              from: { opacity: "0", transform: "translateX(50px)" },
              to: { opacity: "1", transform: "translateX(0)" }
            }).then(() => {
              console.log("✅ Animación completada");
              setupLoginHandlers(container);
            });
          });
        });
      });
    });

    // ⬇️ Interceptar submits dentro del sidebar
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
    container.querySelectorAll('form').forEach(form => {
      form.addEventListener('submit', (e) => {
        e.preventDefault();

        const method = (form.method || 'post').toUpperCase();
        const action = form.action;
        const formData = new FormData(form);
        const innerContent = container.querySelector(".login-inner-content");
        
        // Detectar si es formulario de recuperar contraseña o login
        const isPasswordRecovery = action.includes('password') || form.querySelector('input[name*="email"]');
        const loadingText = isPasswordRecovery ? 'Cargando...' : 'Iniciando sesión...';
        
        // Agregar spinner de carga full-page
        const loadingSpinner = document.createElement('div');
        loadingSpinner.className = 'login-loading-spinner';
        loadingSpinner.innerHTML = `
          <div class="spinner-container">
            <div class="spinner"></div>
            <p class="loading-text">${loadingText}</p>
          </div>
        `;
        innerContent.innerHTML = '';
        innerContent.appendChild(loadingSpinner);
        
        console.log('🔄 Spinner de carga mostrado');

        fetch(action, {
          method,
          headers: {
            'X-Requested-Sidebar': 'true',
            'X-CSRF-Token': csrfToken,
            'Accept': 'text/html, application/json;q=0.9, */*;q=0.8'
          },
          body: formData,
          credentials: 'same-origin',
          redirect: 'follow'
        })
        .then(async (res) => {
          const ct = res.headers.get('content-type') || '';

          if (ct.includes('application/json')) {
            const data = await res.json();
            if (data.success) {
              window.isLoggedIn = true;
              // Cerrar login sidebar con animación
              await animateTransition(innerContent, {
                duration: 400,
                to: { opacity: "0", transform: "translateX(-50px)" }
              });
              container.remove();
              
              if (data.redirect_url) {
                window.location.href = data.redirect_url;
              } else {
                window.location.reload();
              }
            }
            return;
          }

          // HTML: re-renderizar dentro del mismo sidebar (muestra errores)
          // Remover animación de carga del botón
          if (submitButton) {
            const originalText = submitButton.dataset.originalText || 'Entrar';
            submitButton.textContent = originalText;
            submitButton.classList.remove('button-loading');
            submitButton.disabled = false;
          }
          
          // Con animación de fade para mostrar errores
          const newHtml = await res.text();
          const cleanHTML = newHtml.replace(/<\/?(html|body|head)[^>]*>/gi, "");
          
          await animateTransition(innerContent, {
            duration: 200,
            easing: "ease",
            to: { opacity: "0" }
          });
          
          innerContent.innerHTML = cleanHTML;
          
          await animateTransition(innerContent, {
            duration: 300,
            easing: "ease",
            from: { opacity: "0" },
            to: { opacity: "1" }
          });
          
          setupLoginHandlers(container);
        })
        .catch(async (err) => {
          console.error('❌ Error en submit:', err);
          
          // Remover animación de carga del botón en caso de error
          if (submitButton) {
            const originalText = submitButton.dataset.originalText || 'Entrar';
            submitButton.textContent = originalText;
            submitButton.classList.remove('button-loading');
            submitButton.disabled = false;
          }
          
          await animateTransition(innerContent, {
            duration: 200,
            easing: "ease",
            to: { opacity: "0" }
          });
          
          innerContent.innerHTML = '<p style="color: red; padding: 20px;">Error de conexión. Intenta de nuevo.</p>';
          
          await animateTransition(innerContent, {
            duration: 300,
            easing: "ease",
            from: { opacity: "0" },
            to: { opacity: "1" }
          });
        });
      });
    });
  };

  // Función para mostrar skeleton del login (INSTANTÁNEAMENTE)
  const showLoginSkeleton = () => {
    let container = document.querySelector("#deviseSidebarContainer");
    if (!container) {
      container = document.createElement("div");
      container.id = "deviseSidebarContainer";
      document.body.appendChild(container);
    }

    const template = document.createElement('template');
    template.innerHTML = `
      <div class="login-sidebar active login-skeleton" style="
        position: fixed;
        top: 0;
        right: 0;
        width: 380px;
        height: 100%;
        background: white;
        box-shadow: -4px 0 20px rgba(0,0,0,0.2);
        z-index: 9999;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
      ">
        <div class="login-content" style="padding: 20px;">
          <button class="close-login" style="
            position: absolute;
            top: 15px;
            right: 15px;
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
          ">&times;</button>
          
          <!-- SKELETON LOADING SCREEN -->
          <div class="skeleton-container" style="animation: pulse 1.5s infinite;">
            <!-- Logo skeleton -->
            <div class="skeleton-box" style="width: 100px; height: 100px; border-radius: 50%; margin: 20px auto; background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%); background-size: 200% 100%; animation: loading 1.5s infinite;"></div>
            
            <!-- Email input skeleton -->
            <div class="skeleton-box" style="width: 100%; height: 40px; margin: 15px 0; border-radius: 4px; background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%); background-size: 200% 100%; animation: loading 1.5s infinite;"></div>
            
            <!-- Password input skeleton -->
            <div class="skeleton-box" style="width: 100%; height: 40px; margin: 15px 0; border-radius: 4px; background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%); background-size: 200% 100%; animation: loading 1.5s infinite;"></div>
            
            <!-- Button skeleton -->
            <div class="skeleton-box" style="width: 100%; height: 44px; margin: 20px 0; border-radius: 4px; background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%); background-size: 200% 100%; animation: loading 1.5s infinite;"></div>
            
            <!-- Link skeleton -->
            <div class="skeleton-box" style="width: 80%; height: 16px; margin: 10px auto; border-radius: 4px; background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%); background-size: 200% 100%; animation: loading 1.5s infinite;"></div>
          </div>
        </div>
      </div>
      <div id="overlay" style="
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        z-index: 9998;
      "></div>
    `;

    container.innerHTML = '';
    container.appendChild(template.content.cloneNode(true));

    // Permitir cerrar con overlay
    const overlayEl = container.querySelector("#overlay");
    const closeBtn = container.querySelector(".close-login");
    const closeLoginFn = () => container.remove();
    overlayEl.addEventListener("click", closeLoginFn);
    closeBtn.addEventListener("click", closeLoginFn);
    
    return container;
  };

  // --- ABRIR SIDEBAR DE PERFIL O LOGIN ---
  if (profileBtn) {
    profileBtn.addEventListener('click', (e) => {
      e.preventDefault();

      // Si no está logueado, carga login desde Devise
      if (window.isLoggedIn === false) {
        console.log("🔒 Mostrando login sidebar...");
        
        // MOSTRAR SKELETON INSTANTÁNEAMENTE
        showLoginSkeleton();
        
        // Cargar HTML real en background y reemplazar skeleton
        loadSidebarView("/users/sign_in").then(renderSidebar);
        return;
      }

      // Si está logueado, abre el sidebar normal del perfil
      sidebar?.classList.toggle('open');
      overlay?.classList.toggle('show');
    });
  }

  // Cerrar sidebar manual
  closeSidebar?.addEventListener('click', () => {
    sidebar?.classList.remove('open');
    overlay?.classList.remove('show');
  });

  overlay?.addEventListener('click', () => {
    sidebar?.classList.remove('open');
    overlay?.classList.remove('show');
  });

  // === DARK MODE Y AVATAR ===
  if (avatarUpload && profilePic) {
    avatarUpload.addEventListener('change', (event) => {
      const file = event.target.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = (e) => (profilePic.src = e.target.result);
        reader.readAsDataURL(file);
      }
    });
  }

  if (darkModeToggle) {
    darkModeToggle.addEventListener('click', () => {
      document.body.classList.toggle('dark-mode');
      darkModeToggle.textContent = document.body.classList.contains('dark-mode')
        ? '☀️ Modo claro'
        : '🌙 Modo oscuro';
    });
  }

  // === LOGOUT BUTTON ANIMATION ===
  // Manejador para botones de logout que incluyen animación de carga
  document.addEventListener('submit', (e) => {
    const form = e.target;
    // Verificar si el formulario contiene un botón de logout
    const logoutButton = form.querySelector('[class*="logout"]');
    
    if (logoutButton) {
      console.log('✨ Animación de logout iniciada');
      
      // Crear overlay con spinner
      const overlay = document.createElement('div');
      overlay.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(255, 255, 255, 0.9);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
      `;
      
      const spinnerDiv = document.createElement('div');
      spinnerDiv.innerHTML = `
        <div style="display: flex; flex-direction: column; align-items: center; gap: 20px;">
          <div style="
            width: 50px;
            height: 50px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #0066cc;
            border-radius: 50%;
            animation: spin 1s linear infinite;
          "></div>
          <p style="font-size: 16px; color: #666; font-weight: 500; margin: 0;">Cerrando sesión...</p>
        </div>
      `;
      
      overlay.appendChild(spinnerDiv);
      document.body.appendChild(overlay);
    }
  });
});
