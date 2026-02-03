// functions/index.js

// 1. تعريف onDocumentCreated من مكتبة v2
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

// 2. تعريف admin للتعامل مع Firestore و FCM
const admin = require("firebase-admin");

// 3. تهيئة التطبيق (ضرورية جداً ليعمل admin)
admin.initializeApp();

exports.sendNotificationOnDetection = onDocumentCreated("detections/{docId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.log("No data found in snapshot");
        return null;
    }

    const docData = snapshot.data();
    const detectedLabel = docData.label || "Object";

    try {
        // جلب التوكن الذي رفعه التطبيق (APK) تلقائياً إلى Firestore
        const tokenDoc = await admin.firestore().collection("users_tokens").doc("admin_user").get();
        const registrationToken = tokenDoc.data()?.token;

        if (!registrationToken) {
            console.log("No registration token found in database.");
            return null;
        }

        const message = {
            notification: {
                title: `⚠️ Alert: ${detectedLabel} detected!`,
                body: `Scarecrow system identified: ${detectedLabel}`,
            },
            token: registrationToken,
        };

        const response = await admin.messaging().send(message);
        console.log("Notification sent successfully:", response);
    } catch (error) {
        console.error("Error sending notification:", error);
    }
    return null;
});