# syntax=docker/dockerfile:1

# Imagen base de Ruby
ARG RUBY_VERSION=3.2.3
FROM ruby:$RUBY_VERSION-slim AS base

# Configurar el directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config libgmp-dev curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Definir entorno de desarrollo
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_BIN="/usr/local/bundle/bin" \
    PATH="/usr/local/bundle/bin:$PATH"

# Copiar el archivo de Gems y luego instalarlas
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copiar el código de la aplicación
COPY . .

# Permitir cambios en caliente
EXPOSE 3000

# Evitar errores al reiniciar el servidor
ENTRYPOINT ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0 -p 3000"]

