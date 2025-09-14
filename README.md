# Biblioteca Arrupe - Infraestructura

Este proyecto contiene la infraestructura de desarrollo para el sistema de biblioteca Arrupe, incluyendo frontend (Next.js), backend (Node.js) y base de datos (MongoDB).

## Estructura del Proyecto

```
├── docker-compose.yml          # Configuración de contenedores
├── .github/
│   └── workflows/
│       └── deploy.yml          # Pipeline de CI/CD
├── frontend/                   # Aplicación Next.js (clonada automáticamente)
└── backend/                    # API Node.js (clonada automáticamente)
```

## Inicio Rápido

### 1. Clonar repositorios y configurar entorno

```bash
# Clonar los repositorios frontend y backend
docker-compose --profile setup up cloner

# Iniciar todos los servicios
docker-compose up -d
```

### 2. Verificar servicios

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:4000
- **MongoDB**: mongodb://localhost:27017

### 3. Comandos útiles

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f frontend

# Reiniciar servicios
docker-compose restart

# Detener y limpiar
docker-compose down -v

#Reconstrucion de las imagenes sin cache
docker-compose build --no-cache
```

## GitHub Actions

El workflow de CI/CD incluye:

- ✅ **Test**: Ejecuta pruebas del frontend y backend
- 🐳 **Build**: Construye imágenes Docker
- 🚀 **Deploy**: Despliega a producción (configurar servidor)

### Secrets requeridos

Para el deployment automático, configura estos secrets en GitHub:

- `DOCKER_USERNAME`: Tu usuario de Docker Hub
- `DOCKER_PASSWORD`: Tu token de Docker Hub

## Desarrollo

### Estructura de servicios

- **cloner**: Clona automáticamente los repositorios
- **frontend**: Next.js en modo desarrollo (puerto 3000)
- **backend**: Node.js API (puerto 4000)
- **mongo**: Base de datos MongoDB (puerto 27017)

### Variables de entorno

El archivo incluye configuración automática para:
- Hot reload habilitado
- Conexión entre servicios
- Base de datos MongoDB

## Producción

Para desplegar en producción, modifica el workflow para incluir:

1. Tu servidor de deployment
2. Configuración de SSL/TLS
3. Variables de entorno de producción
4. Backups de base de datos
