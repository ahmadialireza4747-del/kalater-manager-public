# frontend/Dockerfile
# Foundation-System / Scaffold-Module: Docker container for React 18 + Vite 5.4.11 development placeholder.

FROM node:20.18.1-alpine
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5173"]
