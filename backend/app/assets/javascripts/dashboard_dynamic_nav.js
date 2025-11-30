// Sistema de navegación dinámica para Dashboard

console.log('📝 dashboard_dynamic_nav.js está siendo cargado...');

(function() {
  'use strict';

  let isLoading = false;
  let currentView = 'inicio';

  function initDashboardDynamicNav() {
    const contentContainer = document.querySelector('#dashboard-content');
    const menuLinks = document.querySelectorAll('ul#menu a.link-menu');
    const menu = document.getElementById('menu');

    console.log('🚀 Inicializando navegación dinámica del dashboard');
    console.log('📍 contentContainer:', contentContainer);
    console.log('📍 menuLinks encontrados:', menuLinks.length);
    console.log('📍 Links:', Array.from(menuLinks).map(l => ({ href: l.href, text: l.textContent })));

    if (!contentContainer) {
      console.warn('⚠️ #dashboard-content no encontrado');
      return;
    }

    if (menuLinks.length === 0) {
      console.warn('⚠️ Ningún link de menú encontrado. Selectors probados:');
      console.log('  - ul#menu a.link-menu');
      console.log('  - Todos los links del menú:', document.querySelectorAll('ul#menu a'));
      return;
    }

    // Función para cargar vista dinámicamente
    async function loadDashboardView(url, viewName = null) {
      if (isLoading) {
        console.log('⏳ Ya hay una carga en progreso');
        return;
      }

      isLoading = true;
      console.log('📡 Cargando vista:', url);
      
      try {
        // Efecto de transición
        contentContainer.style.transition = 'opacity 0.3s ease';
        contentContainer.style.opacity = '0.6';

        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 10000); // Timeout 10s

        const response = await fetch(url, {
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'text/html'
          },
          signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }

        const html = await response.text();
        if (!html || html.trim().length === 0) {
          throw new Error('Response vacío');
        }

        // Parsear HTML
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        const sourceContent = doc.querySelector('#dashboard-content');

        if (!sourceContent) {
          console.error('⚠️ #dashboard-content no encontrado en respuesta');
          window.location.href = url;
          return;
        }

        // Animar salida
        contentContainer.style.opacity = '0';

        setTimeout(() => {
          // Reemplazar innerHTML directamente
          contentContainer.innerHTML = sourceContent.innerHTML;
          contentContainer.style.opacity = '0';
          contentContainer.style.transition = 'opacity 0.3s ease';

          // Animar entrada
          setTimeout(() => {
            contentContainer.style.opacity = '1';
          }, 10);

          // Reinicializar scripts de la nueva vista
          reinitializeDashboardScripts(contentContainer);
          
          console.log('✅ Vista cargada:', url);
        }, 300);

        // Actualizar URL sin recargar
        history.pushState({ dashboard: true, view: viewName || url }, '', url);

        // Actualizar vista actual
        currentView = viewName || url;
        updateActiveDashboardNav(url);

        // Scroll al inicio
        window.scrollTo({ top: 0, behavior: 'smooth' });

        // Cerrar menú mobile después de navegar
        if (menu) menu.classList.remove('active');

      } catch (error) {
        console.error('❌ Error al cargar vista:', error);
        // Fallback a navegación normal
        window.location.href = url;
      } finally {
        isLoading = false;
        if (contentContainer) contentContainer.style.opacity = '1';
      }
    }

    // Función para actualizar nav activo
    function updateActiveDashboardNav(url) {
      menuLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href === url || href === url.split('?')[0]) {
          link.parentElement.classList.add('active');
        } else {
          link.parentElement.classList.remove('active');
        }
      });
    }

    // Función para reinicializar scripts en nueva vista
    function reinitializeDashboardScripts(container) {
      if (!container) return;

      try {
        console.log('🔄 Reinicializando scripts...');

        // Destruir TODOS los gráficos Chart.js de forma segura
        try {
          if (window.Chart && window.Chart.instances && Array.isArray(window.Chart.instances)) {
            const instances = Array.from(window.Chart.instances);
            instances.forEach(chart => {
              try {
                if (chart && typeof chart.destroy === 'function') {
                  chart.destroy();
                  console.log('✅ Gráfico destruido');
                }
              } catch (e) {
                console.warn('⚠️ Error al destruir gráfico:', e.message);
              }
            });
          }
        } catch (e) {
          console.warn('⚠️ Error en destrucción de gráficos:', e.message);
        }

        // Limpiar todos los canvas del contenedor
        try {
          const canvases = container.querySelectorAll('canvas');
          canvases.forEach(canvas => {
            try {
              const ctx = canvas.getContext('2d');
              if (ctx) {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                console.log('🧹 Canvas limpiado:', canvas.id);
              }
            } catch (e) {
              console.warn('⚠️ Error limpiando canvas:', e.message);
            }
          });
        } catch (e) {
          console.log('⚠️ Error al limpiar canvas:', e.message);
        }

        // Pequeño delay antes de ejecutar scripts
        setTimeout(() => {
          try {
            // Ejecutar cualquier script inline que esté en el contenedor
            const scripts = container.querySelectorAll('script');
            scripts.forEach((script, index) => {
              if (script.textContent && !script.src) {
                try {
                  // IMPORTANTE: No ejecutar scripts de inicialización de gráficas en carga dinámica
                  // Solo ejecutar si contiene lógica que NO sea de gráficas (ej: event listeners)
                  const isChartScript = script.textContent.includes('initializeDashboardCharts') || 
                                       script.textContent.includes('crearGraficas') ||
                                       script.textContent.includes('Chart');
                  
                  if (!isChartScript) {
                    // Crear función anónima y ejecutarla en contexto global
                    const fn = new Function(script.textContent);
                    fn.call(window);
                    console.log(`📝 Script inline ${index + 1} ejecutado`);
                  } else {
                    console.log(`⏭️  Script de gráficas ${index + 1} saltado en carga dinámica`);
                  }
                } catch (err) {
                  console.error(`Error en script inline ${index + 1}:`, err.message);
                }
              }
            });
          } catch (e) {
            console.log('⚠️ Error ejecutando scripts:', e.message);
          }

          // Disparar evento personalizado después de ejecutar scripts
          try {
            const event = new Event('dashboard:content-loaded');
            document.dispatchEvent(event);
            console.log('✅ Evento dashboard:content-loaded disparado');
          } catch (e) {
            console.log('⚠️ Error disparando evento:', e.message);
          }
        }, 150);

      } catch (error) {
        console.error('Error reinicializando scripts:', error);
      }
    }

    // Función para asignar handlers al menú
    function attachMenuHandlers() {
      const menuLinks = document.querySelectorAll('ul#menu a.link-menu');
      
      menuLinks.forEach(link => {
        // Remover listeners previos para evitar duplicados
        link.removeEventListener('click', handleMenuClick);
        // Asignar nuevo listener
        link.addEventListener('click', handleMenuClick);
      });
      
      console.log('✅ Menu handlers asignados a', menuLinks.length, 'links');
    }

    // Manejador de clicks del menú
    function handleMenuClick(e) {
      // Permitir Ctrl/Cmd/Shift/Alt click (abrir en nueva pestaña)
      if (e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;

      e.preventDefault();
      const href = this.getAttribute('href');
      
      console.log('🔗 Click en menú:', href);
      
      if (href && href.startsWith('/dashboard')) {
        loadDashboardView(href, this.textContent.trim());
      }
    }

    // Manejar navegación back/forward
    window.addEventListener('popstate', async (e) => {
      const url = window.location.pathname + window.location.search;
      
      if (!url.startsWith('/dashboard')) return;

      console.log('🔙 Popstate:', url);

      try {
        const response = await fetch(url, {
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'text/html'
          }
        });

        if (response.ok) {
          const html = await response.text();
          const parser = new DOMParser();
          const doc = parser.parseFromString(html, 'text/html');
          const sourceContent = doc.querySelector('#dashboard-content');

          if (sourceContent && contentContainer) {
            contentContainer.innerHTML = sourceContent.innerHTML;
            reinitializeDashboardScripts(contentContainer);
            updateActiveDashboardNav(url);
            console.log('🔙 Navegación back/forward completada:', url);
          }
        }
      } catch (error) {
        console.error('Error en popstate:', error);
        window.location.href = url;
      }
    });

    // Asignar handlers del menú
    attachMenuHandlers();

    console.log('✅ Dashboard dynamic navigation inicializado correctamente');
  }

  // Esperar a que el DOM esté listo
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initDashboardDynamicNav);
  } else {
    initDashboardDynamicNav();
  }

})();
