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
FROM node:20-alpine AS runtime

WORKDIR /app

# Copiar arquivos de configuração e dependências
COPY --from=build /app/package*.json ./
COPY --from=build /app/dist/ ./dist/

# Instalar apenas dependências de produção
RUN npm ci --omit=dev

# Expor a porta
EXPOSE 4321

# Comando para iniciar o servidor
CMD ["node", "./dist/server/entry.mjs"]
