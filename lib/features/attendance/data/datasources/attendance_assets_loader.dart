import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_import_service.dart';

class AttendanceAssetsLoader {
  final FirebaseFirestore _firestore;

  AttendanceAssetsLoader(this._firestore);

  /// Carga y procesa automáticamente los archivos JSON de assets
  /// Detecta la compañía del nombre del archivo
  Future<void> loadAndImportFromAssets() async {
    try {
      // Lista de archivos JSON conocidos
      final files = [
        'assets/data/asis_helaco_20-10-25a25-10-25.json',
        // Agregar más archivos aquí según sea necesario
      ];

      for (final filePath in files) {
        try {
          // Cargar el archivo
          final jsonString = await rootBundle.loadString(filePath);
          final jsonData = jsonDecode(jsonString);

          // Detectar compañía del nombre del archivo
          final company = _detectCompanyFromFileName(filePath);

          if (company != null && jsonData is List) {
            // Importar los datos
            final service = AttendanceImportService(_firestore);
            await service.importAttendanceFromJson(jsonData, company);
            print('✅ Importados datos de $company desde $filePath');
          }
        } catch (e) {
          print('⚠️ Error procesando $filePath: $e');
        }
      }
    } catch (e) {
      print('❌ Error en loadAndImportFromAssets: $e');
    }
  }

  /// Detecta la compañía del nombre del archivo
  /// Ej: "asis_helaco_20-10-25a25-10-25.json" -> "Helaco"
  String? _detectCompanyFromFileName(String filePath) {
    final fileName = filePath.toLowerCase();

    if (fileName.contains('helaco')) {
      return 'Helaco';
    } else if (fileName.contains('jaysa') ||
        fileName.contains('jaysa_muebles')) {
      return 'Jaysa Muebles';
    }

    return null;
  }

  /// Obtiene la lista de archivos JSON disponibles en assets
  /// (Para futuras expansiones)
  Future<List<String>> getAvailableFiles() async {
    // Esta es una lista estática por ahora
    // En el futuro se podría usar asset_manifest.json
    return [
      'assets/data/asis_helaco_20-10-25a25-10-25.json',
    ];
  }
}
