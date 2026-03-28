const CACHE_NAME = 'igelpflegestation-v2.5.79';
const urlsToCache = [
  './icon-192.png',
  './icon-512.png'
];

// Install: nur Icons cachen, HTML/JS immer frisch
self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(urlsToCache).catch(err => Promise.resolve());
    })
  );
});

// Activate: alte Caches sofort löschen + Kontrolle übernehmen
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch: Network-first für HTML/JS, Cache-first nur für Icons
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  const isIcon = url.pathname.endsWith('.png');

  if (isIcon) {
    // Cache-first für Icons
    event.respondWith(
      caches.match(event.request).then((cached) => {
        return cached || fetch(event.request).then((response) => {
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
          return response;
        });
      })
    );
  } else {
    // Network-first für HTML/JS/CSS — immer aktuell
    event.respondWith(
      fetch(event.request).then((response) => {
        return response;
      }).catch(() => {
        return caches.match(event.request).then(cached => {
          return cached || caches.match('./index.html');
        });
      })
    );
  }
});
