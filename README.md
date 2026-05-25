# 🌦️ IGS Field Reporting System - Mobile App

Aplicación móvil Android desarrollada en Flutter para la captura, administración y sincronización de reportes meteorológicos de campo.

El sistema permite trabajar completamente offline, generar reportes PDF, capturar evidencias fotográficas, firmar digitalmente reportes y sincronizar la información posteriormente con un backend desarrollado en ASP.NET Core + PostgreSQL.

---

# 🚀 Tecnologías utilizadas

## Mobile App
- Flutter
- Dart
- Android SDK
- Material Design 3

## Backend Integrado
- ASP.NET Core 8
- PostgreSQL
- JWT Authentication
- Docker

---

# ✨ Características principales

## 📋 Gestión de Reportes
- Creación de reportes de campo
- Edición de reportes
- Eliminación lógica
- Visualización de reportes

---

## 📷 Evidencias Fotográficas
- Captura de imágenes desde cámara
- Selección desde galería
- Asociación automática al reporte
- Renombrado automático de imágenes

Ejemplo:

```text
REP-0001-22052026_20260522_021747_IMG_001.jpg
```

---

## ✍️ Firma Digital
- Firma táctil dentro de la app
- Almacenamiento local de firma
- Inserción automática dentro del PDF

---

## 📄 Generación de PDF
- PDF generado localmente
- Compatible para trabajo offline
- Incluye:
    - Folio
    - Fecha
    - Estación
    - Ubicación
    - Observaciones
    - Evidencias
    - Firma digital

---

## 🔐 Autenticación
- Login JWT
- Persistencia de sesión
- Roles de usuario
- Recuperación de contraseña
- Registro de nuevos usuarios

---

## 📡 Trabajo Offline
El sistema fue diseñado para trabajar en zonas sin internet:

- Reportes almacenados localmente
- Evidencias almacenadas localmente
- Firma local
- Sesión persistente
- Sincronización futura

---

# 🏗️ Arquitectura del proyecto

```text
lib/
│
├── models/
│   ├── report_model.dart
│   ├── report_image_model.dart
│   ├── user_model.dart
│   └── login_response_model.dart
│
├── services/
│   ├── pdf_service.dart
│   ├── report_storage_service.dart
│   ├── auth_service.dart
│   └── session_service.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── create_report_screen.dart
│   ├── report_detail_screen.dart
│   └── signature_screen.dart
│
├── widgets/
│
└── main.dart
```

---

# 📦 Dependencias principales

## Instalar Flutter dependencies

```bash
flutter pub add http
flutter pub add shared_preferences
flutter pub add path_provider
flutter pub add image_picker
flutter pub add pdf
flutter pub add printing
flutter pub add signature
flutter pub add intl
```

---

# ⚙️ Configuración del Backend

La app consume el backend ASP.NET Core.

## URL para Android Emulator

```dart
static const String baseUrl =
    'http://10.0.2.2:8080/api';
```

---

# 🔑 Login JWT

La autenticación se realiza mediante JWT.

## Endpoint

```http
POST /api/Auth/login
```

## Ejemplo Request

```json
{
  "email": "admin@igs.com",
  "password": "Admin123*"
}
```

---

# 📝 Registro de Usuarios

## Endpoint

```http
POST /api/Auth/register
```

## Ejemplo Request

```json
{
  "fullName": "Inspector Campo",
  "email": "campo@igs.com",
  "password": "Campo123*",
  "role": "Inspector de Campo"
}
```

---

# 🔄 Recuperación de contraseña

## Generar código

```http
POST /api/Auth/forgot-password
```

---

## Restablecer contraseña

```http
POST /api/Auth/reset-password
```

---

# 📁 Almacenamiento local

Los reportes se almacenan localmente usando JSON.

Cada reporte contiene:

- Información general
- Evidencias
- Firma
- Estado de sincronización
- PDF generado

---

# 📄 Estados del Reporte

## Estado funcional

```text
DRAFT
READY_FOR_SYNC
LOCKED
ARCHIVED
```

---

## Estado de sincronización

```text
LOCAL_ONLY
PENDING_SYNC
SYNCING
SYNCED
SYNC_ERROR
LOCAL_DELETED
```

---

# 🖼️ Flujo de imágenes

Las imágenes se almacenan localmente con nombres únicos:

```text
REP-0001-22052026_20260522_021747_IMG_001.jpg
```

Estructura:

```text
[FOLIO]_[TIMESTAMP]_[CONSECUTIVO]
```

---

# 📲 Compilar aplicación

## Debug

```bash
flutter run
```

---

## APK Release

```bash
flutter build apk --release
```

APK generado:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

# 🐳 Backend Dockerizado

El backend corre mediante Docker:

```bash
docker compose up -d --build
```

---

# 🛡️ Seguridad implementada

- JWT Authentication
- BCrypt Password Hash
- Roles
- Sesión persistente
- Recuperación de contraseña
- Protección de endpoints

---

# 🚧 Funcionalidades futuras

- Sincronización automática
- Cola de sincronización offline
- Biometría
- PIN offline
- Dashboard administrador
- Notificaciones push
- Geolocalización
- Firma avanzada
- Exportación masiva PDF
- Modo tablet
- Cifrado local

---

# 👨‍💻 Autor

## 👨‍💻 Ing. Luis Angel De Los Santos León

📧 ldelossantosleon@gmail.com

🇲🇽 México

---

# 🏢 Proyecto

IGS - Intelligent Global Systems

Sistema móvil empresarial para reportes meteorológicos y operación de campo.