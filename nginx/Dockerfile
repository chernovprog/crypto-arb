# ==================== Stage 1: Build Frontend ====================
FROM node:20-alpine AS frontend-build
WORKDIR /app

COPY frontend/package*.json ./
RUN npm ci --frozen-lockfile

COPY frontend/ .
RUN npm run build

# ==================== Stage 2: Final Nginx Image ====================
FROM nginx:stable-alpine
RUN rm -rf /usr/share/nginx/html/*

COPY --from=frontend-build /app/dist /usr/share/nginx/html

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]