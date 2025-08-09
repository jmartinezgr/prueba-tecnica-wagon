# Documentación de Endpoints de la API

## Descripción General

La aplicación cuenta actualmente con dos módulos principales implementados de los 3 mencionados en la [arquitectura.md](architecture.md):

- **Módulo de Autenticación (Auth)**: Gestiona registro, login y renovación de tokens
- **Módulo de Tareas (Tasks)**: Maneja las operaciones CRUD de tareas

A continuación se detalla la documentación completa de cada endpoint disponible.

---

## Módulo de Autenticación

**Prefijo de rutas:** `/auth`

### POST `/auth/login`
**Descripción:** Iniciar sesión en la aplicación

**Parámetros del body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Respuesta exitosa (200):**
```json
{
  "accessToken": "string",
  "refreshToken": "string",
  "user": {
    "id": "12345",
    "email": "usuario@ejemplo.com",
    "name": "Juan Pérez",
    "createdAt": "2025-08-08T20:38:17.010Z",
    "updatedAt": "2025-08-08T20:38:17.010Z",
    "deletedAt": null
  }
}
```

**Errores comunes:**
- `401 Unauthorized`: Credenciales inválidas

---

### POST `/auth/register`
**Descripción:** Registrar un nuevo usuario en el sistema

**Parámetros del body:**
```json
{
  "name": "string",
  "email": "string",
  "password": "string"
}
```

**Respuesta exitosa (201):**
```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "accessToken": "string",
  "refreshToken": "string"
}
```

**Errores comunes:**
- `400 Bad Request`: Datos inválidos o email ya existente

---

### POST `/auth/refresh`
**Descripción:** Renovar el token de acceso utilizando el refresh token

**Parámetros del body:**
```json
{
  "refreshToken": "string"
}
```

**Respuesta exitosa (200):**
```json
{
  "accessToken": "string",
  "refreshToken": "string"
}
```

**Errores comunes:**
- `401 Unauthorized`: Refresh token inválido o expirado

---

## Tipos de Datos

### UserData
Estructura del objeto usuario devuelto por la API:

```json
{
  "id": "67890",
  "email": "ejemplo@correo.com",
  "name": "María González",
  "createdAt": "2025-08-08T20:38:17.010Z",
  "updatedAt": "2025-08-08T20:38:17.010Z",
  "deletedAt": null
}
```

**Propiedades:**
- `id` (string): Identificador único del usuario
- `email` (string): Correo electrónico del usuario
- `name` (string): Nombre completo del usuario
- `createdAt` (string): Fecha de creación en formato ISO
- `updatedAt` (string): Fecha de última actualización en formato ISO
- `deletedAt` (string | null): Fecha de eliminación lógica (null si está activo)

---

## Notas Importantes

- Todos los endpoints requieren headers `Content-Type: application/json`
- Los tokens de acceso tienen un tiempo de vida limitado
- Utiliza el refresh token para obtener nuevos access tokens sin requerir login
- Las fechas están en formato ISO 8601 (UTC)