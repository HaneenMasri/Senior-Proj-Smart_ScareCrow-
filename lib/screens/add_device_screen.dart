import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDeviceScreen extends StatefulWidget {
  final String? existingId; // معرف الجهاز للتعديل
  final String? existingName; // اسم الجهاز للتعديل

  const AddDeviceScreen({super.key, this.existingId, this.existingName});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  late final TextEditingController _idController;
  late final TextEditingController _nameController;

  String? _idError;
  String? _nameError;
  bool _isLoading = false;

  // هل نحن في وضع التعديل؟
  bool get isEditMode => widget.existingId != null;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.existingId);
    _nameController = TextEditingController(text: widget.existingName);
  }

  Future<void> _saveDevice() async {
    final String deviceId = _idController.text.trim();
    final String deviceName = _nameController.text.trim();

    setState(() {
      _idError = deviceId.isEmpty ? 'Hardware ID is required' : null;
      _nameError = deviceName.isEmpty ? 'Device Name is required' : null;
    });

    if (deviceId.isEmpty || deviceName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // في وضع التعديل نستخدم .update لتجنب الكتابة فوق الحقول الأخرى غير الموجودة هنا
      if (isEditMode) {
        await FirebaseFirestore.instance
            .collection('pi-devices')
            .doc(deviceId)
            .update({'name': deviceName});
      } else {
        // وضع الإضافة الجديد
        await FirebaseFirestore.instance
            .collection('pi-devices')
            .doc(deviceId)
            .set({'deviceId': deviceId, 'name': deviceName});

        // إضافة سجل البداية فقط عند الإضافة لأول مرة
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
      }

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
        title: Text(
          isEditMode ? 'Edit Device' : 'New Device',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(
              isEditMode ? Icons.edit_note_rounded : Icons.sensors_rounded,
              size: 100,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Text(
              // تغيير النص الأساسي
              isEditMode ? "Update Settings" : "Setup Your Scarecrow",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              // تغيير النص الفرعي
              isEditMode
                  ? "Modify your device information below"
                  : "Connect your hardware to the cloud",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _idController,
              enabled: !isEditMode,
              decoration: InputDecoration(
                labelText: 'Device ID',
                prefixIcon: const Icon(Icons.qr_code_scanner),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                errorText: _idError,
                filled: isEditMode,
                fillColor: isEditMode ? Colors.grey[100] : null,
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Device Name',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveDevice,
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
                    : Text(
                        isEditMode ? 'Update Device' : 'Add Device',
                        style: const TextStyle(
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
