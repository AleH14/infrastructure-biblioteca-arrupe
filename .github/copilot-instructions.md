# Contexto del Proyecto: Sistema de Biblioteca Arrupe

## 📋 Descripción General

Sistema de gestión de biblioteca digital desarrollado para el Colegio Arrupe. Arquitectura distribuida en 3 repositorios con frontend (Next.js), backend (Node.js/Express) y base de datos (MongoDB), todo orquestado con Docker Compose.

## 🏗️ Arquitectura del Sistema

### Repositorios
- **infrastructure-biblioteca-arrupe** (este repo): Infraestructura Docker y orquestación
- **biblioteca-arrupe-frontend**: Interfaz de usuario con Next.js 14
- **biblioteca-arrupe-backend**: API REST con Node.js y Express

### Stack Tecnológico

#### Frontend
- **Framework**: Next.js 15.5.2 (React 19.1.0)
- **Estilos**: CSS Modules + Bootstrap 5.3.8
- **Autenticación**: NextAuth 4.24.8
- **HTTP Client**: Axios 1.12.2
- **Gráficos**: Chart.js 4.5.1 + react-chartjs-2
- **Iconos**: React Icons 5.5.0
- **Testing**: Jest 30.1.3 + Testing Library
- **Fechas**: date-fns 4.1.0 + react-datepicker

#### Backend
- **Runtime**: Node.js
- **Framework**: Express 5.1.0
- **Base de datos**: MongoDB (mongoose 8.18.1)
- **Autenticación**: JWT (jsonwebtoken 9.0.2) + bcrypt 6.0.0
- **Seguridad**: Helmet 8.1.0 + CORS 2.8.5
- **Logging**: Winston 3.18.3 + Morgan 1.10.1
- **Testing**: Jest 30.1.3 + Supertest 7.1.4
- **Dev**: Nodemon 3.1.10

#### Infraestructura
- **Contenedorización**: Docker + Docker Compose
- **Base de datos**: MongoDB 6.0
- **Puertos**:
  - Frontend: 3000
  - Backend: 4000
  - MongoDB: 27018 (host) → 27017 (container)

## 📁 Estructura del Proyecto

### Backend (`/backend`)
```
backend/
├── src/
│   ├── config/           # Configuración (app, db, server)
│   ├── core/
│   │   ├── middlewares/  # Auth & request logger
│   │   └── utils/        # Logger (winston)
│   └── modules/          # Módulos funcionales
│       ├── auth/         # Autenticación (login/register)
│       ├── libros/       # CRUD libros + categorías + ejemplares
│       ├── prestamos/    # Gestión préstamos y devoluciones
│       └── usuarios/     # CRUD usuarios
├── tests/                # Tests unitarios y de integración
└── logs/                 # Logs de la aplicación
```

### Frontend (`/frontend`)
```
frontend/
├── src/
│   ├── app/              # App Router de Next.js
│   │   ├── api/auth/     # NextAuth API routes
│   │   ├── dashboard/    # Dashboard principal
│   │   └── login/        # Página de login
│   ├── components/
│   │   ├── estadisticas/ # Componentes de estadísticas
│   │   ├── forms/        # Formularios (Libros, Préstamos, Usuarios, etc.)
│   │   ├── svg/          # Iconos SVG custom
│   │   └── ui/           # Componentes UI reutilizables
│   ├── contexts/         # AuthContext para estado global
│   ├── hooks/            # Custom hooks (useAuth, useDebounce)
│   ├── services/         # API clients y servicios
│   └── styles/           # CSS Modules
└── public/images/        # Imágenes estáticas
```

## 🔑 Funcionalidades Principales

### 1. Gestión de Libros
- CRUD completo de libros
- Gestión de categorías
- Gestión de ejemplares por libro
- Estados de ejemplares: disponible, prestado, reservado, mantenimiento, baja
- Búsqueda y filtrado de libros
- Integración con Google Books API

### 2. Gestión de Préstamos
- Crear préstamos con búsqueda de libros y usuarios
- Estados: activo, vencido, devuelto
- Fechas: préstamo, devolución estimada, devolución real
- Búsqueda por nombre de alumno
- Filtrado por estado
- Cerrar préstamos (devoluciones)
- Validaciones de disponibilidad

### 3. Gestión de Usuarios
- CRUD de usuarios
- Roles: admin, bibliotecario, estudiante
- Información: nombre, email, grado, sección, código
- Autenticación con JWT
- Registro e inicio de sesión

### 4. Estadísticas (En desarrollo)
- **Estado actual**: Datos simulados/hardcodeados
- **Componentes**:
  - Métricas generales (préstamos, usuarios, libros)
  - Tendencias temporales (hoy, mensual, anual)
  - Top libros más/menos prestados
  - Distribución por categorías
  - Devoluciones atrasadas
  - Libros reservados
- **Pendiente**: Integración con backend para datos reales

