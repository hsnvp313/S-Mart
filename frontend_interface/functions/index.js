const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.deleteUserAccount = functions.https.onCall(async (data, context) => {
  const uid = data.uid;

  if (!uid) {
    throw new functions.https.HttpsError("invalid-argument", "Missing UID");
  }

  try {
    // Delete from Authentication
    await admin.auth().deleteUser(uid);

    // Delete from Firestore (users collection)
    await admin.firestore().collection('users').doc(uid).delete();

    return { success: true };
  } catch (error) {
    console.error("Error deleting user:", error);
    throw new functions.https.HttpsError("internal", error.message || "Unknown error occurred");
  }
});
