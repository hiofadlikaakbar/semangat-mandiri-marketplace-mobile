importScripts(
  "https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js",
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js",
);

firebase.initializeApp({
  apiKey: "AIzaSyCQa8o5lQc8Izf1lPwxwcAkbI9Yt7Qwwro",
  authDomain: "marketplace-uts.firebaseapp.com",

  projectId: "marketplace-uts",

  messagingSenderId: "608464027335",
  appId: "1:608464027335:web:6b8f04fbb00fdbaeb9c8e2",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log("Background message ", payload);
});
