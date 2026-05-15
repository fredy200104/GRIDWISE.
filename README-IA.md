# GridWise Assistant - Integración de IA Institucional

Este documento detalla la arquitectura técnica e integración del asistente de inteligencia artificial (GridWise Assistant) dentro del ecosistema GridWise.

## 1. Arquitectura General

El asistente de GridWise está construido bajo una arquitectura cliente-servidor interactiva:
*   **Frontend (Flutter):** Se encarga de la interfaz de usuario (UI), capturando las interacciones, gestionando la conexión por WebSockets (Socket.IO) y mostrando el historial de mensajes de manera reactiva mediante `ChangeNotifier`.
*   **Backend (Node.js + Express):** Actúa como middleware de orquestación. Mantiene una conexión persistente bidireccional con el frontend, procesa la seguridad mediante tokens JWT de Firebase, y gestiona las peticiones asíncronas hacia la API de Google Gemini.
*   **Inteligencia Artificial (Gemini):** Se utiliza el SDK `@google/genai` (modelo `gemini-2.5-flash`) para el procesamiento de lenguaje natural y generación de respuestas contextuales.
*   **Base de Datos (Firestore):** Se almacena el historial de conversaciones y se obtienen los datos de consumo en tiempo real de los dispositivos IoT para nutrir el contexto del LLM.

## 2. Integración Filosófica e Institucional

GridWise Assistant no es solo una herramienta técnica; ha sido dotado de una personalidad orientada al crecimiento humano y la ética. 

### Declaración Institucional
La siguiente declaración ha sido integrada como pilar central del sistema:
> *"Soy LIBRE, AUTÓNOMO Y RESPONSABLE a través del diálogo y la construcción, como ideal regulativo; me dirijo, controlo y dicto mis propias leyes."*

### Implementación Técnica de la Filosofía
Esta identidad se integra en múltiples capas del software:
1.  **Componente Visual e Informativo (Frontend):** 
    En `lib/services/chat_service.dart`, el mensaje de bienvenida expone la declaración directamente al usuario cada vez que se inicia una nueva conversación, estableciendo el tono reflexivo de inmediato.
2.  **Filosofía Orientadora del Prompt (Backend):**
    En `gridwise-backend/chatService.js`, el `SYSTEM_PROMPT` inyecta estas directrices directamente en el "cerebro" de Gemini. Se le instruye explícitamente para que sus respuestas promuevan el desarrollo humano, la transformación positiva, el bienestar integral y la responsabilidad social ecológica.

## 3. Integración de Contexto de Consumo en Tiempo Real

Para que la IA no ofrezca respuestas genéricas, sino consejos aplicables a la realidad del usuario, se implementó una técnica de **RAG (Retrieval-Augmented Generation)** simplificada:

*   **Función `getUserContext(userId)`:** Antes de llamar a Gemini, el backend consulta Firestore para extraer:
    *   Todos los dispositivos IoT conectados actualmente.
    *   Su consumo instantáneo en vatios (`last_power_watts`).
    *   Su estado de conexión.
    *   Las alertas o recomendaciones pendientes generadas por el motor de reglas de GridWise.
*   **Inyección Dinámica:** Esta información estructurada se concatena dinámicamente al `systemInstruction` de Gemini en cada interacción. Así, cuando el usuario pregunta *"¿Cómo reduzco mi consumo hoy?"*, Gemini "sabe" exactamente qué dispositivos están consumiendo en ese preciso instante.

## 4. Gestión de Conexiones (Socket.IO)

Se ha configurado una conexión robusta que se adapta al entorno de despliegue:
*   El cliente en Flutter detecta dinámicamente si se está ejecutando en la **Web (Chrome)**, **Android Emulator** o un **dispositivo real**, inyectando la IP correspondiente (`localhost` o `10.0.2.2`).
*   Se forzó la actualización del Token de Firebase (`getIdToken(true)`) antes de cada conexión para prevenir denegaciones de servicio por caducidad de sesión.
