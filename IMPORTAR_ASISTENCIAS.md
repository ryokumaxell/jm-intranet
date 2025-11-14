# Importar Asistencias desde JSON

## Descripción
Este documento explica cómo importar registros de asistencia desde un archivo JSON a Firestore.

## Formato del JSON
El JSON debe tener la siguiente estructura:

```json
[
  {
    "colaborador": "Juan De La Cruz",
    "asistencias": [
      "lunes, 20 de octubre de 2025 7:27:00 AM",
      "lunes, 20 de octubre de 2025 5:01:00 PM",
      "martes, 21 de octubre de 2025 8:01:00 AM"
    ]
  },
  {
    "colaborador": "Carlos Cornielle Feliz",
    "asistencias": [
      "lunes, 20 de octubre de 2025 7:53:00 AM",
      "lunes, 20 de octubre de 2025 5:01:00 PM"
    ]
  }
]
```

## Cómo funciona

### 1. **Servicio de Importación**
Ubicación: `lib/features/attendance/data/datasources/attendance_import_service.dart`

El servicio procesa cada registro de asistencia:
- Parsea fechas en formato español
- Determina si es entrada (mañana) o salida (tarde)
- Calcula el estado (puntual, tarde, ausente)
- Guarda en Firestore en batch

### 2. **Parseo de Fechas**
Convierte: `"lunes, 20 de octubre de 2025 7:27:00 AM"`

A: `DateTime(2025, 10, 20, 7, 27)`

Soporta:
- Días de la semana en español (lunes, martes, etc.)
- Meses en español (enero, febrero, ..., diciembre)
- Formato 12 horas (AM/PM)

### 3. **Determinación de Estado**
- **Entrada antes de 9:00 AM**: Puntual
- **Entrada 9:00-9:15 AM**: Puntual
- **Entrada después de 9:15 AM**: Tarde
- **Salida (PM)**: Puntual

## Cómo usar

### Opción 1: Desde la Pantalla de Asistencia
Crear un botón de importación en `attendance_screen.dart`:

```dart
FloatingActionButton(
  onPressed: () async {
    final service = AttendanceImportService(FirebaseFirestore.instance);
    await service.importAttendanceFromJson(jsonData, 'Jaysa Muebles');
  },
  child: const Icon(Icons.upload),
)
```

### Opción 2: Crear una Pantalla de Importación
Nueva pantalla en `lib/features/attendance/presentation/screens/import_attendance_screen.dart`:

```dart
class ImportAttendanceScreen extends StatefulWidget {
  @override
  State<ImportAttendanceScreen> createState() => _ImportAttendanceScreenState();
}

class _ImportAttendanceScreenState extends State<ImportAttendanceScreen> {
  final _jsonController = TextEditingController();
  String _selectedCompany = 'Jaysa Muebles';

  void _importData() async {
    try {
      final jsonData = jsonDecode(_jsonController.text);
      final service = AttendanceImportService(FirebaseFirestore.instance);
      await service.importAttendanceFromJson(jsonData, _selectedCompany);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Asistencias importadas')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar Asistencias')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCompany,
              items: const [
                DropdownMenuItem(value: 'Jaysa Muebles', child: Text('Jaysa Muebles')),
                DropdownMenuItem(value: 'Helaco', child: Text('Helaco')),
              ],
              onChanged: (value) => setState(() => _selectedCompany = value!),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _jsonController,
                decoration: const InputDecoration(
                  hintText: 'Pega el JSON aquí',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _importData,
              child: const Text('Importar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Opción 3: Script de Importación
Crear un archivo `lib/scripts/import_attendance.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../features/attendance/data/datasources/attendance_import_service.dart';

Future<void> importAttendance() async {
  final jsonString = '''[...]'''; // Pega el JSON aquí
  final jsonData = jsonDecode(jsonString);
  
  final service = AttendanceImportService(FirebaseFirestore.instance);
  await service.importAttendanceFromJson(jsonData, 'Jaysa Muebles');
  
  print('✅ Importación completada');
}
```

## Estructura en Firestore

Los registros se guardan en la colección `attendance_records`:

```json
{
  "id": "Juan De La Cruz_2025-10-20T07:27:00.000",
  "employeeId": "Juan De La Cruz",
  "employeeName": "Juan De La Cruz",
  "department": "General",
  "date": "2025-10-20T07:27:00.000Z",
  "entry": "2025-10-20T07:27:00.000Z",
  "exit": null,
  "hoursWorked": 8.0,
  "status": "punctual",
  "company": "Jaysa Muebles"
}
```

## Notas Importantes

1. **Nombres de Empleados**: Deben coincidir exactamente con los nombres en el sistema
2. **Compañía**: Especificar "Jaysa Muebles" o "Helaco"
3. **Batch**: Se importan en batch para mejor rendimiento
4. **Duplicados**: Si se importa dos veces, se crearán registros duplicados
5. **Horas Trabajadas**: Se asume 8 horas por defecto

## Troubleshooting

### Error: "Invalid date format"
- Verifica que el formato sea: `"día, DD de mes de YYYY HH:MM:SS AM/PM"`
- Ejemplo: `"lunes, 20 de octubre de 2025 7:27:00 AM"`

### Error: "Batch commit failed"
- Verifica que tengas permisos de escritura en Firestore
- Revisa las reglas de seguridad

### Registros no aparecen
- Verifica que la compañía sea correcta
- Revisa la consola para mensajes de error
- Verifica que el usuario tenga acceso a esa compañía
