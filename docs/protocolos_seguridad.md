# 🛡️ GridWise — Protocolos de Seguridad y Arquitectura

**Fecha:** 05 de Mayo de 2026  
**Documento:** Matriz de Ciberseguridad y Protocolos de Aislamiento de Datos.

Este documento describe las barreras tecnológicas y metodologías de seguridad implementadas en las tres capas principales de la plataforma: **Frontend (Flutter)**, **Backend (Node.js)** y **Hardware (IoT / MQTT)**.

---

## 1. Seguridad de Base de Datos y Aislamiento (Firestore Rules)
El modelo de almacenamiento en la nube (Firebase Firestore) sigue el principio de **Mínimo Privilegio (PoLP)**. La lógica de negocio está delegada a las Reglas de Seguridad Criptográficas, asegurando que ninguna falla en el cliente comprometa los datos globales.

*   **Aislamiento de Usuarios (Tenant Isolation):**
    Mediante la regla `isOwner(userId) { return request.auth != null && request.auth.uid == userId; }`, el sistema asegura matemáticamente que ningún usuario puede leer, modificar, interceptar o escribir en la rama de base de datos de otro usuario. Cada usuario tiene una "bóveda" aislada.
*   **Restricción de Borrado (Anti-Tampering):**
    Ramas críticas relacionadas a datos unificados de sensores (`device_data_unified`) o al perfil raíz del usuario (`/users/{uid}`) tienen un bloqueo permanente (`allow delete: if false;`). Esto garantiza que el historial de consumo no pueda ser borrado maliciosamente para alterar recibos de cobro o simulaciones.

---

## 2. Autenticación y Manejo de Sesiones
*   **Tokens JWT (JSON Web Tokens):**
    El sistema no traslada contraseñas por la red para operaciones habituales. Al iniciar sesión (con correo/contraseña o Google Auth OAuth 2.0), el usuario recibe un JWT de corta duración firmado por Google Identity Services.
*   **Middleware de Validación REST:**
    Todas las rutas del servidor (API) Node.js están protegidas por un intermediario (Middleware). La aplicación debe inyectar el token en las cabeceras HTTP (`Authorization: Bearer <token>`). El servidor valida criptográficamente este token usando `firebase-admin` (`admin.auth().verifyIdToken()`). Si se omite o es inválido, retorna el código de error `401 Unauthorized`.

---

## 3. Seguridad Hardware e IoT (Anti-Spoofing de Sensores)
Dado que los microcontroladores (ESP32) están expuestos físicamente y pueden ser robados, la arquitectura IoT prohíbe alojar credenciales maestras dentro del hardware.

*   **Arquitectura Indirecta de Escritura:**
    Los ESP32 no tienen permiso directo para escribir en la base de datos Firestore. Actúan a través del protocolo MQTT, vigilado por el servidor Node.js.
*   **Autenticación Hash SHA-256 (Tokens de Hardware):**
    1. Al registrar un sensor, el backend genera un `device_token` (UUID o cadena segura).
    2. El backend procesa este token y guarda en la base de datos **solamente un Hash** Criptográfico de un solo sentido (`token_hash = SHA-256(device_token)`).
    3. El microcontrolador ESP32 envía su token en cada mensaje MQTT al intermediario (Broker EMQX).
    4. El servidor extrae el payload MQTT, cifra el token entrante en SHA-256 y lo compara con la base de datos.
    *Consecuencia:* Si la red MQTT es interceptada o vulnerada, un atacante no puede extraer la identidad maestra de escritura.

---

## 4. Seguridad a Nivel de Red y Capa de Presentación
*   **Políticas de Origen (CORS - Cross-Origin Resource Sharing):**
    El servidor REST implementa políticas CORS que instruyen a los navegadores web a rechazar llamadas API que provengan de dominios ajenos al ecosistema oficial de GridWise (previniendo ataques XSS/CSRF).
*   **Data Sanitization (Limpieza de Entradas):**
    Tanto la aplicación móvil/web como el backend implementan Expresiones Regulares (`RegExp`) estrictas antes de enviar peticiones (ej. `^[^\s@]+@[^\s@]+\.[^\s@]+$`). Esto elimina riesgos de Inyección SQL/NoSQL clásica.
*   **Cifrado en Tránsito (TLS/SSL):**
    Las comunicaciones entre Flutter, Firebase y el backend (a excepción del entorno localhost durante desarrollo) operan exclusivamente sobre el protocolo encriptado `HTTPS`, impidiendo ataques de interceptación (Man-in-the-Middle).

---

**Estado Final:** 🟢 *Implementado y auditado.*
