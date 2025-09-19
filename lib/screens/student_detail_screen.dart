import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../services/database_service.dart';

class StudentDetailScreen extends StatefulWidget {
  final Alumno alumno;

  const StudentDetailScreen({super.key, required this.alumno});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _codigoController;
  late TextEditingController _direccionController;
  late TextEditingController _numeroController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(text: widget.alumno.nombres);
    _apellidosController = TextEditingController(text: widget.alumno.apellidos);
    _codigoController = TextEditingController(text: widget.alumno.codigo);
    _direccionController = TextEditingController(text: widget.alumno.direccion);
    _numeroController = TextEditingController(text: widget.alumno.numero);
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _codigoController.dispose();
    _direccionController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _updateAlumno() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedAlumno = widget.alumno.copyWith(
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        codigo: _codigoController.text.trim(),
        direccion: _direccionController.text.trim(),
        numero: _numeroController.text.trim(),
      );

      await DatabaseService.updateAlumno(updatedAlumno);
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alumno actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAlumno() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar a ${widget.alumno.nombreCompleto}?'),
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
      setState(() => _isLoading = true);

      try {
        await DatabaseService.deleteAlumno(widget.alumno.id!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alumno eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop('deleted');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Restaurar valores originales
      _nombresController.text = widget.alumno.nombres;
      _apellidosController.text = widget.alumno.apellidos;
      _codigoController.text = widget.alumno.codigo;
      _direccionController.text = widget.alumno.direccion;
      _numeroController.text = widget.alumno.numero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Alumno' : 'Detalles del Alumno'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteAlumno,
              tooltip: 'Eliminar',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar del alumno
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          widget.alumno.nombres.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campos del formulario
                    _buildTextField(
                      controller: _nombresController,
                      label: 'Nombres',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Los nombres son requeridos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _apellidosController,
                      label: 'Apellidos',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Los apellidos son requeridos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _codigoController,
                      label: 'Código',
                      icon: Icons.badge,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El código es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _direccionController,
                      label: 'Dirección',
                      icon: Icons.location_on,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La dirección es requerida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _numeroController,
                      label: 'Número de teléfono',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El número de teléfono es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botones de acción
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _cancelEdit,
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updateAlumno,
                              child: const Text('Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar Información'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _deleteAlumno,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Eliminar Alumno', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: !_isEditing,
        fillColor: _isEditing ? null : Colors.grey[100],
      ),
    );
  }
}