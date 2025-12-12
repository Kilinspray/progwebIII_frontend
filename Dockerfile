# =============================================
# Flutter Web App - Multi-stage Dockerfile
# Optimizado para deploy no Render
# =============================================

# ---------------------------------------------
# Stage 1: Build Flutter Web
# ---------------------------------------------
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS builder

# Define diretório de trabalho
WORKDIR /app

# Copia pubspec primeiro para cache de dependências
COPY pubspec.yaml pubspec.lock* ./

# Instala dependências (cached layer)
RUN flutter pub get

# Copia o restante do código
COPY . .

# Build da versão web otimizada para produção
RUN flutter build web --release --web-renderer html

# ---------------------------------------------
# Stage 2: Serve com Nginx
# ---------------------------------------------
FROM nginx:alpine AS production

# Remove config default do nginx
RUN rm -rf /usr/share/nginx/html/*

# Copia os arquivos buildados do Flutter
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copia configuração customizada do nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expõe porta 80 (Render usa $PORT, redirecionamos no nginx.conf)
EXPOSE 80

# Health check para Render
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Inicia nginx em foreground
CMD ["nginx", "-g", "daemon off;"]
