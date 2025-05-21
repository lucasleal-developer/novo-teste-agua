FROM node:20-alpine AS build

WORKDIR /app

# Copiar arquivos de configuração
COPY package*.json ./
COPY astro.config.mjs ./
COPY tsconfig.json ./

# Instalar dependências
RUN npm ci

# Copiar código fonte
COPY src/ ./src/
COPY public/ ./public/

# Construir o projeto
RUN npm run build

# Estágio de produção
FROM nginx:alpine AS runtime

WORKDIR /usr/share/nginx/html

# Copiar os arquivos estáticos gerados
COPY --from=build /app/dist/ ./

# Configuração do Nginx para SPA
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expor a porta
EXPOSE 80

# Comando para iniciar o servidor
CMD ["nginx", "-g", "daemon off;"]
