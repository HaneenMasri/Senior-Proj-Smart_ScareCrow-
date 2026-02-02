//web/icons/firebase-messaging-sw.js
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

const firebaseConfig = {
  apiKey: "AIzaSyDCkxmWygh-ybEmYO9vOhBzlaOaf4VUV4g",
  authDomain: "scarecrow-e4060.firebaseapp.com",
  projectId: "scarecrow-e4060",
  storageBucket: "scarecrow-e4060.firebasestorage.app",
  messagingSenderId: "723232938358",
  appId: "1:723232938358:web:243e8394dc851d2e0c4257"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Message received in background: ", payload);
});