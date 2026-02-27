const CACHE_NAME = 'igelpflege-v4';
const ASSETS = [
  '/IGELSTATION_nei/',
  '/IGELSTATION_nei/index.html',
  '/IGELSTATION_nei/manifest.json',
  '/IGELSTATION_nei/icon-192.png',
  '/IGELSTATION_nei/icon-512.png'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(ASSETS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    ).then(() => clients.claim())
  );
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request)
      .then(cached => cached || fetch(e.request))
  );
});
