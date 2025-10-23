const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const { processLessons } = require('./lesson_parser');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function importData() {
  try {
    // Process lessons from markdown files
    const lessons = processLessons();
    for (const lesson of lessons) {
      const lessonId = lesson.id;
      delete lesson.id;
      
      await db.collection('lessons').doc(lessonId).set(lesson);
      console.log(`Imported lesson: ${lessonId}`);
    }

    console.log('Data import completed successfully!');
  } catch (error) {
    console.error('Error importing data:', error);
  } finally {
    process.exit();
  }
}

importData();