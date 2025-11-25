# config/initializers/pagy.rb
# OPTIMIZACIÓN: Configuración de Pagy para máxima velocidad

Pagy::DEFAULT[:items]      = 12    # items por página
Pagy::DEFAULT[:size]       = 7     # cantidad de páginas mostradas
Pagy::DEFAULT[:page_param] = :page
