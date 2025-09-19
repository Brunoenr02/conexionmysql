# Aplicación de Registro de Alumnos

Una aplicación Flutter para gestionar el registro de alumnos con operaciones CRUD (Crear, Leer, Actualizar, Eliminar) conectada a una base de datos MySQL.

## Características

- ✅ Listar todos los alumnos registrados
- ✅ Agregar nuevos alumnos
- ✅ Ver detalles de cada alumno
- ✅ Editar información de alumnos existentes
- ✅ Eliminar alumnos del registro
- ✅ Validación de formularios
- ✅ Interfaz intuitiva con Material Design
- ✅ Conexión directa a base de datos MySQL

## Campos de Alumno

- **Nombres**: Nombres del alumno (requerido)
- **Apellidos**: Apellidos del alumno (requerido)
- **Código**: Código único de identificación (requerido)
- **Dirección**: Dirección del alumno (requerido)
- **Número**: Número de teléfono (requerido)

## Requisitos Previos

### Base de Datos MySQL

1. **Instalar MySQL Server** (si no está instalado):
   - Descargar desde: https://dev.mysql.com/downloads/mysql/
   - O usar XAMPP: https://www.apachefriends.org/

2. **Configurar la conexión** en `lib/services/database_service.dart`:
   ```dart
   static const String _host = 'localhost';     // Tu servidor MySQL
   static const int _port = 3306;               // Puerto MySQL
   static const String _user = 'root';          // Tu usuario MySQL
   static const String _password = '';          // Tu contraseña MySQL
   static const String _db = 'escuela_db';      // Nombre de la base de datos
   ```

### Flutter

- Flutter SDK 3.0 o superior
- Dart 3.0 o superior

## Instalación y Configuración

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Configurar MySQL

#### Opción A: Usando XAMPP (Recomendado para desarrollo)

1. Descargar e instalar XAMPP
2. Iniciar Apache y MySQL desde el panel de control
3. Abrir phpMyAdmin en http://localhost/phpmyadmin
4. La aplicación creará automáticamente la base de datos y tabla al ejecutarse

#### Opción B: MySQL directo

1. Conectar a MySQL:
   ```sql
   mysql -u root -p
   ```

2. La tabla se crea automáticamente al ejecutar la aplicación por primera vez.

### 3. Ejecutar la aplicación

```bash
flutter run
```

## Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada de la aplicación
├── models/
│   └── alumno.dart                # Modelo de datos del alumno
├── services/
│   └── database_service.dart      # Servicio de conexión y operaciones MySQL
└── screens/
    ├── home_screen.dart           # Pantalla principal con lista de alumnos
    ├── add_student_screen.dart    # Pantalla para agregar nuevos alumnos
    └── student_detail_screen.dart # Pantalla de detalles y edición
```

## Uso de la Aplicación

### Pantalla Principal
- Muestra lista de todos los alumnos registrados
- Cada elemento tiene íconos para editar (lápiz) y eliminar (basura)
- Botón flotante (+) para agregar nuevos alumnos
- Pull-to-refresh para actualizar la lista

### Agregar Alumno
- Formulario con validación para todos los campos
- Verificación de código único
- Mensajes de error descriptivos

### Detalles/Edición
- Vista de solo lectura por defecto
- Modo edición activable con botón
- Opción de eliminar con confirmación
- Validación en tiempo real
