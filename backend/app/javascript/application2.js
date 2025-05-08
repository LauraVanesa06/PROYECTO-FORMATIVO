function moverSlider(id, direccion) {
    const slider = document.getElementById(id);
    const carta = slider.querySelector(".carta");
    if (!carta) return;
  
    const cartaStyle = getComputedStyle(slider);
    const gap = parseInt(cartaStyle.gap || "20", 10); // lee el gap del CSS
    const cartaWidth = carta.offsetWidth + gap;
  
    const nuevoScroll = slider.scrollLeft + direccion * cartaWidth;
  
    slider.scrollTo({ left: nuevoScroll, behavior: "smooth" });
}