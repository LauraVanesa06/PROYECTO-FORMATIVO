// Manejo del offcanvas de favoritos

document.addEventListener('DOMContentLoaded', function() {
  // Obtener el offcanvas de favoritos
  const favoritesOffcanvas = document.getElementById('favoritesOffcanvas');
  
  if (!favoritesOffcanvas) return;

  // Actualizar el contenido del offcanvas cuando se abre
  favoritesOffcanvas.addEventListener('show.bs.offcanvas', async function() {
    const favoritesBody = document.getElementById('favorites-offcanvas-body');
    
    try {
      const response = await fetch('/favorites', {
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'text/html'
        }
      });

      if (response.ok) {
        const html = await response.text();
        // Extraer el contenido del partial de favoritos
        const temp = document.createElement('div');
        temp.innerHTML = html;
        
        const newContent = temp.querySelector('#favorites-offcanvas-content');
        if (newContent && favoritesBody) {
          favoritesBody.innerHTML = newContent.innerHTML;
          // Reinicializar listeners después de actualizar
          reinitializeFavoritesOffcanvas();
        }
      }
    } catch (error) {
      console.error('Error al actualizar favoritos:', error);
    }
  });

  // Event delegation para botones dentro del offcanvas
  favoritesOffcanvas.addEventListener('click', async function(e) {
    // Botón agregar al carrito
    if (e.target.closest('.btn-add-to-cart')) {
      const btn = e.target.closest('.btn-add-to-cart');
      const productId = btn.dataset.productId;
      const url = btn.dataset.url;
      
      if (!url) return;

      btn.disabled = true;
      const icon = btn.querySelector('i');
      if (icon) icon.classList.add('icon-loading');

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
          console.log('Cart response:', data);
          
          // Actualizar contador del carrito dinámicamente
          const cartCountBadge = document.getElementById('cart-count');
          console.log('Cart count badge:', cartCountBadge);
          console.log('Data count:', data.count);
          if (cartCountBadge && data.count !== undefined) {
            // Solo actualizar el número, no el innerHTML completo
            cartCountBadge.firstChild.textContent = data.count;
            cartCountBadge.style.display = data.count > 0 ? 'inline' : 'none';
            console.log('Updated cart count to:', data.count);
          }

          // Actualizar el contenido del carrito offcanvas
          if (data.cart_html) {
            const cartBody = document.querySelector('#cart-offcanvas-body');
            if (cartBody) {
              cartBody.innerHTML = data.cart_html;
            }
          }

          showToast('Producto agregado al carrito', 'success');
        } else {
          showToast('Error al agregar al carrito', 'danger');
        }
      } catch (error) {
        console.error('Error:', error);
        showToast('Error en la solicitud', 'danger');
      } finally {
        btn.disabled = false;
        if (icon) icon.classList.remove('icon-loading');
      }
    }
  });

  // Función para recargar el contenido del offcanvas
  function reloadFavoritesOffcanvasContent() {
    const favoritesBody = document.getElementById('favorites-offcanvas-body');
    if (!favoritesBody) return;

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
      const temp = document.createElement('div');
      temp.innerHTML = html;
      
      const newContent = temp.querySelector('#favorites-offcanvas-content');
      if (newContent) {
        favoritesBody.innerHTML = newContent.innerHTML;
        reinitializeFavoritesOffcanvas();
      }
    }).catch(error => {
      console.error('Error al actualizar favoritos:', error);
    });
  }

  // Función para reinicializar listeners del offcanvas
  function reinitializeFavoritesOffcanvas() {
    const favoritesBody = document.getElementById('favorites-offcanvas-body');
    if (!favoritesBody) return;

    const favoriteBtns = favoritesBody.querySelectorAll('.favorite-btn');
    favoriteBtns.forEach(btn => {
      const newBtn = btn.cloneNode(true);
      btn.parentNode.replaceChild(newBtn, btn);
      
      newBtn.addEventListener('click', async (e) => {
        e.preventDefault();
        e.stopPropagation();

        const url = newBtn.dataset.url;
        const method = (newBtn.dataset.method || 'post').toUpperCase();
        const productId = newBtn.dataset.productId;

        if (!url) return;

        const icon = newBtn.querySelector('i');
        if (icon) {
          icon.classList.add('icon-loading');
        }
        newBtn.disabled = true;

        if (method === 'DELETE') {
          const favoriteItem = newBtn.closest('.favorite-item');
          if (favoriteItem) {
            favoriteItem.style.transition = 'all 0.3s ease';
            favoriteItem.style.opacity = '0';
            favoriteItem.style.transform = 'translateX(100%)';
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

          if (response.ok) {
            if (method === 'DELETE') {
              setTimeout(() => {
                const favoriteItem = newBtn.closest('.favorite-item');
                if (favoriteItem) favoriteItem.remove();
                updateFavoritesCounter();
              }, 300);
            }
            showToast('Removido de favoritos', 'success');
            broadcastFavoriteRemoved(productId);
          } else {
            if (method === 'DELETE') {
              const favoriteItem = newBtn.closest('.favorite-item');
              if (favoriteItem) {
                favoriteItem.style.opacity = '1';
                favoriteItem.style.transform = 'translateX(0)';
              }
            }
            showToast('Error al actualizar favorito', 'danger');
          }
        } catch (error) {
          console.error('Error:', error);
          if (method === 'DELETE') {
            const favoriteItem = newBtn.closest('.favorite-item');
            if (favoriteItem) {
              favoriteItem.style.opacity = '1';
              favoriteItem.style.transform = 'translateX(0)';
            }
          }
          showToast('Error al actualizar favorito', 'danger');
        } finally {
          if (icon) {
            icon.classList.remove('icon-loading');
          }
          newBtn.disabled = false;
        }
      });
    });
  }

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

  if (typeof BroadcastChannel !== 'undefined') {
    const channel = new BroadcastChannel('favorites_update');
    channel.addEventListener('message', (event) => {
      if (event.data.type === 'favorite_removed' || event.data.type === 'favorite_added') {
        reloadFavoritesOffcanvasContent();
      }
    });
  }

  window.reloadFavoritesOffcanvas = reloadFavoritesOffcanvasContent;
});

