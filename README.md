# Todoter 📋

Una aplicación moderna de gestión de tareas desarrollada con **Flutter** y **NestJS**, diseñada con una arquitectura escalable que utiliza bases de datos híbridas para optimizar el rendimiento y la flexibilidad.

## 🚀 Descripción del Proyecto

Todoter es una aplicación móvil de gestión de tareas que permite a los usuarios crear, organizar y gestionar sus actividades diarias de manera eficiente. La aplicación está construida con tecnologías modernas y una arquitectura que separa las responsabilidades entre diferentes tipos de bases de datos según la naturaleza de los datos.

### Stack Tecnológico

- **Frontend:** Flutter (Dart)
- **Backend:** NestJS (Node.js/TypeScript)
- **Base de datos SQL:** PostgreSQL (usuarios y autenticación)
- **Base de datos NoSQL:** MongoDB (tareas y contenido dinámico)
- **Autenticación:** JWT (JSON Web Tokens)
- **Despliegue:** Azure (backend), Railway (bases de datos)

---

## 🏗️ Arquitectura del Sistema

```mermaid
graph TD
  subgraph CLIENTE
    A[App Flutter]
  end
  
  subgraph BACKEND
    B[NestJS en Azure]
  end
  
  subgraph BBDD
    C[(PostgreSQL - Usuarios)]
    D[(MongoDB - Tareas)]
  end
  
  A -->|HTTP REST API| B
  B -->|Consulta usuarios| C
  B -->|Gestiona tareas| D
  C ---|Relación por userId| D
```

### Decisiones Arquitectónicas Clave

**¿Por qué dos bases de datos diferentes?**

- **PostgreSQL para Usuarios**: Entidades con estructura bien definida, que escalan verticalmente y requieren consistencia transaccional para operaciones de autenticación y seguridad.

- **MongoDB para Tareas**: Entidades flexibles que pueden evolucionar (subtareas, repeticiones, adjuntos), permitiendo crecimiento horizontal y adaptabilidad a nuevas funcionalidades sin migraciones complejas.

---

## 📱 Funcionalidades Principales

- ✅ **Autenticación segura** con JWT
- ✅ **Creación y gestión de tareas**
- ✅ **Filtrado por fecha y estado**
- 🔄 **Próximamente**: Subtareas, patrones de repetición, recordatorios

---

## 🛠️ Instalación y Configuración Local

### Requisitos Previos

- Node.js (v16+)
- Flutter SDK
- Android Studio / Xcode
- PostgreSQL y MongoDB (local o en la nube)

### 1. Clonar el Repositorio

```bash
git clone https://github.com/jmartinezgr/prueba-tecnica-wagon
cd prueba-tecnica-wagon
```

### 2. Configurar Backend

```bash
cd server
npm install
```

Crear archivo `.env` en `/server`:
```env
POSTGRES_USER=tu_usuario
POSTGRES_PASSWORD=tu_password
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=todoter_db
SECRET=tu_jwt_secret
MONGODB_URI=mongodb://localhost:27017/todoter
```

Ejecutar servidor:
```bash
npm run start:dev
```

### 3. Configurar Frontend

```bash
cd mobile
flutter pub get
```

Crear archivo `.env` en `/mobile`:
```env
API_BASE=http://10.0.2.2:3000/api/v1
```

Ejecutar aplicación:
```bash
flutter run
```

---

## 🔌 API Endpoints

### Autenticación `/auth`
- `POST /auth/login` - Iniciar sesión
- `POST /auth/register` - Registrar usuario
- `POST /auth/refresh` - Renovar token

### Tareas `/tasks`
- `GET /tasks` - Obtener tareas (con filtros opcionales)
- `POST /tasks` - Crear nueva tarea
- `GET /tasks/:id` - Obtener tarea específica
- `PATCH /tasks/:id` - Actualizar tarea
- `DELETE /tasks/:id` - Eliminar tarea

**Documentación completa:** Ver [`docs/endpoints.md`](docs/endpoints.md)

---

## 🌐 Backend Desplegado

**URL de producción:** 
```
[URL_AZURE_AQUI]
```

*Para usar el backend desplegado, actualiza la variable `API_BASE` en el archivo `.env` del frontend con la URL de Azure.*

---

## 📸 Capturas de Pantalla

<!-- TODO: Agregar capturas de pantalla de la aplicación -->

### Pantalla de Login
*[Captura pendiente]*

### Lista de Tareas
*[Captura pendiente]*

### Crear Nueva Tarea
*[Captura pendiente]*

---

## 🏭 Módulos del Sistema

### 🔐 Auth Module
Gestiona toda la lógica de autenticación y autorización:
- Registro e inicio de sesión de usuarios
- Generación y validación de JWT tokens
- Middleware de protección para rutas sensibles
- Integración con PostgreSQL para datos de usuario

### 👥 Users Module
Maneja las operaciones CRUD de usuarios:
- Creación y gestión de perfiles de usuario
- Validación de datos y unicidad de emails
- Interacción directa con PostgreSQL

### ✅ Tasks Module
Núcleo funcional de la aplicación:
- CRUD completo de tareas
- Filtrado por fecha, estado y programación
- Arquitectura preparada para subtareas y repeticiones
- Integración con MongoDB para flexibilidad de datos

---

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

## 📞 Contacto

**Desarrollador:** José Martínez  
**GitHub:** [@jmartinezgr](https://github.com/jmartinezgr)

---

*Todoter - Organizando tu día, una tarea a la vez* ✨