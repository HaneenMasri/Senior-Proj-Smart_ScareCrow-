import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _idError;
  String? _nameError;
  bool _isLoading = false;

  Future<void> _addDevice() async {
    final String deviceId = _idController.text.trim();
    final String deviceName = _nameController.text.trim();

    setState(() {
      _idError = deviceId.isEmpty ? 'Hardware ID is required' : null;
      _nameError = deviceName.isEmpty ? 'Device Name is required' : null;
    });

    if (deviceId.isEmpty || deviceName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // حفظ البيانات الأساسية في المسار المتفق عليه
      await FirebaseFirestore.instance
          .collection('pi-devices')
          .doc(deviceId)
          .set({'deviceId': deviceId, 'name': deviceName});

      await FirebaseFirestore.instance
          .collection('pi-devices')
          .doc(deviceId)
          .collection('motionEvents')
          .add({
            'deviceId': deviceId,
            'ts': FieldValue.serverTimestamp(),
            'gpio': 17,
            'state': 'initialized',
          });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' New Device'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // 1. أيقونة كبيرة في الأعلى لتعزيز شكل الصفحة
            const SizedBox(height: 20),
            Icon(
              Icons.sensors_rounded, // أيقونة تعبر عن الحساسات والاتصال
              size: 100,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 10),
            const Text(
              "Setup Your Scarecrow",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Connect your hardware to the cloud",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Device ID', // العنوان الذي سيظهر فوق
                hintText: 'e.g. Scarecrow-01', // النص الذي سيظهر داخل
                floatingLabelBehavior:
                    FloatingLabelBehavior.always, // جعله دائماً فوق
                prefixIcon: const Icon(Icons.qr_code_scanner),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                errorText: _idError,
              ),
            ),

            const SizedBox(height: 25),

            // 3. حقل الاسم (Device Name) بنفس التنسيق
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Device Name',
                hintText: 'e.g. Front Garden Camera',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                errorText: _nameError,
              ),
            ),

            const SizedBox(height: 40),

            // زر الإضافة بتصميم عصري
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add device',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
