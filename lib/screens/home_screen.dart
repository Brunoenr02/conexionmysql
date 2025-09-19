import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../services/database_service.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Alumno> alumnos = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Inicializar la base de datos
      await DatabaseService.initializeDatabase();
      
      // Cargar datos
      await _loadAlumnos();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadAlumnos() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await DatabaseService.getAllAlumnos();
      setState(() {
        alumnos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAlumno(Alumno alumno) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar a ${alumno.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseService.deleteAlumno(alumno.id!);
        _showSnackBar('Alumno eliminado correctamente', Colors.green);
        _loadAlumnos();
      } catch (e) {
        _showSnackBar('Error al eliminar: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Alumnos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlumnos,
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddStudent(),
        tooltip: 'Agregar alumno',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando datos...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Error de conexión',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeAndLoadData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (alumnos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay alumnos registrados',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Agrega el primer alumno usando el botón +'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToAddStudent,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Alumno'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlumnos,
      child: ListView.builder(
        itemCount: alumnos.length,
        itemBuilder: (context, index) {
          final alumno = alumnos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  alumno.nombres.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                alumno.nombreCompleto,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Código: ${alumno.codigo}'),
                  Text('Teléfono: ${alumno.numero}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navigateToStudentDetail(alumno),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAlumno(alumno),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
              onTap: () => _navigateToStudentDetail(alumno),
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToAddStudent() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddStudentScreen()),
    );

    if (result == true) {
      _showSnackBar('Alumno agregado correctamente', Colors.green);
      _loadAlumnos();
    }
  }

  Future<void> _navigateToStudentDetail(Alumno alumno) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentDetailScreen(alumno: alumno),
      ),
    );

    if (result == true) {
      _showSnackBar('Alumno actualizado correctamente', Colors.green);
      _loadAlumnos();
    } else if (result == 'deleted') {
      _showSnackBar('Alumno eliminado correctamente', Colors.green);
      _loadAlumnos();
    }
  }
}