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

  // === SECCIÓN: SIDEBAR PERFIL ===
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

  // --- SIDEBAR PERFIL ---
  if (sidebar) {
    profileBtn.addEventListener('click', (e) => {
      e.preventDefault();

      // ✅ Si no está logueado, mostrar el login real de Devise en un sidebar
      if (window.isLoggedIn === false) {
        console.log("🟢 Cargando vista real de Devise en sidebar...");

        // Evitar duplicados
        if (document.querySelector('.login-sidebar')) return;

        fetch("/users/sign_in")
          .then(res => res.text())
          .then(html => {
            // Crear contenedor del sidebar
            const container = document.createElement("div");
            container.id = "deviseSidebarContainer";
            container.innerHTML = `
              <div class="login-sidebar active">
                <div class="login-content">
                  <button class="close-login">&times;</button>
                  ${html}
                </div>
              </div>
              <div id="overlay" class="show"></div>
            `;
            document.body.appendChild(container);

            // Botón de cerrar
            const closeLogin = container.querySelector(".close-login");
            closeLogin.addEventListener("click", () => {
              container.remove();
            });

            // Cerrar con overlay
            const overlayEl = container.querySelector("#overlay");
            overlayEl.addEventListener("click", () => {
              container.remove();
            });
          })
          .catch(err => console.error("❌ Error al cargar el login de Devise:", err));

        return;
      }

      // Si está logueado, abre el sidebar de perfil
      sidebar.classList.toggle('open');
      overlay.classList.toggle('show');
      console.log("📂 Sidebar:", sidebar.classList.contains('open') ? "ABIERTO" : "CERRADO");
    });

    closeSidebar?.addEventListener('click', () => {
      sidebar.classList.remove('open');
      overlay.classList.remove('show');
    });

    overlay?.addEventListener('click', () => {
      sidebar.classList.remove('open');
      overlay.classList.remove('show');
    });

    // Cambiar foto de perfil (preview)
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

  // === 💀 LOGIN SIDEBAR ELIMINADO ===
  // El bloque del formulario falso fue reemplazado por un fetch real a Devise.
  // Devise maneja la autenticación, y el formulario se muestra dentro de un panel lateral dinámico.
});
