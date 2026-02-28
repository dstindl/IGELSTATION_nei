// Igelpflege Pro — Service Worker v1.8.46
// Cacht die App-Shell für Offline-Nutzung

const CACHE_NAME = 'igelpflege-v1.8.46';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.svg',
  './icon-512.svg',
  // CDN-Ressourcen (React, Babel, Firebase, Tailwind)
  'https://unpkg.com/react@18/umd/react.production.min.js',
  'https://unpkg.com/react-dom@18/umd/react-dom.production.min.js',
  'https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/7.23.2/babel.min.js',
  'https://cdn.tailwindcss.com',
];

// Install — alle Assets cachen
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      // Core-Dateien immer cachen, CDN optional (kann offline fehlen)
      return cache.addAll(['./index.html', './manifest.json', './icon-192.svg', './icon-512.svg'])
        .then(() => {
          // CDN-Assets best-effort cachen
          return Promise.allSettled(
            ASSETS.slice(4).map(url =>
              fetch(url).then(r => r.ok ? cache.put(url, r) : null).catch(() => null)
            )
          );
        });
    }).then(() => self.skipWaiting())
  );
});

// Activate — alte Caches löschen
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys
          .filter(key => key !== CACHE_NAME)
          .map(key => caches.delete(key))
      )
    ).then(() => self.clients.claim())
  );
});

// Fetch — Cache First für App-Assets, Network First für Firebase API
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);

  // Firebase-Anfragen immer live (nie cachen)
  if (
    url.hostname.includes('firestore.googleapis.com') ||
    url.hostname.includes('firebase') ||
    url.hostname.includes('identitytoolkit')
  ) {
    return; // Browser standard fetch
  }

  // Alles andere: Cache First, Fallback auf Network
  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;
      return fetch(event.request).then(response => {
        // Nur gültige GET-Antworten cachen
        if (
          response &&
          response.status === 200 &&
          event.request.method === 'GET' &&
          !url.hostname.includes('localhost')
        ) {
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
        }
        return response;
      }).catch(() => {
        // Offline-Fallback: App-Shell zurückgeben
        if (event.request.mode === 'navigate') {
          return caches.match('./index.html');
        }
      });
    })
  );
});

// Push-Nachrichten (optional, für spätere Erweiterung)
self.addEventListener('push', event => {
  const data = event.data?.json() || { title: 'Igelpflege Pro', body: 'Neue Nachricht' };
  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: './icon-192.svg',
      badge: './icon-192.svg',
    })
  );
});
