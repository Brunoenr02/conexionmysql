import 'package:crudmysql/services/database_service.dart';

void main() async {
  print('🔍 Probando conexión a MySQL...');
  
  // Probar conexión básica
  bool isConnected = await DatabaseService.testConnection();
  
  if (isConnected) {
    print('🎉 ¡Conexión exitosa!');
    
    try {
      print('🔧 Inicializando base de datos...');
      await DatabaseService.initializeDatabase();
      print('✅ Base de datos inicializada correctamente');
      
      print('📊 Obteniendo lista de alumnos...');
      var alumnos = await DatabaseService.getAllAlumnos();
      print('✅ Consulta exitosa. Alumnos encontrados: ${alumnos.length}');
      
    } catch (e) {
      print('❌ Error al inicializar base de datos: $e');
    }
  } else {
    print('❌ No se pudo conectar a MySQL');
    print('');
    print('🔧 Verifica que:');
    print('   1. MySQL esté corriendo');
    print('   2. Las credenciales sean correctas');
    print('   3. El puerto 3306 esté disponible');
  }
}