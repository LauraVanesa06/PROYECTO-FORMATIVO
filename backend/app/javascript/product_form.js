document.addEventListener("turbo:load", () => {
  console.log("🚀 JS de producto cargado");

  const nombreInput = document.getElementById("edit-nombre");
  const codigoInput = document.getElementById("edit-codigo_producto");

  if (!nombreInput || !codigoInput) {
    console.warn("⚠️ No se encontraron los inputs");
    return;
  }

  nombreInput.addEventListener("input", () => {
    const nombre = nombreInput.value.trim();
    if (nombre.length === 0) {
      codigoInput.value = "";
      return;
    }

    fetch(`/products/generate_code?nombre=${encodeURIComponent(nombre)}`)
      .then((res) => res.json())
      .then((data) => {
        console.log("📦 Código generado:", data.codigo);
        codigoInput.value = data.codigo;
      })
      .catch((err) => console.error("❌ Error en fetch:", err));
  });
});