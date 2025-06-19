import { Application } from "@hotwired/stimulus"
document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("form-proveedor");
  const contenedor = document.getElementById("contenedor-proveedores");
  const plantilla = document.getElementById("card-template").firstElementChild;

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const data = new FormData(form);

    const nueva = plantilla.cloneNode(true);
    nueva.querySelector(".nombre").textContent = data.get("nombre");
    nueva.querySelector(".ubicacion").textContent = data.get("ubicacion");
    nueva.querySelector(".tipo").textContent = data.get("tipo");
    nueva.querySelector(".numero").textContent = data.get("numero");
    nueva.querySelector(".correo").textContent = data.get("correo");

    contenedor.appendChild(nueva);
    form.reset();
    bootstrap.Modal.getInstance(document.getElementById("modalProveedor")).hide();
  });
});

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
