// Shows chat pushes while the app is closed or in the background.
importScripts('firebase-config.js');

if (self.FIREBASE_CONFIG && self.FIREBASE_CONFIG.projectId) {
  importScripts('https://www.gstatic.com/firebasejs/13.1.0/firebase-app-compat.js');
  importScripts('https://www.gstatic.com/firebasejs/13.1.0/firebase-messaging-compat.js');
  firebase.initializeApp(self.FIREBASE_CONFIG);
  // Notification payloads are displayed by the SDK; this keeps the worker
  // registered for them.
  firebase.messaging();
}
