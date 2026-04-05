# etapa build
FROM node:22-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# etapa final
FROM node:22-alpine

WORKDIR /app
RUN addgroup -g 1001 -S nodejs && \
    adduser -S roxsapp -u 1001

COPY --from=builder /app /app
RUN mkdir -p /app/logs && \
    chown -R roxsapp:nodejs /app

USER roxsapp

EXPOSE 3000

ENV NODE_ENV=development
ENV DEBUG=app:*
ENV LOG_LEVEL=debug

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["npm", "run", "start"]