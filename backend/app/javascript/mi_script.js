window.addEventListener('DOMContentLoaded', () => {
  console.log("✅ mi_script.js cargado correctamente");

  // === SCRIPT ORIGINAL: NAVBAR ===
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

  // === SECCIÓN: SIDEBAR PERFIL Y LOGIN ===
  const profileBtn = document.querySelector('#userButton');
  const sidebar = document.querySelector('#profileSidebar');
  const overlay = document.querySelector('#overlay');
  const closeSidebar = document.querySelector('#closeSidebar');
  const darkModeToggle = document.querySelector('#darkModeToggle');
  const avatarUpload = document.querySelector('#avatar-upload');
  const profilePic = document.querySelector('#profile-pic');

  if (!profileBtn) {
    console.warn("⚠️ No se encontró el botón de usuario.");
    return;
  }

  // --- FUNCIONES AUXILIARES ---
  const loadSidebarView = (url) => {
    return fetch(url, { headers: { "X-Requested-Sidebar": "true" } })
      .then(res => res.text());
  };

  const renderSidebar = (html) => {
    // Si ya existe el contenedor, reemplazar el contenido
    let container = document.querySelector("#deviseSidebarContainer");
    if (!container) {
      container = document.createElement("div");
      container.id = "deviseSidebarContainer";
      document.body.appendChild(container);
    }

    container.innerHTML = `
      <div class="login-sidebar active">
        <div class="login-content">
          <button class="close-login">&times;</button>
          ${html}
        </div>
      </div>
      <div id="overlay" class="show"></div>
    `;

    // Cerrar sidebar
    const closeLogin = container.querySelector(".close-login");
    closeLogin.addEventListener("click", () => container.remove());
    const overlayEl = container.querySelector("#overlay");
    overlayEl.addEventListener("click", () => container.remove());

    // 🎯 Escuchar enlaces de cambio entre login y registro
    const registerLink = container.querySelector('a[href*="sign_up"]');
    const loginLink = container.querySelector('a[href*="sign_in"]');
    const forgotLink = container.querySelector('a[href*="password/new"]');

    if (registerLink) {
      registerLink.addEventListener("click", (e) => {
        e.preventDefault();
        loadSidebarView("/users/sign_up").then(renderSidebar);
      });
    }

    if (loginLink) {
      loginLink.addEventListener("click", (e) => {
        e.preventDefault();
        loadSidebarView("/users/sign_in").then(renderSidebar);
      });
    }

    if (forgotLink) {
      forgotLink.addEventListener("click", (e) => {
        e.preventDefault();
        loadSidebarView("/users/password/new").then(renderSidebar);
      });
    }
  };

  // --- ABRIR LOGIN O PERFIL ---
  if (sidebar) {
    profileBtn.addEventListener('click', (e) => {
      e.preventDefault();

      // ✅ Si no está logueado, cargar el login sidebar
      if (window.isLoggedIn === false) {
        console.log("🟢 Cargando vista real de Devise en sidebar...");
        loadSidebarView("/users/sign_in").then(renderSidebar)
          .catch(err => console.error("❌ Error al cargar el login de Devise:", err));
        return;
      }

      // Si está logueado, abre el sidebar de perfil
      sidebar.classList.toggle('open');
      overlay.classList.toggle('show');
      console.log("📂 Sidebar:", sidebar.classList.contains('open') ? "ABIERTO" : "CERRADO");
    });

    // --- Cerrar Sidebar Perfil ---
    closeSidebar?.addEventListener('click', () => {
      sidebar.classList.remove('open');
      overlay.classList.remove('show');
    });

    overlay?.addEventListener('click', () => {
      sidebar.classList.remove('open');
      overlay.classList.remove('show');
    });

    // --- Preview de foto ---
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

    // --- Modo oscuro ---
    if (darkModeToggle) {
      darkModeToggle.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        darkModeToggle.textContent = document.body.classList.contains('dark-mode')
          ? '☀️ Modo claro'
          : '🌙 Modo oscuro';
      });
    }
  }

  // ✅ Detectar clic en enlace "Registrarse" dentro del sidebar
  document.addEventListener("click", (e) => {
    if (e.target.matches(".register-link")) {
      e.preventDefault();
      console.log("🟢 Cargando formulario de registro...");

      fetch("/users/sign_up", { headers: { "X-Requested-Sidebar": "true" } })
        .then(res => res.text())
        .then(html => {
          const container = document.querySelector("#deviseSidebarContainer");
          if (container) {
            const content = container.querySelector(".login-content");
            content.innerHTML = `
              <button class="close-login">&times;</button>
              ${html}
            `;
          }
        })
        .catch(err => console.error("❌ Error al cargar registro:", err));
    }
  });

  // ✅ Detectar clic en enlace "¿Olvidaste tu contraseña?" dentro del sidebar
  document.addEventListener("click", (e) => {
    if (e.target.matches(".forgot-link")) {
      e.preventDefault();
      console.log("🟢 Cargando formulario de recuperación de contraseña...");

      fetch("/users/password/new", { headers: { "X-Requested-Sidebar": "true" } })
        .then(res => res.text())
        .then(html => {
          const container = document.querySelector("#deviseSidebarContainer");
          if (container) {
            const content = container.querySelector(".login-content");
            content.innerHTML = `
              <button class="close-login">&times;</button>
              ${html}
            `;
          }
        })
        .catch(err => console.error("❌ Error al cargar recuperación:", err));
    }
  });

  // ✅ Detectar clic en enlace "Inicia sesión aquí" dentro del sidebar
  document.addEventListener("click", (e) => {
    if (e.target.matches(".login-link")) {
      e.preventDefault();
      console.log("🟢 Volviendo al formulario de inicio de sesión...");

      fetch("/users/sign_in", { headers: { "X-Requested-Sidebar": "true" } })
        .then(res => res.text())
        .then(html => {
          const container = document.querySelector("#deviseSidebarContainer");
          if (container) {
            const content = container.querySelector(".login-content");
            content.innerHTML = `
              <button class="close-login">&times;</button>
              ${html}
            `;
          }
        })
        .catch(err => console.error("❌ Error al cargar login:", err));
    }
  });
});
