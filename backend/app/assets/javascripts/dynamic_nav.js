// Sistema de navegación dinámica para Inicio, Productos y Contactos

document.addEventListener('DOMContentLoaded', function() {
  // Contenedor principal donde se cargará el contenido
  const mainContent = document.querySelector('main') || document.body;
  
  // Enlaces de navegación - buscar por id y clase
  const navHome = document.getElementById('nav-home') || document.querySelector('.nav-home');
  const navProducts = document.querySelector('.nav-products');
  const navContacts = document.querySelector('.nav-contacts');

  // Variable para rastrear la vista actual
  let currentView = 'home';
  let isLoading = false;

  // Función para cargar productos de una categoría dinámicamente
  window.loadCategoryProducts = async function(event, categoryId) {
    event.preventDefault();
    event.stopPropagation();
    
    console.log('🔥 Cargando productos de categoría:', categoryId);
    
    // Obtener el locale actual de la URL o del DOM
    const pathParts = window.location.pathname.split('/').filter(p => p);
    let locale = '';
    
    // Detectar si el primer segmento es un locale (es o en)
    if (pathParts.length > 0 && (pathParts[0] === 'es' || pathParts[0] === 'en')) {
      locale = pathParts[0];
    }
    
    // Construir URL
    const url = locale ? `/${locale}/productos?category_id=${categoryId}` : `/productos?category_id=${categoryId}`;
    
    console.log('📍 Locale detectado:', locale || 'ninguno');
    console.log('🚀 URL:', url);
    
    const currentContent = document.querySelector('#dynamic-content');
    if (!currentContent) {
      console.warn('⚠️ #dynamic-content no encontrado, navegando normalmente');
      window.location.href = url;
      return;
    }

    // Agregar efecto de carga
    currentContent.style.transition = 'opacity 0.3s ease';
    currentContent.style.opacity = '0.6';

    try {
      const response = await fetch(url, {
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'text/html'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const html = await response.text();
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      const sourceContent = doc.querySelector('#dynamic-content');
      
      if (!sourceContent) {
        console.error('⚠️ #dynamic-content no encontrado en respuesta');
        window.location.href = url;
        return;
      }

      // Animar transición
      currentContent.style.opacity = '0';
      
      setTimeout(() => {
        // Reemplazar contenido
        currentContent.innerHTML = sourceContent.innerHTML;
        
        // Animar entrada
        currentContent.style.opacity = '0';
        setTimeout(() => {
          currentContent.style.opacity = '1';
        }, 10);
        
        // Reinicializar scripts (carrusel, listeners, etc)
        reinitializeScripts(currentContent);
      }, 300);

      // Actualizar URL sin recargar
      history.pushState({ view: 'productos', category_id: categoryId }, '', url);
      
      // Actualizar la vista actual para que la navegación se resalte correctamente
      currentView = 'productos';
      updateActiveNav();
      
      // Scroll suave al inicio
      window.scrollTo({ top: 0, behavior: 'smooth' });
      
      console.log('✅ Productos cargados dinámicamente');
    } catch (error) {
      console.error('❌ Error al cargar categoría:', error);
      // Fallback a navegación normal
      window.location.href = url;
    }
  };

  // Función simple para filtrar por categoría (ahora solo se usa como backup)
  window.filterByCategory = function(event, categoryId) {
    // Esta función ya no es necesaria porque usamos href directo en los links
    console.log('⚠️ filterByCategory deprecated - usar loadCategoryProducts en lugar de onclick');
  };

  // Inicializar categorías en home (ahora solo logging)
  function initializeCategories() {
    const categoryLinks = document.querySelectorAll('.category-link');
    console.log('✅ Categorías encontradas:', categoryLinks.length);
    categoryLinks.forEach((link, idx) => {
      console.log(`   - Link ${idx}: href="${link.href}"`);
    });
  }

  // Inicializar en carga
  initializeCategories();

  // Función para cargar detalles de producto dinámicamente
  window.loadProductDetails = async function(productoId) {
    const url = `/home/producto_show?id=${productoId}`;
    const currentContent = document.querySelector('#dynamic-content');
    
    if (!currentContent) {
      // Si no está en flujo dinámico, usar navegación normal
      window.location = url;
      return;
    }

    // Agregar efecto de carga
    currentContent.style.transition = 'opacity 0.3s ease';
    currentContent.style.opacity = '0.6';

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
        const sourceContent = doc.querySelector('#dynamic-content');
        
        if (sourceContent) {
          // Animar salida
          currentContent.style.opacity = '0';
          
          setTimeout(() => {
            // Reemplazar contenido
            currentContent.innerHTML = sourceContent.innerHTML;
            
            // Animar entrada
            currentContent.style.opacity = '0';
            
            setTimeout(() => {
              currentContent.style.opacity = '1';
            }, 10);
            
            // Reinicializar scripts
            reinitializeScripts(currentContent);
          }, 200);

          // Actualizar URL sin recargar
          history.pushState({ view: 'producto_show', id: productoId }, '', url);
        }

        // Actualizar vista actual
        currentView = 'producto_show';
        updateActiveNav();

        // Scroll suave al inicio
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    } catch (error) {
      console.error('Error al cargar producto:', error);
      showToast('Error al cargar producto', 'danger');
      
      // Restaurar
      if (currentContent) {
        currentContent.style.opacity = '1';
      }
    }
  };

  // Función para cargar contenido dinámicamente
  async function loadView(viewName, url) {
    if (isLoading) return; // Evitar cargas simultáneas
    isLoading = true;

    try {
      // Validar URL
      if (!url || typeof url !== 'string') {
        throw new Error('URL inválida');
      }

      // Agregar efecto de carga suave
      const loadingArea = document.querySelector('#dynamic-content');
      if (loadingArea) {
        loadingArea.style.transition = 'opacity 0.3s ease';
        loadingArea.style.opacity = '0.6';
      }

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000); // Timeout de 10 segundos

      const response = await fetch(url, {
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'text/html'
        },
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const html = await response.text();
      
      if (!html || html.trim().length === 0) {
        throw new Error('Response vacío');
      }

      // Extraer el contenido principal usando DOMParser
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      
      // Buscar el contenedor #dynamic-content en el HTML descargado
      const sourceContent = doc.querySelector('#dynamic-content');
      
      if (!sourceContent) {
        console.warn('No content container found in response');
        throw new Error('No se encontró contenido en la respuesta');
      }

      // Obtener el contenedor de destino
      const targetContent = document.querySelector('#dynamic-content');
      if (!targetContent) {
        throw new Error('Dynamic content container not found en página actual');
      }

      // Limpiar listeners anteriores antes de reemplazar contenido
      const oldContent = targetContent.cloneNode(false);
      targetContent.parentNode.replaceChild(oldContent, targetContent);
      
      // Re-obtener referencia después del reemplazo
      const newTargetContent = document.querySelector('#dynamic-content');
      
      // Copiar el HTML del contenido descargado
      newTargetContent.innerHTML = sourceContent.innerHTML;
      newTargetContent.style.opacity = '1';
      newTargetContent.style.transition = 'opacity 0.3s ease';

      // Reinicializar scripts de la nueva página
      reinitializeScripts(newTargetContent);

      // Actualizar vista actual
      currentView = viewName;
      updateActiveNav();

      // Scroll suave al inicio del contenido
      window.scrollTo({ top: 0, behavior: 'smooth' });

    } catch (error) {
      console.error('Error loading view:', error);
      isLoading = false;
      showToast('Error al cargar la página: ' + error.message, 'danger');
      
      // Restaurar opacidad en caso de error
      const errorArea = document.querySelector('#dynamic-content');
      if (errorArea) errorArea.style.opacity = '1';
    } finally {
      if (isLoading) {
        isLoading = false;
        const finalArea = document.querySelector('#dynamic-content');
        if (finalArea) finalArea.style.opacity = '1';
      }
    }
  }

  // Función para reinicializar scripts después de cargar contenido
  function reinitializeScripts(container) {
    if (!container) return;

    try {
      // Reinicializar category-links para cargar dinámicamente
      const categoryLinks = container.querySelectorAll('.category-link');
      if (categoryLinks.length > 0) {
        console.log('🔄 Reinicializando', categoryLinks.length, 'category-links');
        categoryLinks.forEach(link => {
          // Remover onclick anterior si existe
          link.onclick = null;
          // Agregar nuevo onclick
          const categoryId = link.getAttribute('data-category-id');
          if (categoryId) {
            link.onclick = function(e) {
              window.loadCategoryProducts(e, categoryId);
              return false;
            };
          }
        });
      }

      // Reinicializar carrusel de categorías si existe
      const carousel = container.querySelector('#category-carousel');
      if (carousel) {
        try {
          const leftBtn = container.querySelector(".category-arrow.left");
          const rightBtn = container.querySelector(".category-arrow.right");
          const card = carousel.querySelector(".category-card");
          
          if (card && leftBtn && rightBtn) {
            const cardWidth = card.offsetWidth + 16;
            const scrollAmount = cardWidth * 2;

            // Remover listeners anteriores
            const newLeftBtn = leftBtn.cloneNode(true);
            const newRightBtn = rightBtn.cloneNode(true);
            leftBtn.parentNode.replaceChild(newLeftBtn, leftBtn);
            rightBtn.parentNode.replaceChild(newRightBtn, rightBtn);

            // Agregar nuevos listeners
            const updatedLeftBtn = container.querySelector(".category-arrow.left");
            const updatedRightBtn = container.querySelector(".category-arrow.right");

            if (updatedLeftBtn) {
              updatedLeftBtn.addEventListener("click", () => {
                carousel.scrollBy({ left: -scrollAmount, behavior: "smooth" });
              });
            }
            if (updatedRightBtn) {
              updatedRightBtn.addEventListener("click", () => {
                carousel.scrollBy({ left: scrollAmount, behavior: "smooth" });
              });
            }
          }
        } catch (e) {
          console.warn('Error initializing category carousel:', e);
        }
      }

      // Reinicializar carrusel principal de imágenes
      const mainCarousel = container.querySelector('#carouselExampleIndicators');
      if (mainCarousel && window.bootstrap) {
        try {
          const existingInstance = bootstrap.Carousel.getInstance(mainCarousel);
          if (existingInstance) {
            existingInstance.dispose();
          }
          new bootstrap.Carousel(mainCarousel);
        } catch (e) {
          console.warn('Error initializing main carousel:', e);
        }
      }

      // Reinicializar listeners de productos (carrito, favoritos, etc.)
      initializeProductListeners(container);
    } catch (error) {
      console.error('Error in reinitializeScripts:', error);
    }
  }

  // Función para inicializar listeners de productos
  function initializeProductListeners(container) {
    if (!container) return;

    try {
      const productCards = container.querySelectorAll('.product-card');
      const addToCartBtns = container.querySelectorAll('.add-to-cart-btn');
      const favoriteBtns = container.querySelectorAll('.favorite-btn');

      // Click en tarjeta de producto
      productCards.forEach(card => {
        // Clonar para remover listeners anteriores
        const newCard = card.cloneNode(true);
        card.parentNode.replaceChild(newCard, card);
        
        newCard.addEventListener('click', (e) => {
          // No navegar si el click fue en botones/iconos
          if (e.target.closest('button') || e.target.closest('i')) return;
          const productId = newCard.dataset.productoId;
          if (productId) loadProductDetails(productId);
        });
      });

      // Botones agregar al carrito
      addToCartBtns.forEach(btn => {
        // Clonar para remover listeners anteriores
        const newBtn = btn.cloneNode(true);
        btn.parentNode.replaceChild(newBtn, btn);
        
        newBtn.addEventListener('click', async (e) => {
          e.preventDefault();
          e.stopPropagation();
          
          if (!window.isLoggedIn) {
            openProfileSidebar();
            return;
          }

          const url = newBtn.dataset.url;
          if (!url) return;

          // Agregar animación de carga solo al icono
          const icon = newBtn.querySelector('i');
          if (icon) {
            icon.classList.add('icon-loading');
          }
          newBtn.disabled = true;

          try {
            const csrfToken = document.querySelector("meta[name='csrf-token']");
            const response = await fetch(url, {
              method: 'POST',
              headers: {
                'X-CSRF-Token': csrfToken ? csrfToken.content : '',
                'Accept': 'application/json'
              }
            });

            if (response.ok) {
              const data = await response.json();
              if (data.cart_html) {
                const cartBody = document.querySelector('#cart-offcanvas-body');
                if (cartBody) cartBody.innerHTML = data.cart_html;
              }
              const cartCount = document.querySelector('#cart-count');
              if (cartCount && data.count !== undefined) {
                cartCount.textContent = data.count;
                cartCount.style.display = data.count > 0 ? 'inline' : 'none';
              }
              showToast('Producto agregado al carrito', 'success');
            } else {
              showToast('Error al agregar al carrito', 'danger');
            }
          } catch (error) {
            console.error('Error:', error);
            showToast('Error de conexión', 'danger');
          } finally {
            // Remover animación de carga del icono
            if (icon) {
              icon.classList.remove('icon-loading');
            }
            newBtn.disabled = false;
          }
        });
      });

      // Botones favoritos
      favoriteBtns.forEach(btn => {
        // Clonar para remover listeners anteriores
        const newBtn = btn.cloneNode(true);
        btn.parentNode.replaceChild(newBtn, btn);
        
        newBtn.addEventListener('click', async (e) => {
          e.preventDefault();
          e.stopPropagation();

          const url = newBtn.dataset.url;
          const method = (newBtn.dataset.method || 'post').toUpperCase();
          const productId = newBtn.dataset.productId;

          if (!url) return;

          // Agregar animación de carga al icono
          const icon = newBtn.querySelector('i');
          if (icon) {
            icon.classList.add('icon-loading');
          }
          newBtn.disabled = true;

          // ACTUALIZAR DOM INMEDIATAMENTE (optimistic UI) - igual que carrito
          if (method === 'POST') {
            // Agregar a favoritos: cambiar estilo inmediatamente
            newBtn.classList.remove('btn-outline-warning');
            newBtn.classList.add('btn-warning');
            if (icon) {
              icon.classList.remove('fa-regular');
              icon.classList.add('fa-solid');
            }
          } else {
            // Remover de favoritos: cambiar estilo inmediatamente
            newBtn.classList.add('btn-outline-warning');
            newBtn.classList.remove('btn-warning');
            if (icon) {
              icon.classList.add('fa-regular');
              icon.classList.remove('fa-solid');
            }
          }

          try {
            const csrfToken = document.querySelector("meta[name='csrf-token']");
            const response = await fetch(url, {
              method: method,
              headers: {
                'X-CSRF-Token': csrfToken ? csrfToken.content : '',
                'Accept': 'application/json'
              }
            });

            const data = await response.json();

            // Si no está autenticado, abrir el sidebar de login y revertir cambios
            if (!response.ok && response.status === 401 && data.show_login_sidebar) {
              openProfileSidebar();
              // Revertir cambios visuales
              if (method === 'POST') {
                newBtn.classList.remove('btn-warning');
                newBtn.classList.add('btn-outline-warning');
                if (icon) {
                  icon.classList.add('fa-regular');
                  icon.classList.remove('fa-solid');
                }
              } else {
                newBtn.classList.remove('btn-outline-warning');
                newBtn.classList.add('btn-warning');
                if (icon) {
                  icon.classList.remove('fa-regular');
                  icon.classList.add('fa-solid');
                }
              }
            } else if (response.ok) {
              console.log('Favorite response:', data);

              if (method === 'POST') {
                if (data.id) newBtn.dataset.url = `/favorites/${data.id}`;
                newBtn.dataset.method = 'delete';
                showToast('Agregado a favoritos', 'success');
                
                // Recargar offcanvas en background SIN ESPERAR (sin await)
                if (typeof reloadFavoritesOffcanvas === 'function') {
                  reloadFavoritesOffcanvas();
                }
                
                // Sincronizar en otras ventanas/tabs
                broadcastFavoriteAdded(productId);
              } else {
                newBtn.dataset.url = `/favorites?product_id=${productId}`;
                newBtn.dataset.method = 'post';
                showToast('Removido de favoritos', 'success');
                
                // Sincronizar en otras ventanas/tabs
                broadcastFavoriteRemoved(productId);
                
                // Actualizar contador de favoritos
                updateFavoritesCounter();
              }
            } else {
              // Si hay error, revertir cambios
              if (method === 'POST') {
                newBtn.classList.remove('btn-warning');
                newBtn.classList.add('btn-outline-warning');
                if (icon) {
                  icon.classList.add('fa-regular');
                  icon.classList.remove('fa-solid');
                }
              } else {
                newBtn.classList.remove('btn-outline-warning');
                newBtn.classList.add('btn-warning');
                if (icon) {
                  icon.classList.remove('fa-regular');
                  icon.classList.add('fa-solid');
                }
              }
              const errorMessage = data.error || 'Error al actualizar favorito';
              showToast(errorMessage, 'danger');
            }
          } catch (error) {
            console.error('Error:', error);
            // Revertir cambios si hay error
            if (method === 'POST') {
              newBtn.classList.remove('btn-warning');
              newBtn.classList.add('btn-outline-warning');
              if (icon) {
                icon.classList.add('fa-regular');
                icon.classList.remove('fa-solid');
              }
            } else {
              newBtn.classList.remove('btn-outline-warning');
              newBtn.classList.add('btn-warning');
              if (icon) {
                icon.classList.remove('fa-regular');
                icon.classList.add('fa-solid');
              }
            }
            showToast('Error de conexión al actualizar favorito', 'danger');
          } finally {
            // Remover animación de carga
            if (icon) {
              icon.classList.remove('icon-loading');
            }
            newBtn.disabled = false;
          }
        });
      });

      // Inicializar formulario de filtros si existe
      const filterForm = container.querySelector('#productos-filter-form');
      if (filterForm) {
        initializeAutoFilter(filterForm);
      }

      // Inicializar paginación dinámica
      initializePagination(container);
    } catch (error) {
      console.error('Error in initializeProductListeners:', error);
    }
  }

  // Función para inicializar paginación dinámica
  function initializePagination(container) {
    const paginationLinks = container.querySelectorAll('.pagination-link');
    
    paginationLinks.forEach(link => {
      link.removeEventListener('click', handlePaginationClick);
      link.addEventListener('click', handlePaginationClick);
    });
  }

  // Manejador de click de paginación
  async function handlePaginationClick(e) {
    e.preventDefault();
    e.stopPropagation();
    
    const page = this.dataset.page;
    if (!page) return;

    const formData = new FormData(document.getElementById('productos-filter-form'));
    const params = new URLSearchParams(formData);
    params.set('page', page);

    // Agregar efecto de carga
    const currentGrid = document.querySelector('.product-grid');
    if (currentGrid) {
      currentGrid.style.transition = 'opacity 0.2s ease';
      currentGrid.style.opacity = '0.6';
      currentGrid.style.pointerEvents = 'none';
    }

    try {
      const response = await fetch(`/productos?${params.toString()}`, {
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'text/html'
        }
      });

      if (response.ok) {
        const html = await response.text();
        
        // Extraer la grid de productos
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        const newGrid = doc.querySelector('.product-grid');
        const newPagination = doc.querySelector('#pagination-nav');
        
        if (newGrid && currentGrid) {
          // Animar salida
          currentGrid.style.opacity = '0';
          
          setTimeout(() => {
            // Reemplazar contenido
            currentGrid.innerHTML = newGrid.innerHTML;
            
            // Animar entrada
            currentGrid.style.opacity = '0';
            currentGrid.style.pointerEvents = 'auto';
            
            setTimeout(() => {
              currentGrid.style.opacity = '1';
            }, 10);
            
            // Reinicializar listeners
            reinitializeScripts(currentGrid.parentElement);
          }, 200);
        }

        // Actualizar paginación
        if (newPagination) {
          const paginationNav = document.getElementById('pagination-nav');
          if (paginationNav) {
            paginationNav.innerHTML = newPagination.innerHTML;
            initializePagination(document);
          }
        }

        // Scroll suave al inicio
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    } catch (error) {
      console.error('Error al cambiar página:', error);
      showToast('Error al cambiar página', 'danger');
      
      // Restaurar
      if (currentGrid) {
        currentGrid.style.opacity = '1';
        currentGrid.style.pointerEvents = 'auto';
      }
    }
    return false;
  }

  // Función para agregar producto HTML a la página de favoritos en tiempo real
  window.addProductHTMLToFavoritesPage = function(productId, productHTML) {
    // Buscar la página de favoritos
    const productGrid = document.querySelector('.product-grid');
    if (!productGrid) return; // Si no está en la página de favoritos, no hacer nada

    // Verificar si el producto ya existe
    const existingProduct = productGrid.querySelector(`[data-producto-id="${productId}"]`);
    if (existingProduct) return; // Ya existe, no agregar

    // Crear contenedor temporal para el HTML
    const temp = document.createElement('div');
    temp.innerHTML = productHTML;
    const newCard = temp.firstElementChild;

    if (newCard) {
      newCard.style.opacity = '0';
      newCard.style.transform = 'scale(0.8)';
      
      // Agregar a la grid
      productGrid.appendChild(newCard);

      // Animar entrada
      setTimeout(() => {
        newCard.style.transition = 'all 0.3s ease';
        newCard.style.opacity = '1';
        newCard.style.transform = 'scale(1)';
      }, 10);

      // Reinicializar listeners en el nuevo producto
      initializeProductListeners(newCard);
    }
  };

  // Función para agregar producto a la página de favoritos en tiempo real (legacy)
  window.addProductToFavoritesPage = function(productId, productCard) {
    // Esta función se mantiene por compatibilidad pero ahora se usa addProductHTMLToFavoritesPage
  };  // Función para auto-submit del formulario de filtros
  function initializeAutoFilter(form) {
    let filterTimeout;
    
    function debounce(fn, wait) {
      let t;
      return function (...args) {
        clearTimeout(t);
        t = setTimeout(() => fn.apply(this, args), wait);
      };
    }

    // Función para enviar filtros por AJAX
    async function submitFilterAjax() {
      const formData = new FormData(form);
      const params = new URLSearchParams(formData);
      
      // Agregar efecto de carga
      const currentGrid = document.querySelector('.product-grid');
      if (currentGrid) {
        currentGrid.style.transition = 'opacity 0.2s ease';
        currentGrid.style.opacity = '0.6';
        currentGrid.style.pointerEvents = 'none';
      }
      
      try {
        const response = await fetch(`${form.action}?${params.toString()}`, {
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'text/html'
          }
        });

        if (response.ok) {
          const html = await response.text();
          
          // Extraer solo la grid de productos del HTML
          const parser = new DOMParser();
          const doc = parser.parseFromString(html, 'text/html');
          const newGrid = doc.querySelector('.product-grid');
          
          if (newGrid && currentGrid) {
            // Animar salida
            currentGrid.style.opacity = '0';
            
            setTimeout(() => {
              // Reemplazar contenido
              currentGrid.innerHTML = newGrid.innerHTML;
              
              // Animar entrada
              currentGrid.style.opacity = '0';
              currentGrid.style.pointerEvents = 'auto';
              
              setTimeout(() => {
                currentGrid.style.opacity = '1';
              }, 10);
              
              // Reinicializar listeners en los nuevos productos
              reinitializeScripts(currentGrid.parentElement);
            }, 200);
          }
        }
      } catch (error) {
        console.error('Error al filtrar productos:', error);
        showToast('Error al filtrar productos', 'danger');
        
        // Restaurar
        if (currentGrid) {
          currentGrid.style.opacity = '1';
          currentGrid.style.pointerEvents = 'auto';
        }
      }
    }

    const inputs = Array.from(form.querySelectorAll('select, input[type="text"], input[type="number"], input[type="search"]'));

    inputs.forEach((el) => {
      if (el.tagName.toLowerCase() === 'select' || el.type === 'number') {
        el.addEventListener('change', () => {
          submitFilterAjax();
        });
      } else {
        // Búsqueda más rápida: 300ms en lugar de 450ms
        el.addEventListener('input', debounce(() => {
          submitFilterAjax();
        }, 300));
      }
    });
  }

  // Función para mostrar toasts
  function showToast(message, type) {
    let toastContainer = document.getElementById('toast-container');
    if (!toastContainer) {
      toastContainer = document.createElement('div');
      toastContainer.id = 'toast-container';
      toastContainer.className = 'toast-container position-fixed bottom-0 end-0 p-3';
      toastContainer.style.zIndex = '1055';
      document.body.appendChild(toastContainer);
    }

    const toast = document.createElement('div');
    const bg = type === 'success' ? 'bg-success' : (type === 'danger' ? 'bg-danger' : `bg-${type}`);

    toast.className = `toast fade show ${bg} text-white`;
    toast.innerHTML = `<div class="toast-body">${message}</div>`;
    toastContainer.appendChild(toast);

    setTimeout(() => {
      toast.classList.remove('show');
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  }

  // Función para abrir sidebar de perfil
  function openProfileSidebar() {
    const btn = document.getElementById('userButton');
    if (btn) btn.click();
    else {
      const sidebar = document.getElementById('profileSidebar');
      if (sidebar) sidebar.classList.add('open');
    }
  }

  // Actualizar enlace activo en navegación
  function updateActiveNav() {
    // Remover clase activa de TODOS los enlaces de navegación
    const allNavLinks = document.querySelectorAll('.main-nav a, .nav-home, .nav-products, .nav-contacts');
    allNavLinks.forEach(link => {
      link.classList.remove('active');
    });

    // Agregar clase activa al enlace correspondiente
    if (currentView === 'home' && navHome) {
      navHome.classList.add('active');
    } else if (currentView === 'productos' && navProducts) {
      navProducts.classList.add('active');
    } else if (currentView === 'contactos' && navContacts) {
      navContacts.classList.add('active');
    }
  }

  // Event listeners para navegación con validación
  if (navHome) {
    navHome.addEventListener('click', (e) => {
      if (currentView !== 'home') {
        e.preventDefault();
        const url = navHome.href || navHome.getAttribute('href');
        if (url) loadView('home', url);
      }
    });
  }

  if (navProducts) {
    navProducts.addEventListener('click', (e) => {
      if (currentView !== 'productos') {
        e.preventDefault();
        const url = navProducts.href || navProducts.getAttribute('href');
        if (url) loadView('productos', url);
      }
    });
  }

  if (navContacts) {
    navContacts.addEventListener('click', (e) => {
      if (currentView !== 'contactos') {
        e.preventDefault();
        const url = navContacts.href || navContacts.getAttribute('href');
        if (url) loadView('contactos', url);
      }
    });
  }

  // Inicializar vista actual y listeners
  updateActiveNav();
  initializeProductListeners(document);

  // Funciones de broadcast para sincronizar cambios en favoritos
  window.broadcastFavoriteRemoved = function(productId) {
    if (typeof BroadcastChannel !== 'undefined') {
      const channel = new BroadcastChannel('favorites_update');
      channel.postMessage({
        type: 'favorite_removed',
        productId: productId
      });
      channel.close();
    }
  };

  window.broadcastFavoriteAdded = function(productId) {
    if (typeof BroadcastChannel !== 'undefined') {
      const channel = new BroadcastChannel('favorites_update');
      channel.postMessage({
        type: 'favorite_added',
        productId: productId
      });
      channel.close();
    }
  };

  window.updateFavoritesCounter = function() {
    const favCountBadge = document.getElementById('favorites-count');
    if (favCountBadge) {
      const currentCount = parseInt(favCountBadge.textContent) || 0;
      const newCount = Math.max(0, currentCount - 1);
      favCountBadge.textContent = newCount;
      if (newCount === 0) favCountBadge.style.display = 'none';
    }
  };

  // Escuchar cambios de favoritos desde otras ventanas/tabs
  if (typeof BroadcastChannel !== 'undefined') {
    const channel = new BroadcastChannel('favorites_update');
    channel.addEventListener('message', (event) => {
      if (event.data.type === 'favorite_removed') {
        // Actualizar icono de favorito en la vista actual
        const productCard = document.querySelector(`[data-producto-id="${event.data.productId}"]`);
        if (productCard) {
          const favoriteBtn = productCard.querySelector('.favorite-btn');
          if (favoriteBtn) {
            const icon = favoriteBtn.querySelector('i');
            if (icon) {
              icon.classList.remove('fa-solid');
              icon.classList.add('fa-regular');
            }
            favoriteBtn.classList.add('btn-outline-warning');
            favoriteBtn.classList.remove('btn-warning');
            favoriteBtn.dataset.method = 'post';
            favoriteBtn.dataset.url = `/favorites?product_id=${event.data.productId}`;
          }
        }
        // Actualizar contador
        window.updateFavoritesCounter();
      }
    });
  }

  // Manejar botón atrás del navegador
  window.addEventListener('popstate', async (event) => {
    if (event.state && event.state.view === 'producto_show' && event.state.id) {
      await loadProductDetails(event.state.id);
    } else if (event.state && event.state.view) {
      await loadView(event.state.view, event.state.view === 'home' ? '/' : `/${event.state.view}`);
    }
  });

  // Función para crear y mostrar el overlay de carga
  function showLoadingOverlay() {
    let overlay = document.querySelector('.loading-overlay');
    if (!overlay) {
      overlay = document.createElement('div');
      overlay.className = 'loading-overlay';
      overlay.innerHTML = `
        <div class="loading-spinner"></div>
        <div class="loading-text">Cargando carrito...</div>
      `;
      document.body.appendChild(overlay);
    } else {
      overlay.classList.remove('fade-out');
    }
    return overlay;
  }

  // Función para ocultar el overlay de carga
  function hideLoadingOverlay(overlay) {
    if (overlay) {
      overlay.classList.add('fade-out');
      setTimeout(() => {
        if (overlay.parentNode) {
          overlay.remove();
        }
      }, 300);
    }
  }

  // Función para cargar el carrito dinámicamente con animación
  window.loadCartDynamic = async function() {
    const overlay = showLoadingOverlay();
    
    try {
      // Pequeño delay para que se vea la animación
      await new Promise(resolve => setTimeout(resolve, 500));

      const response = await fetch('/cart', {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'text/html'
        }
      });

      if (!response.ok) throw new Error('Error al cargar carrito');

      const html = await response.text();
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      
      // Buscar el contenido dinámico
      let newContent = doc.querySelector('#dynamic-content');
      if (!newContent) {
        newContent = doc.querySelector('main');
      }

      const currentContent = document.querySelector('#dynamic-content');
      if (currentContent && newContent) {
        // Fade out del contenido actual
        currentContent.style.transition = 'opacity 0.3s ease-out';
        currentContent.style.opacity = '0';

        // Esperar a que se fade out
        await new Promise(resolve => setTimeout(resolve, 300));

        // Reemplazar contenido
        currentContent.innerHTML = newContent.innerHTML;
        
        // Fade in del nuevo contenido
        currentContent.style.opacity = '1';
        
        // Cerrar offcanvas si está abierto
        const cartOffcanvas = document.querySelector('#cartOffcanvas');
        if (cartOffcanvas) {
          const bsOffcanvas = bootstrap.Offcanvas.getInstance(cartOffcanvas);
          if (bsOffcanvas) bsOffcanvas.hide();
        }
        
        // Reinicializar scripts
        if (typeof reinitializeScripts === 'function') {
          reinitializeScripts(currentContent);
        }
        
        // Reinicializar Wompi si existe - buscar el contenedor
        const wompiContainer = currentContent.querySelector('#wompi-container');
        if (wompiContainer) {
          const wompiScript = wompiContainer.querySelector('script[src*="wompi"]');
          if (wompiScript) {
            // Crear nuevo script que será ejecutado por el navegador
            const newWompiScript = document.createElement('script');
            newWompiScript.src = 'https://checkout.wompi.co/widget.js';
            
            // Copiar todos los atributos data- del script original
            Array.from(wompiScript.attributes).forEach(attr => {
              if (attr.name.startsWith('data-') || attr.name === 'src') {
                newWompiScript.setAttribute(attr.name, attr.value);
              }
            });
            
            // Limpiar el contenedor y agregar el nuevo script
            wompiContainer.innerHTML = '';
            wompiContainer.appendChild(newWompiScript);
          }
        }
        
        // Scroll a top con animación
        window.scrollTo({ top: 0, behavior: 'smooth' });
      } else {
        throw new Error('No se encontró contenido dinámico');
      }
    } catch (error) {
      console.error('Error al cargar carrito:', error);
      // Si falla, navegar normalmente
      window.location.href = '/cart';
    } finally {
      // Ocultar overlay después de un pequeño delay
      await new Promise(resolve => setTimeout(resolve, 300));
      hideLoadingOverlay(overlay);
    }
  };
});
