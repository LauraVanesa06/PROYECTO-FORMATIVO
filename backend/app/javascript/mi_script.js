window.addEventListener('DOMContentLoaded', () => {
  console.log("✅ mi_script.js cargado correctamente");

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
    return fetch(url, { headers: { "X-Requested-Sidebar": "true" } })
      .then(res => res.text());
  };

  const renderSidebar = (html) => {
    const cleanHTML = html.replace(/<\/?(html|body|head)[^>]*>/gi, "");

    // Crear contenedor si no existe
    let container = document.querySelector("#deviseSidebarContainer");
    if (!container) {
      container = document.createElement("div");
      container.id = "deviseSidebarContainer";
      document.body.appendChild(container);
    }

    // Estructura flotante
    container.innerHTML = `
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
          ${cleanHTML}
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

    // Cerrar sidebar
    const closeLogin = container.querySelector(".close-login");
    const overlayEl = container.querySelector("#overlay");
    closeLogin.addEventListener("click", () => container.remove());
    overlayEl.addEventListener("click", () => container.remove());

    // Enlaces dentro del sidebar (login/signup/forgot)
    container.querySelectorAll('a[href*="sign_in"], a[href*="sign_up"], a[href*="password/new"]').forEach(link => {
      link.addEventListener("click", (e) => {
        e.preventDefault();
        loadSidebarView(link.getAttribute("href")).then(renderSidebar);
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
              // Cerrar login sidebar y seguir flujo
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
          const newHtml = await res.text();
          renderSidebar(newHtml);
        })
        .catch((err) => console.error('Login sidebar submit error:', err));
      });
    });
  };

  // --- ABRIR SIDEBAR DE PERFIL O LOGIN ---
  if (profileBtn) {
    profileBtn.addEventListener('click', (e) => {
      e.preventDefault();

      // Si no está logueado, carga login desde Devise
      if (window.isLoggedIn === false) {
        console.log("🔒 Mostrando login sidebar...");
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
});
