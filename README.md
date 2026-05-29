# J&P Tech Support — App Móvil

## 🔧 Descripción
App de servicios técnicos a domicilio estilo Uber. Clientes solicitan soporte IT (PCs, laptops, redes, etc.) y técnicos certificados reciben el trabajo en tiempo real.

---

## 📁 Estructura del Proyecto

```
jp_tech_support/
├── backend/           → API Node.js + Express + Socket.io
│   ├── database/      → Schema MySQL
│   ├── src/
│   │   ├── config/    → Conexión DB
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── routes/
│   │   └── sockets/
│   └── .env.example
└── mobile/            → App Flutter
    └── lib/
        ├── config/    → Colores, tema, URLs
        ├── models/    → User, Service, Message
        ├── providers/ → Auth, Service (estado global)
        ├── services/  → API, Location, Socket
        └── screens/
            ├── auth/
            ├── client/
            └── technician/
```

---

## ⚙️ Instalación Backend

### Requisitos
- Node.js 18+
- MySQL 8+

### Pasos

```bash
cd backend
npm install

# Configurar .env
cp .env.example .env
# Editar .env con tus credenciales de MySQL

# Crear base de datos
mysql -u root -p < database/schema.sql

# Iniciar servidor
npm run dev
# ó
npm start
```

El servidor corre en: `http://localhost:3000`

### Variables de entorno (.env)
```
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=TU_PASSWORD
DB_NAME=jp_tech_support
JWT_SECRET=clave_secreta_segura
```

---

## 📱 Instalación App Flutter

### Requisitos
- Flutter SDK 3.x
- Android Studio / VS Code
- Emulador Android o dispositivo físico

### Pasos

```bash
cd mobile
flutter pub get

# Verificar setup
flutter doctor

# Correr la app
flutter run
```

### Configurar URL del backend (api_config.dart)
```dart
// Para emulador Android:
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Para dispositivo físico (reemplaza con tu IP local):
static const String baseUrl = 'http://192.168.1.X:3000/api';
```

---

## 🗄️ Base de Datos (MySQL)

**Tablas principales:**
| Tabla | Descripción |
|-------|-------------|
| `users` | Clientes y técnicos |
| `tecnicos_perfil` | Perfil profesional del técnico |
| `categorias` | Tipos de servicio (PC, Laptop, etc.) |
| `solicitudes` | Órdenes de servicio |
| `ofertas` | Propuestas de técnicos |
| `mensajes` | Chat en tiempo real |
| `resenas` | Calificaciones |
| `marketplace_leads` | Leads para el marketplace |
| `ubicaciones_tecnico` | Tracking GPS |

---

## 🔌 API Endpoints

### Auth
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login (cliente/técnico) |
| POST | `/api/auth/register/cliente` | Registro cliente |
| POST | `/api/auth/register/tecnico` | Registro técnico |
| POST | `/api/auth/verify` | Verificar OTP |
| POST | `/api/auth/forgot-password` | Recuperar contraseña |
| GET | `/api/auth/profile` | Perfil del usuario |

### Servicios
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/services/categorias` | Listar categorías |
| POST | `/api/services` | Crear solicitud |
| GET | `/api/services/mis-solicitudes` | Mis servicios |
| GET | `/api/services/:id` | Detalle de servicio |
| PUT | `/api/services/:id/estado` | Actualizar estado |
| POST | `/api/services/:id/finalizar` | Finalizar servicio |

### Técnicos
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/technicians/nearby` | Técnicos cercanos |
| POST | `/api/technicians/offer` | Enviar oferta |
| GET | `/api/technicians/offers/:id` | Ver ofertas |
| POST | `/api/technicians/accept-offer/:id` | Aceptar oferta |
| PUT | `/api/technicians/location` | Actualizar GPS |
| PUT | `/api/technicians/availability` | Toggle disponibilidad |
| GET | `/api/technicians/marketplace` | Ver marketplace leads |

### Chat & Ratings
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/chat/:solicitud_id` | Obtener mensajes |
| POST | `/api/chat/:solicitud_id` | Enviar mensaje |
| POST | `/api/ratings` | Crear reseña |
| GET | `/api/ratings/tecnico/:id` | Reseñas de técnico |

---

## ⚡ Socket.io Events

### Cliente → Servidor
| Evento | Descripción |
|--------|-------------|
| `join_solicitud` | Unirse a sala de una solicitud |
| `typing` | Indicador de escritura |
| `stop_typing` | Dejar de escribir |

### Técnico → Servidor
| Evento | Descripción |
|--------|-------------|
| `update_location` | Enviar posición GPS |
| `en_camino` | Marcar "en camino" |
| `llegue_destino` | Marcar "llegué" |

### Servidor → Cliente
| Evento | Descripción |
|--------|-------------|
| `nueva_solicitud` | Nueva solicitud disponible |
| `nueva_oferta` | Técnico envió oferta |
| `oferta_aceptada` | Cliente aceptó oferta |
| `tecnico_ubicacion` | Posición GPS del técnico |
| `estado_actualizado` | Cambio de estado |
| `nuevo_mensaje` | Mensaje de chat |
| `tecnico_llego` | Técnico llegó |

---

## 📱 Pantallas Implementadas (21)

### Auth (5)
- Login (Cliente/Técnico)
- Registro Cliente
- Registro Técnico
- Verificar OTP
- Recuperar Contraseña

### Cliente (10)
- Home / Inicio
- Solicitar Servicio (Paso 1/3)
- Agendar Fecha/Hora (Paso 2/3)
- Resumen Solicitud (Paso 3/3)
- Buscando Técnicos (tiempo real)
- Ofertas de Técnicos
- Reserva Confirmada
- Chat (con socket)
- Calificar Servicio
- Mi Perfil

### Técnico (6)
- Panel / Dashboard
- Detalle del Servicio
- Navegación en Mapa (OpenStreetMap)
- Chat Técnico (con botones ubicación/llegué)
- Resumen de Servicio (finalizar)
- Marketplace / Leads

---

## 🎨 Diseño
- **Color principal:** `#1E4DB7`
- **Fondo:** `#F5F7FA`
- **Fuente:** Roboto
- Basado en diseños Figma proporcionados
- Mapas: OpenStreetMap (flutter_map + latlong2)

---

## 🇵🇪 Contexto
- Moneda: Soles peruanos (S/.)
- Zona horaria: GMT-5 (Lima, Perú)
- Idioma: Español

---

*J&P SERVICIOS TÉCNICOS © 2024*
