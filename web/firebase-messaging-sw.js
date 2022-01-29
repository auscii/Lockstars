importScripts('https://www.gstatic.com/firebasejs/8.1.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.1.1/firebase-messaging.js');

firebase.initializeApp({
    apiKey: "AIzaSyCjrQH97Uz8oDE3iysKRQKVdUOz-_-cru0",
    authDomain: "locky-app.firebaseapp.com",
    projectId: "locky-app",
    storageBucket: "locky-app.appspot.com",
    messagingSenderId: "435708045284",
    appId: "1:435708045284:web:bacabb52f214038da049f1",
    measurementId: "G-3L8MWELLFM"
});

const messaging = firebase.messaging();