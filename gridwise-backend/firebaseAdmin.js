const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const keyPath = path.join(__dirname, 'serviceAccountKey.json');

try {
  const credential = fs.existsSync(keyPath)
    ? admin.credential.cert(require(keyPath))   // Usa el JSON si existe
    : admin.credential.applicationDefault();     // Fallback a ADC

  admin.initializeApp({ credential });
  console.log('✅ Firebase Admin inicializado');
} catch (e) {
  console.log('⚠️ Firebase Admin ya estaba inicializado o falta configuración: ', e.message);
}

const db = admin.firestore();
module.exports = { admin, db };
