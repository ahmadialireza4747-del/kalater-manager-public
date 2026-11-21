// frontend/vite.config.ts
// Foundation-System / Scaffold-Module: Vite 5.4.11 configuration allowing reverse-proxy Host headers for custom domain testing.

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5173,
    allowedHosts: true
  }
});
