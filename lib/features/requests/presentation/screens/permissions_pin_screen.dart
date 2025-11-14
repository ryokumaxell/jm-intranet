import 'dart:html' as html;
import 'package:flutter/material.dart';

class PermissionsFormScreen extends StatefulWidget {
  const PermissionsFormScreen({super.key});
  @override
  State<PermissionsFormScreen> createState() => _PermissionsFormScreenState();
}

class _PermissionsFormScreenState extends State<PermissionsFormScreen> {
  bool _granted = false;

  @override
  void initState() {
    super.initState();
    final ok = html.window.localStorage['permiso_form_access'] == '1';
    _granted = ok;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_granted) _showPinModal();
    });
  }

  void _showPinModal() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Acceso al formulario'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ingresa 4 dígitos para continuar'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    hintText: '••••',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).maybePop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final code = controller.text.trim();
                final isValid = RegExp(r'^\d{4}$').hasMatch(code);
                if (!isValid) return;
                html.window.localStorage['permiso_form_access'] = '1';
                setState(() => _granted = true);
                Navigator.of(context).pop();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de Permisos')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _granted
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Solicitud de Permiso', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      const TextField(decoration: InputDecoration(labelText: 'Empleado', prefixIcon: Icon(Icons.person))),
                      const SizedBox(height: 12),
                      const TextField(decoration: InputDecoration(labelText: 'Motivo', prefixIcon: Icon(Icons.edit))),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Expanded(child: TextField(decoration: InputDecoration(labelText: 'Desde', prefixIcon: Icon(Icons.calendar_today)))),
                          SizedBox(width: 12),
                          Expanded(child: TextField(decoration: InputDecoration(labelText: 'Hasta', prefixIcon: Icon(Icons.calendar_today)))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.send), label: const Text('Enviar')),
                      ),
                    ],
                  )
                : const Text('Validando acceso...', style: TextStyle(color: Colors.black54)),
          ),
        ),
      ),
    );
  }
}