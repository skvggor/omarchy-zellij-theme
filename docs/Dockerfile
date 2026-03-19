FROM node:22-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json ./
RUN npm install

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

FROM caddy:2-alpine
COPY --from=builder /app/dist /srv

EXPOSE 3011

CMD ["caddy", "file-server", "--root", "/srv", "--listen", ":3011"]
