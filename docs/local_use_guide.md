# Guía de Uso en Local

## Requisitos Previos

Para ejecutar este proyecto correctamente, necesitarás tener instalados y configurados los siguientes elementos:

- **Node.js** (versión 16 o superior)
- **Flutter** con el SDK configurado
- **Android Studio** con los emuladores configurados
- **Visual Studio Code** (recomendado para desarrollo)
- **Bases de datos**: PostgreSQL y MongoDB (en la nube o local)

## Instalación Inicial

Comienza clonando el repositorio público:

```bash
git clone https://github.com/jmartinezgr/prueba-tecnica-wagon
cd prueba-tecnica-wagon
```

Una vez dentro del directorio, encontrarás la siguiente estructura:

```
prueba-tecnica-wagon/
├── docs/
├── mobile/
└── server/
```

## Configuración del Backend

### 1. Instalación de Dependencias

Navega al directorio del servidor:

```bash
cd server
```

Instala las dependencias utilizando tu gestor de paquetes preferido:

```bash
# Con npm
npm install

# Con pnpm
pnpm install

# Con yarn
yarn install
```

### 2. Variables de Entorno

Crea un archivo `.env` en la raíz del directorio `server` con la siguiente estructura:

```bash
POSTGRES_USER=<tu_usuario_postgres>
POSTGRES_PASSWORD=<tu_contraseña_postgres>
POSTGRES_HOST=<host_postgres>
POSTGRES_PORT=<puerto_postgres>
POSTGRES_DB=<nombre_base_datos_postgres>
SECRET=<tu_secreto_jwt>
MONGODB_URI=<uri_completa_mongodb>
```

### 3. Ejecución del Servidor

Una vez configuradas las variables de entorno, inicia el servidor NestJS:

**Para desarrollo (con hot reload):**
```bash
npm run start:dev
```

**Para producción:**
```bash
npm run start
```

El servidor estará disponible en `http://localhost:3000`

## Configuración del Frontend (Flutter)

### Prerrequisitos

Antes de proceder con la configuración del cliente Flutter, asegúrate de haber completado todo el tutorial de instalación y configuración de Flutter para tu sistema operativo.

### 1. Configuración del Entorno de Desarrollo

#### En Windows:
- Abre Visual Studio Code
- Inicia un servicio de emulación Android desde Android Studio o VS Code
- Verifica que el emulador esté ejecutándose correctamente

#### En macOS:
- Abre Visual Studio Code
- Puedes utilizar el simulador de iOS o un emulador Android
- Elige el dispositivo de tu preferencia desde VS Code

### 2. Configuración de Variables de Entorno

Crea un archivo `.env` en la **raíz del directorio `mobile`** con la siguiente configuración:

```bash
API_BASE=http://10.0.2.2:3000/api/v1
```

> **Nota importante:** La dirección `http://10.0.2.2:3000/api/v1` es específica para emuladores Android, ya que `10.0.2.2` es la IP que el emulador Android utiliza para comunicarse con `localhost` de la máquina host.

### 3. Alternativas de Configuración

Si tienes el backend desplegado en Azure u otro servicio en la nube, puedes reemplazar la URL local por la URL de producción:

```bash
API_BASE=https://tu-backend-en-azure.com/api/v1
```

### 4. Instalación de Dependencias Flutter

Navega al directorio mobile:

```bash
cd mobile
```

Instala las dependencias de Flutter:

```bash
flutter pub get
```

### 5. Ejecución de la Aplicación

Con el emulador ejecutándose y las variables configuradas, lanza la aplicación:

```bash
flutter run
```

## Resolución de Problemas Comunes

### Problemas de Conectividad
- Verifica que el backend esté ejecutándose en el puerto 3000
- Asegúrate de que las variables de entorno estén correctamente configuradas
- En Android, confirma que estés usando la IP `10.0.2.2` en lugar de `localhost`

### Problemas con Flutter
- Ejecuta `flutter doctor` para verificar la configuración
- Asegúrate de que el emulador esté completamente iniciado antes de ejecutar la aplicación
- Limpia el proyecto con `flutter clean` si experimentas problemas de compilación

## Estructura del Proyecto

- **`server/`**: Backend desarrollado en NestJS
- **`mobile/`**: Aplicación móvil desarrollada en Flutter
- **`_docs/`**: Documentación del proyecto