### 5. Autenticación y Autorización
- JWT para backend
- NextAuth para frontend
- Middleware de autenticación
- Protección de rutas
- Manejo de sesiones

## 🔐 Variables de Entorno

### Backend (.env)
```
NODE_ENV=development
MONGO_URI=mongodb://mongo:27017/biblioteca-arrupe
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d
FRONTEND_URL=http://localhost:3000
```

### Frontend (.env.local)
```
NODE_ENV=development
NEXT_PUBLIC_API_URL=http://localhost:4000
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-nextauth-secret
```

## 🎨 Patrones y Convenciones

### Backend
- **Arquitectura**: Modular por dominio (auth, libros, prestamos, usuarios)
- **Capas**: Controller → Service → Repository → Model
- **Rutas**: `/api/auth`, `/api/libros`, `/api/prestamos`, `/api/usuarios`
- **Respuestas**: JSON con estructura `{ success, data, message }`
- **Errores**: Middleware centralizado de manejo de errores

### Frontend
- **Arquitectura**: Component-based con App Router
- **Estado**: Context API para autenticación global
- **Estilos**: CSS Modules (archivos `.module.css`)
- **Componentes**: Separados en forms/, ui/, estadisticas/
- **Servicios**: Cliente API centralizado con interceptors

### Modelos de Datos

#### Libro
```javascript
{
  titulo: String,
  autor: String,
  editorial: String,
  isbn: String,
  precio: Number,
  categoria: ObjectId → Categoria,
  ejemplares: [Ejemplar],
  fechaRegistro: Date
}
```

#### Ejemplar
```javascript
{
  numeroEjemplar: String,
  estado: ['disponible', 'prestado', 'reservado', 'mantenimiento', 'baja'],
  ubicacion: String,
  observaciones: String
}
```

#### Préstamo
```javascript
{
  libro: ObjectId → Libro,
  ejemplar: ObjectId → Ejemplar,
  usuario: ObjectId → Usuario,
  fechaPrestamo: Date,
  fechaDevolucionEstimada: Date,
  fechaDevolucionReal: Date,
  estado: ['activo', 'vencido', 'devuelto'],
  observaciones: String
}
```

#### Usuario
```javascript
{
  nombre: String,
  email: String,
  password: String (hashed),
  rol: ['admin', 'bibliotecario', 'estudiante'],
  grado: String,
  seccion: String,
  codigo: String
}
```

## 🚀 Comandos Útiles

### Docker
```bash
# Setup inicial (clonar repos)
docker-compose --profile setup up cloner

# Iniciar servicios
docker-compose up -d

# Ver logs
docker-compose logs -f [service]

# Reiniciar servicio
docker-compose restart [service]

# Detener todo
docker-compose down

# Rebuild
docker-compose up -d --build
```

### Desarrollo Local

#### Backend
```bash
cd backend
npm install
npm run dev          # Nodemon en puerto 4000
npm test            # Tests con Jest
```

#### Frontend
```bash
cd frontend
npm install
npm run dev         # Next.js dev en puerto 3000
npm test            # Tests con Jest
npm run build       # Build de producción
```

## 📝 Notas Importantes

### Estado Actual del Proyecto
- Falta integracion del backend con el frontend
- ⚠️ Estadísticas con datos simulados (pendiente integración backend)
- ⚠️ Falta endpoint de estadísticas en backend

### Consideraciones de Desarrollo
1. **Hot Reload**: Ambos servicios tienen hot reload configurado
2. **Persistencia**: MongoDB con volumen persistente
3. **CORS**: Configurado para desarrollo (frontend → backend)
4. **Logs**: Winston para logs estructurados en backend
5. **Testing**: Jest configurado en ambos proyectos

### Próximos Pasos Recomendados
1. Implementar endpoint de estadísticas en backend
2. Conectar frontend de estadísticas con backend
3. Implementar sistema de notificaciones
4. Agregar exportación de reportes
5. Mejorar sistema de búsqueda avanzada
6. Implementar sistema de reservas de libros

## 🐛 Debugging

### Backend
- Logs en: `backend/logs/`
- Health check: `GET http://localhost:4000/health`
- MongoDB Shell: `docker exec -it mongo mongosh`

### Frontend
- Next.js debug: `DEBUG=* npm run dev`
- Build info: `.next/`
- API calls: Network tab en DevTools

## 🔗 URLs y Endpoints Principales

### Frontend
- Homepage: `http://localhost:3000`
- Login: `http://localhost:3000/login`
- Dashboard: `http://localhost:3000/dashboard`

### Backend API
- Base URL: `http://localhost:4000`
- Auth: `/api/auth/login`, `/api/auth/register`
- Libros: `/api/libros`, `/api/libros/:id`
- Categorías: `/api/categorias`
- Préstamos: `/api/prestamos`
- Usuarios: `/api/usuarios`

### Base de Datos
- Connection: `mongodb://localhost:27018`
- Database: `biblioteca-arrupe`

---

**Última actualización**: Diciembre 2025
**Mantenedor**: AleH14
