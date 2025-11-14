import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:j_intranet/core/constants/app_colors.dart';
import '../../.././attendance/data/datasources/attendance_import_service.dart';

class ImportAttendanceScreen extends StatefulWidget {
  const ImportAttendanceScreen({super.key});

  @override
  State<ImportAttendanceScreen> createState() => _ImportAttendanceScreenState();
}

class _ImportAttendanceScreenState extends State<ImportAttendanceScreen> {
  final _jsonController = TextEditingController();
  String _selectedCompany = 'Jaysa Muebles';
  bool _isLoading = false;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _importData() async {
    if (_jsonController.text.isEmpty) {
      _showSnackBar('❌ Por favor pega el JSON', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parsear JSON
      final jsonData = jsonDecode(_jsonController.text);

      if (jsonData is! List) {
        _showSnackBar('❌ El JSON debe ser un array', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      // Importar asistencias
      final service = AttendanceImportService(FirebaseFirestore.instance);
      await service.importAttendanceFromJson(jsonData, _selectedCompany);

      // Limpiar y mostrar éxito
      _jsonController.clear();
      _showSnackBar(
        '✅ ${jsonData.length} empleados importados correctamente',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('❌ Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
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

  void _clearJson() {
    _jsonController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        title: const Text('Importar Asistencias'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 Instrucciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Selecciona la compañía\n'
                        '2. Pega el JSON con las asistencias\n'
                        '3. Presiona "Importar"\n\n'
                        'Formato esperado:\n'
                        '[{"colaborador":"Nombre","asistencias":["lunes, 20 de octubre de 2025 7:27:00 AM",...]}]',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Selección de compañía
              const Text(
                'Compañía',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedCompany,
                  isExpanded: true,
                  underline: const SizedBox(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: const [
                    DropdownMenuItem(
                      value: 'Jaysa Muebles',
                      child: Text('Jaysa Muebles'),
                    ),
                    DropdownMenuItem(
                      value: 'Helaco',
                      child: Text('Helaco'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCompany = value!);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Campo de JSON
              const Text(
                'JSON de Asistencias',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _jsonController,
                  decoration: InputDecoration(
                    hintText: 'Pega el JSON aquí...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  maxLines: 12,
                  minLines: 8,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
                ),
              ),
              const SizedBox(height: 20),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _clearJson,
                      icon: const Icon(Icons.clear),
                      label: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _importData,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.upload),
                      label: Text(_isLoading ? 'Importando...' : 'Importar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Información adicional
              Card(
                color: Colors.blue[50],
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 Información',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Las asistencias se guardarán en Firestore\n'
                        '• Entrada antes de 9:00 AM = Puntual\n'
                        '• Entrada después de 9:15 AM = Tarde\n'
                        '• Se detectan automáticamente entrada/salida por hora',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
