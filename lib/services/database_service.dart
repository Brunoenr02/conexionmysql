import 'package:mysql1/mysql1.dart';
import '../models/alumno.dart';

class DatabaseService {
  static const String _host = '10.0.2.2'; // IP especial para emulador Android
  static const int _port = 3306;
  static const String _user = 'root';
  static const String _password = '';
  static const String _db = 'escuela_db';

  // Configuración de conexión MySQL
  static final ConnectionSettings _settings = ConnectionSettings(
    host: _host,
    port: _port,
    user: _user,
    password: _password,
    db: _db,
  );

  // Crear conexión
  static Future<MySqlConnection> _getConnection() async {
    try {
      return await MySqlConnection.connect(_settings);
    } catch (e) {
      throw Exception('Error al conectar con la base de datos: $e');
    }
  }

  // Inicializar la base de datos y tabla
  static Future<void> initializeDatabase() async {
    MySqlConnection? conn;
    try {
      // Conectar sin especificar base de datos
      final settingsWithoutDb = ConnectionSettings(
        host: _host,
        port: _port,
        user: _user,
        password: _password,
      );
      
      conn = await MySqlConnection.connect(settingsWithoutDb);
      
      // Crear la base de datos si no existe
      await conn.query('CREATE DATABASE IF NOT EXISTS $_db');
      await conn.query('USE $_db');
      
      // Crear la tabla alumnos si no existe
      await conn.query('''
        CREATE TABLE IF NOT EXISTS alumnos (
          id INT AUTO_INCREMENT PRIMARY KEY,
          nombres VARCHAR(100) NOT NULL,
          apellidos VARCHAR(100) NOT NULL,
          codigo VARCHAR(20) UNIQUE NOT NULL,
          direccion TEXT NOT NULL,
          numero VARCHAR(20) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
      ''');
      
      print('Base de datos inicializada correctamente');
    } catch (e) {
      throw Exception('Error al inicializar la base de datos: $e');
    } finally {
      await conn?.close();
    }
  }

  // Obtener todos los alumnos
  static Future<List<Alumno>> getAllAlumnos() async {
    MySqlConnection? conn;
    try {
      conn = await _getConnection();
      final results = await conn.query('SELECT * FROM alumnos ORDER BY apellidos, nombres');
      
      return results.map((row) => Alumno.fromJson({
        'id': row['id'],
        'nombres': row['nombres'],
        'apellidos': row['apellidos'],
        'codigo': row['codigo'],
        'direccion': row['direccion'],
        'numero': row['numero'],
      })).toList();
    } catch (e) {
      throw Exception('Error al obtener alumnos: $e');
    } finally {
      await conn?.close();
    }
  }

  // Obtener un alumno por ID
  static Future<Alumno?> getAlumnoById(int id) async {
    MySqlConnection? conn;
    try {
      conn = await _getConnection();
      final results = await conn.query('SELECT * FROM alumnos WHERE id = ?', [id]);
      
      if (results.isEmpty) return null;
      
      final row = results.first;
      return Alumno.fromJson({
        'id': row['id'],
        'nombres': row['nombres'],
        'apellidos': row['apellidos'],
        'codigo': row['codigo'],
        'direccion': row['direccion'],
        'numero': row['numero'],
      });
    } catch (e) {
      throw Exception('Error al obtener alumno: $e');
    } finally {
      await conn?.close();
    }
  }

  // Crear un nuevo alumno
  static Future<int> createAlumno(Alumno alumno) async {
    MySqlConnection? conn;
    try {
      conn = await _getConnection();
      
      // Verificar si el código ya existe
      final existingResults = await conn.query(
        'SELECT COUNT(*) as count FROM alumnos WHERE codigo = ?', 
        [alumno.codigo]
      );
      
      if (existingResults.first['count'] > 0) {
        throw Exception('El código ${alumno.codigo} ya existe');
      }
      
      final result = await conn.query(
        'INSERT INTO alumnos (nombres, apellidos, codigo, direccion, numero) VALUES (?, ?, ?, ?, ?)',
        [alumno.nombres, alumno.apellidos, alumno.codigo, alumno.direccion, alumno.numero]
      );
      
      return result.insertId!;
    } catch (e) {
      throw Exception('Error al crear alumno: $e');
    } finally {
      await conn?.close();
    }
  }

  // Actualizar un alumno
  static Future<bool> updateAlumno(Alumno alumno) async {
    MySqlConnection? conn;
    try {
      if (alumno.id == null) {
        throw Exception('ID del alumno es requerido para actualizar');
      }
      
      conn = await _getConnection();
      
      // Verificar si el código ya existe en otro registro
      final existingResults = await conn.query(
        'SELECT COUNT(*) as count FROM alumnos WHERE codigo = ? AND id != ?', 
        [alumno.codigo, alumno.id]
      );
      
      if (existingResults.first['count'] > 0) {
        throw Exception('El código ${alumno.codigo} ya existe');
      }
      
      final result = await conn.query(
        'UPDATE alumnos SET nombres = ?, apellidos = ?, codigo = ?, direccion = ?, numero = ? WHERE id = ?',
        [alumno.nombres, alumno.apellidos, alumno.codigo, alumno.direccion, alumno.numero, alumno.id]
      );
      
      return result.affectedRows! > 0;
    } catch (e) {
      throw Exception('Error al actualizar alumno: $e');
    } finally {
      await conn?.close();
    }
  }

  // Eliminar un alumno
  static Future<bool> deleteAlumno(int id) async {
    MySqlConnection? conn;
    try {
      conn = await _getConnection();
      final result = await conn.query('DELETE FROM alumnos WHERE id = ?', [id]);
      
      return result.affectedRows! > 0;
    } catch (e) {
      throw Exception('Error al eliminar alumno: $e');
    } finally {
      await conn?.close();
    }
  }

  // Buscar alumnos por nombre o código
  static Future<List<Alumno>> searchAlumnos(String query) async {
    MySqlConnection? conn;
    try {
      conn = await _getConnection();
      final searchPattern = '%$query%';
      
      final results = await conn.query(
        'SELECT * FROM alumnos WHERE nombres LIKE ? OR apellidos LIKE ? OR codigo LIKE ? ORDER BY apellidos, nombres',
        [searchPattern, searchPattern, searchPattern]
      );
      
      return results.map((row) => Alumno.fromJson({
        'id': row['id'],
        'nombres': row['nombres'],
        'apellidos': row['apellidos'],
        'codigo': row['codigo'],
        'direccion': row['direccion'],
        'numero': row['numero'],
      })).toList();
    } catch (e) {
      throw Exception('Error al buscar alumnos: $e');
    } finally {
      await conn?.close();
    }
  }

  // Verificar conexión a la base de datos
  static Future<bool> testConnection() async {
    MySqlConnection? conn;
    try {
      print('🔄 Intentando conectar a MySQL...');
      print('Host: $_host, Puerto: $_port, Usuario: $_user');
      
      conn = await _getConnection();
      await conn.query('SELECT 1');
      print('✅ Conexión exitosa a MySQL');
      return true;
    } catch (e) {
      print('❌ Error de conexión: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }
}