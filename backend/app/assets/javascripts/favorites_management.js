// Sistema de manejo de favoritos con actualización sin recargar

document.addEventListener('DOMContentLoaded', function() {
  // Interceptar clics en botones de eliminar favorito
  const favoriteContainer = document.querySelector('.product-grid') || document.body;

  favoriteContainer.addEventListener('click', async function(e) {
    const removeBtn = e.target.closest('.remove-favorite');
    
    if (!removeBtn) return;

    e.preventDefault();
    e.stopPropagation();

    const productCard = removeBtn.closest('.product-card');
    const productId = productCard?.dataset.productoId;
    const favoriteLink = removeBtn.closest('form');
    
    if (!favoriteLink) return;

    // Obtener la URL del formulario
    const form = removeBtn.closest('form');
    const action = form.getAttribute('action');

    if (!action) {
      console.error('No se encontró URL de acción');
      return;
    }

    removeBtn.disabled = true;
    const icon = removeBtn.querySelector('i');
    if (icon) icon.classList.add('icon-loading');

    try {
      const response = await fetch(action, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'application/json'
        }
      });

      if (response.ok) {
        // Animar salida del card
        productCard.style.transition = 'all 0.4s ease';
        productCard.style.opacity = '0';
        productCard.style.transform = 'scale(0.95) translateY(20px)';

        setTimeout(() => {
          productCard.remove();

          // Actualizar el contador de favoritos en la navbar
          updateFavoritesCounter();

          // Actualizar icono de favorito en productos dinámicos e home
          updateProductFavoriteStatus(productId);

          // Verificar si hay más favoritos
          checkEmptyFavorites();

          // Emitir evento para sincronizar en otras ventanas
          broadcastFavoriteRemoved(productId);

          showMessage('Producto eliminado de favoritos', 'success');
        }, 400);
      } else {
        showMessage('Error al eliminar favorito', 'error');
      }
    } catch (error) {
      console.error('Error:', error);
      showMessage('Error en la solicitud', 'error');
    } finally {
      removeBtn.disabled = false;
      if (icon) icon.classList.remove('icon-loading');
    }
  });

  // Actualizar contador de favoritos en navbar
  function updateFavoritesCounter() {
    const favCountBadge = document.getElementById('favorites-count');
    if (favCountBadge) {
      const currentCount = parseInt(favCountBadge.textContent) || 0;
      const newCount = Math.max(0, currentCount - 1);
      favCountBadge.textContent = newCount;
      if (newCount === 0) favCountBadge.style.display = 'none';
    }
  }

  // Actualizar estado de favoritos en otros lugares (home, productos dinámicos)
  function updateProductFavoriteStatus(productId) {
    if (!productId) return;

    console.log('Buscando producto con ID:', productId);

    // 1. Buscar en la vista dinámica (home/productos)
    const dynamicContent = document.getElementById('dynamic-content');
    if (dynamicContent) {
      const productCard = dynamicContent.querySelector(`[data-producto-id="${productId}"]`);
      if (productCard) {
        console.log('Encontrado en dynamic-content');
        updateFavoriteBtnUI(productCard, productId);
      }
    }

    // 2. Buscar en el carrito/offcanvas
    const cartBody = document.getElementById('cart-offcanvas-body');
    if (cartBody) {
      const productCard = cartBody.querySelector(`[data-producto-id="${productId}"]`);
      if (productCard) {
        console.log('Encontrado en cart-offcanvas');
        updateFavoriteBtnUI(productCard, productId);
      }
    }

    // 3. Buscar en el offcanvas de favoritos
    const favoritesBody = document.getElementById('favorites-offcanvas-body');
    if (favoritesBody) {
      const favoriteItem = favoritesBody.querySelector(`[data-favorite-id]`);
      if (favoriteItem) {
        console.log('Limpiando offcanvas de favoritos');
        // El item ya se removió en favorites_offcanvas.js
      }
    }

    // 4. Buscar en cualquier lugar del DOM con ese data-producto-id
    document.querySelectorAll(`[data-producto-id="${productId}"]`).forEach(card => {
      updateFavoriteBtnUI(card, productId);
    });
  }

  // Función para actualizar el UI del botón de favorito
  function updateFavoriteBtnUI(productCard, productId) {
    const favoriteBtn = productCard.querySelector('.favorite-btn');
    if (favoriteBtn) {
      const icon = favoriteBtn.querySelector('i');
      if (icon) {
        // Cambiar icono de relleno a outline
        icon.classList.remove('fa-solid');
        icon.classList.add('fa-regular');
      }
      
      // Cambiar clases del botón
      favoriteBtn.classList.remove('btn-warning');
      favoriteBtn.classList.add('btn-outline-warning');
      
      // Actualizar data attributes
      favoriteBtn.dataset.method = 'post';
      favoriteBtn.dataset.url = `/favorites?product_id=${productId}`;
    }
  }

  // Verificar si la lista de favoritos está vacía
  function checkEmptyFavorites() {
    const productGrid = document.querySelector('.product-grid');
    const remainingCards = productGrid ? productGrid.querySelectorAll('.product-card').length : 0;

    if (remainingCards === 0) {
      // Mostrar mensaje de vacío
      const container = document.querySelector('.container');
      if (container) {
        const emptyDiv = document.createElement('div');
        emptyDiv.style.textAlign = 'center';
        emptyDiv.style.padding = '40px 20px';
        emptyDiv.innerHTML = `
          <i class="fa-solid fa-heart" style="font-size: 48px; color: #ccc; margin-bottom: 16px; display: block;"></i>
          <p style="color: #999; font-size: 16px; margin: 0;">
            No tienes productos favoritos
          </p>
        `;

        if (productGrid) {
          productGrid.replaceWith(emptyDiv);
        } else {
          container.appendChild(emptyDiv);
        }
      }
    }
  }

  // Función auxiliar para mostrar mensajes con icono
  function showMessage(message, type) {
    // Usar el sistema de toast existente si está disponible
    if (typeof window.showToast === 'function') {
      window.showToast(message, type);
      return;
    }
    
    // Fallback a alerts tradicionales si no existe showToast
    const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
    const alertElement = document.createElement('div');
    alertElement.className = `alert ${alertClass} text-center position-fixed top-0 start-50 translate-middle-x mt-3 shadow`;
    alertElement.style.zIndex = '1056';
    alertElement.textContent = message;
    
    document.body.appendChild(alertElement);
    
    setTimeout(() => {
      alertElement.style.transition = 'opacity 0.3s ease';
      alertElement.style.opacity = '0';
      setTimeout(() => alertElement.remove(), 300);
    }, 3000);
  }

  // Broadcast para comunicar cambios a otras ventanas/tabs
  function broadcastFavoriteRemoved(productId) {
    if (typeof BroadcastChannel !== 'undefined') {
      const channel = new BroadcastChannel('favorites_update');
      channel.postMessage({
        type: 'favorite_removed',
        productId: productId
      });
      channel.close();
    }
  }

  // Escuchar cambios de favoritos desde otras ventanas/tabs
  if (typeof BroadcastChannel !== 'undefined') {
    const channel = new BroadcastChannel('favorites_update');
    channel.addEventListener('message', (event) => {
      if (event.data.type === 'favorite_removed') {
        updateProductFavoriteStatus(event.data.productId);
        updateFavoritesCounter();
      } else if (event.data.type === 'favorite_added') {
        // Si estamos en la página de favoritos y el offcanvas de favoritos tiene el producto, agregar
        const productGrid = document.querySelector('.product-grid');
        const favoritesBody = document.getElementById('favorites-offcanvas-body');
        
        // Si existe el offcanvas, actualizar su contenido
        if (favoritesBody) {
          reloadFavoritesOffcanvas();
        }
        
        // Si existe la grid de favoritos, verificar si ya tiene el producto
        if (productGrid) {
          const existingProduct = productGrid.querySelector(`[data-producto-id="${event.data.productId}"]`);
          if (!existingProduct) {
            // El producto no existe en la grid, se agregará cuando se refrescara
            // Por ahora solo actualizar el offcanvas
          }
        }
      }
    });
  }

  // Función para recargar el offcanvas de favoritos
  window.reloadFavoritesOffcanvas = function() {
    const favoritesBody = document.getElementById('favorites-offcanvas-body');
    if (!favoritesBody) return;

    // No usar await - ejecutar en background
    fetch('/favorites', {
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/html'
      }
    }).then(response => {
      if (response.ok) {
        return response.text();
      }
    }).then(html => {
      if (!html) return;
      // Extraer el contenido del partial de favoritos
      const temp = document.createElement('div');
      temp.innerHTML = html;
      
      const newContent = temp.querySelector('#favorites-offcanvas-content');
      if (newContent) {
        favoritesBody.innerHTML = newContent.innerHTML;
        // Reinicializar listeners después de actualizar
        if (typeof reinitializeFavoritesOffcanvas === 'function') {
          reinitializeFavoritesOffcanvas();
        }
      }
    }).catch(error => {
      console.error('Error al actualizar favoritos:', error);
    });
  };

  // Función para recargar la página de favoritos
  async function reloadFavoritesPage(productId) {
    try {
      const response = await fetch('/favorites', {
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'text/html'
        }
      });

      if (response.ok) {
        const html = await response.text();
        // Crear un contenedor temporal para parsear el HTML
        const temp = document.createElement('div');
        temp.innerHTML = html;

        // Buscar la nueva grid de productos
        const newGrid = temp.querySelector('.product-grid');
        const currentGrid = document.querySelector('.product-grid');
        
        if (newGrid && currentGrid) {
          // Encontrar el nuevo producto
          const newProduct = newGrid.querySelector(`[data-producto-id="${productId}"]`);
          if (newProduct) {
            // Verificar si el producto ya existe en la grid actual
            const existingProduct = currentGrid.querySelector(`[data-producto-id="${productId}"]`);
            if (!existingProduct) {
              // Agregarlo con animación
              newProduct.style.opacity = '0';
              newProduct.style.transform = 'scale(0.8)';
              currentGrid.appendChild(newProduct);

              // Animar la entrada
              setTimeout(() => {
                newProduct.style.transition = 'all 0.3s ease';
                newProduct.style.opacity = '1';
                newProduct.style.transform = 'scale(1)';
              }, 50);
            }
          }
        } else if (newGrid && !currentGrid) {
          // Si no existe grid, crear una desde cero
          const container = document.querySelector('.container');
          if (container) {
            const gridDiv = document.createElement('div');
            gridDiv.className = 'product-grid';
            gridDiv.style.display = 'grid';
            gridDiv.style.gridTemplateColumns = 'repeat(5, 1fr)';
            gridDiv.style.gap = '24px';
            gridDiv.innerHTML = newGrid.innerHTML;
            container.appendChild(gridDiv);
          }
        }
      }
    } catch (error) {
      console.error('Error al recargar favoritos:', error);
    }
  }
});