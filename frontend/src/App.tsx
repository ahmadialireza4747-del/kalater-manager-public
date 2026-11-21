// frontend/src/App.tsx
// Foundation-System / Scaffold-Module: Phase 1 placeholder screen confirming Nginx reverse proxy routing to frontend and API.

import React from 'react';

export default function App() {
  return (
    <main style={{ fontFamily: 'system-ui, sans-serif', maxWidth: 640, margin: '4rem auto', padding: '0 1.5rem' }}>
      <h1>Kalate Manager — Backend Phase Active</h1>
      <p>Reverse proxy routing is active. Full UI implementation begins in Phase 3 after backend verification.</p>
      <p>
        API Health Endpoint: <a href="/api/v1/health">/api/v1/health</a> | Swagger UI: <a href="/swagger">/swagger</a>
      </p>
    </main>
  );
}
