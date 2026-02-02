const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationOnDetection = functions.firestore
  .document("detections/{docId}")
  .onCreate(async (snap, context) => {
    const docData = snap.data();

    const detectedLabel = docData.label || "Object"; 
    const imageUrl = docData.image_url || ""; 

    const message = {
      notification: {
        title: `⚠️ Alert: ${detectedLabel} detected!`, 
        body: `Scarecrow system identified: ${detectedLabel}`,
      },
      data: {
        imageUrl: imageUrl,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      token: "Test ", // بدل topic
    };

    try {
      await admin.messaging().send(message);
      console.log("Notification sent successfully for label:", detectedLabel);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
    return null;
  });
