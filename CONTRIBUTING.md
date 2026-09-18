# 🤝 Guía de Contribución — GridWise

¡Gracias por tu interés en contribuir a **GridWise**! Este documento describe el proceso para contribuir al proyecto de forma efectiva.

---

## 📋 Tabla de Contenidos

- [Código de conducta](#código-de-conducta)
- [¿Cómo puedo contribuir?](#cómo-puedo-contribuir)
- [Configuración del entorno de desarrollo](#configuración-del-entorno-de-desarrollo)
- [Flujo de trabajo con Git](#flujo-de-trabajo-con-git)
- [Convención de commits](#convención-de-commits)
- [Estándares de código](#estándares-de-código)
- [Pull Request Checklist](#pull-request-checklist)
- [Reportar bugs](#reportar-bugs)
- [Solicitar funcionalidades](#solicitar-funcionalidades)

---

## Código de conducta

Al participar en este proyecto, aceptas nuestro [Código de Conducta](CODE_OF_CONDUCT.md). Por favor, léelo antes de contribuir.

---

## ¿Cómo puedo contribuir?

### 🐛 Reportar bugs

- Usa la sección de [Issues](https://github.com/fredy200104/GRIDWISE/issues) en GitHub
- Usa la plantilla de **Bug Report** y describe el problema con detalle
- Incluye pasos para reproducir el bug, comportamiento esperado y capturas de pantalla si aplica

### 💡 Proponer nuevas funcionalidades

- Abre un [Issue](https://github.com/fredy200104/GRIDWISE/issues) con la plantilla **Feature Request**
- Describe el problema que resuelve y la solución propuesta
- Espera feedback del equipo antes de implementar

### 📝 Mejorar la documentación

- La documentación vive en la carpeta `docs/` y en el `README.md` raíz
- Los cambios de documentación también requieren Pull Request

### 💻 Contribuir con código

1. Revisa los [Issues abiertos](https://github.com/fredy200104/GRIDWISE/issues) y busca los marcados con `good first issue` o `help wanted`
2. Comenta en el issue que te interesa trabajar en él
3. Sigue el flujo de trabajo descrito a continuación

---

## Configuración del entorno de desarrollo

### Prerrequisitos

| Herramienta | Versión mínima |
|-------------|---------------|
| Flutter SDK | ≥ 3.11.1 |
| Dart SDK | ^3.11.1 |
| Node.js | ≥ 18.x |
| Git | ≥ 2.x |

### Setup inicial

```bash
# 1. Fork el repositorio en GitHub
# 2. Clona tu fork (reemplaza TU_USUARIO)
git clone https://github.com/TU_USUARIO/GRIDWISE.git
cd GRIDWISE

# 3. Agrega el repositorio original como remote "upstream"
git remote add upstream https://github.com/fredy200104/GRIDWISE.git

# 4. Instala dependencias Flutter
flutter pub get

# 5. Instala dependencias del backend
cd gridwise-backend && npm install && cd ..

# 6. Configura las variables de entorno del backend
cp gridwise-backend/.env.example gridwise-backend/.env
# Edita .env con tus credenciales de desarrollo

# 7. Verifica que todo funcione
flutter analyze
flutter test
```

---

## Flujo de trabajo con Git

### Mantener tu fork actualizado

```bash
# Sincronizar con el repositorio original
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### Crear una rama para tu contribución

```bash
# Para una nueva funcionalidad
git checkout -b feature/nombre-descriptivo

# Para corrección de bug
git checkout -b fix/descripcion-del-bug

# Para documentación
git checkout -b docs/seccion-actualizada
```

### Enviar tu contribución

```bash
# Asegúrate de que tu rama está actualizada
git fetch upstream
git rebase upstream/main

# Haz push de tu rama
git push origin feature/nombre-descriptivo

# Abre un Pull Request en GitHub hacia la rama main de fredy200104/GRIDWISE
```

---

## Convención de commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/). El formato es:

```
<tipo>(ámbito opcional): <descripción breve>

[cuerpo opcional]

[notas al pie opcionales]
```

### Tipos permitidos

| Tipo | Cuándo usar |
|------|-------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `docs` | Cambios en documentación únicamente |
| `style` | Formato, espacios, etc. (sin cambios de lógica) |
| `refactor` | Refactorización sin nueva funcionalidad ni fix |
| `test` | Agregar o modificar tests |
| `chore` | Actualizar dependencias, configuración de build, etc. |
| `perf` | Mejoras de rendimiento |

### Ejemplos de commits correctos

```
feat(chat): agregar soporte para imágenes en el chat IA
fix(dashboard): corregir cálculo de ahorro mensual con dispositivos inactivos
docs(manual): agregar sección de firmware ESP32 al manual de usuario
test(alerts): agregar tests para AlertService.checkAndCreateAlert
chore(deps): actualizar firebase_core a ^4.6.0
refactor(dashboard): simplificar DashboardService usando asyncExpand
```

---

## Estándares de código

### Dart / Flutter

- Sigue el [Effective Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- Usa `const` en widgets cuando sea posible (optimización de renderizado)
- Usa `debugPrint()` en lugar de `print()` para logs de desarrollo
- Evita lógica de negocio en los widgets — úsala en los Services
- Nombra los archivos en `snake_case`
- Nombra las clases en `PascalCase`

```dart
// ✅ Correcto
const Text('Hola GridWise')
debugPrint('Stream actualizado: $data')

// ❌ Incorrecto
Text('Hola GridWise')
print('Stream actualizado: $data')
```

### JavaScript / Node.js

- Usa `const` / `let` (nunca `var`)
- Usa `async/await` (evita callbacks anidados)
- Maneja errores con `try/catch` en funciones async
- Usa nombres descriptivos para funciones y variables

```javascript
// ✅ Correcto
const getUserContext = async (userId) => {
  try {
    const devicesSnap = await db.collection('iot_devices')
      .where('user_id', '==', userId).get();
    return devicesSnap.docs.map(doc => doc.data());
  } catch (error) {
    console.error('Error getting user context:', error);
    throw error;
  }
};

// ❌ Incorrecto
function getUserContext(userId, callback) {
  db.collection('iot_devices').where('user_id', '==', userId).get()
    .then(snap => callback(null, snap))
    .catch(err => callback(err));
}
```

### Verificar antes de hacer commit

```bash
# Análisis estático Dart
flutter analyze

# Formateo de código
dart format lib/

# Ejecutar todos los tests
flutter test

# Backend: verificar sintaxis
cd gridwise-backend && node --check server.js
```

---

## Pull Request Checklist

Antes de abrir un Pull Request, verifica que:

- [ ] El código sigue los estándares del proyecto
- [ ] `flutter analyze` no muestra errores ni warnings
- [ ] `flutter test` pasa todos los tests existentes
- [ ] `dart format` ha sido aplicado al código nuevo
- [ ] Se han agregado tests para la nueva funcionalidad (si aplica)
- [ ] La documentación ha sido actualizada (si se agregaron nuevas funciones)
- [ ] Los commits siguen la convención de Conventional Commits
- [ ] **No** se incluyen archivos sensibles (`.env`, `serviceAccountKey.json`, `*.jks`, `*.keystore`)
- [ ] El PR tiene un título descriptivo y una descripción clara de los cambios

---

## Reportar bugs

Al reportar un bug, incluye:

1. **Descripción:** ¿Qué sucede? ¿Qué esperabas que sucediera?
2. **Pasos para reproducirlo:** Lista numerada de pasos exactos
3. **Plataforma:** Android / iOS / Web + versión del OS
4. **Versión de la app:** (si aplica)
5. **Capturas de pantalla o videos:** (si aplica)
6. **Logs de error:** Copia el stack trace si está disponible

---

## Solicitar funcionalidades

Al solicitar una nueva funcionalidad:

1. **Problema:** Describe el problema que intenta resolver
2. **Solución propuesta:** Describe la funcionalidad deseada
3. **Alternativas consideradas:** Describe otras opciones que consideraste
4. **Contexto adicional:** Capturas, mockups, referencias, etc.

---

<div align="center">

*¡Gracias por contribuir a GridWise!* ⚡

</div>
