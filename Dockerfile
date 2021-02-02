FROM alpine:latest
RUN apk add --no-cache nodejs npm
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY . /app
RUN mkdir -p /app; chown -R appuser:appgroup /app; chown -R appuser:appgroup /app/node_modules
USER appuser
RUN npm install
EXPOSE 3000
CMD ["node", "app.js"]
