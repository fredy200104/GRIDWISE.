# Reporte de Pruebas - GridWise Residencial

## Entorno
- Fecha: 2026-04-24
- Plataforma: Flutter (Dart), backend Node.js, Firebase
- Comando ejecutado: `flutter test`
- Resultado general automatizado: 4/4 pruebas superadas

## 1) Pruebas unitarias

### Caso U1 - Calculo de consumo por dispositivo
- Descripcion: validar conversion de watts/horas a kWh mensual y costo.
- Resultado esperado: `monthlyKwh` y `monthlyCost` deben coincidir con formula.
- Resultado obtenido: exitoso (`test/device_model_test.dart`).

### Caso U2 - Recomendacion por umbral superado
- Descripcion: generar recomendacion cuando el consumo mensual supera umbral.
- Resultado esperado: incluir mensaje de "Consumo por encima del umbral".
- Resultado obtenido: exitoso (`test/recommendation_service_test.dart`).

## 2) Pruebas de integracion

### Caso I1 - Flujo dispositivos -> resumen -> recomendaciones
- Descripcion: simular dispositivos residenciales y derivar recomendaciones desde consumo agregado.
- Resultado esperado: obtener consumo mensual mayor a 0 y lista de recomendaciones no vacia.
- Resultado obtenido: exitoso (`integration_test/residential_flow_test.dart`).

## 3) Pruebas funcionales (prototipo)

### Caso F1 - Registro y acceso
- Descripcion: registrar usuario y acceder al home.
- Resultado esperado: redireccion a modulos principales al autenticar.
- Resultado obtenido: correcto en validacion funcional manual.

### Caso F2 - CRUD de dispositivos
- Descripcion: crear, editar y eliminar dispositivos del hogar.
- Resultado esperado: cambios visibles en lista y resumen de consumo.
- Resultado obtenido: correcto en validacion funcional manual.

### Caso F3 - Alertas por umbral
- Descripcion: configurar umbral bajo y refrescar dashboard.
- Resultado esperado: crear alerta de consumo elevado cuando aplique.
- Resultado obtenido: correcto en validacion funcional manual.

### Caso F4 - IoT simulado
- Descripcion: vincular dispositivo IoT simulado y activar simulacion.
- Resultado esperado: estado conectado/desconectado y potencia actualizada periodicamente.
- Resultado obtenido: correcto en validacion funcional manual.

## 4) Validaciones de formularios y manejo de errores
- Registro/login con validacion de correo.
- Registro con validacion minima de telefono.
- Recuperacion por telefono con respuesta uniforme (sin enumeracion de usuarios).
- Respuestas de error controladas en backend para payload/token invalidos.
