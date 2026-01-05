// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'device_details_screen.dart';
import 'add_device_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const HomeScreen(), // HomeTab تم استبداله بـ HomeScreen الديناميكية
    const DevicesTab(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 20,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices_rounded),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/* ====================== DEVICES TAB ====================== */

// ... (كلاس MainScreen يبقى كما هو)

/* ====================== DEVICES TAB (المعدل) ====================== */
class DevicesTab extends StatefulWidget {
  const DevicesTab({super.key});

  @override
  State<DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Devices'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              // استخدمنا StreamBuilder لجلب الأجهزة من فايربيس مباشرة
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pi-devices')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading devices"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("No devices found. Add one!"),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      // جلب بيانات الجهاز من Firestore
                      final deviceData =
                          docs[index].data() as Map<String, dynamic>;
                      final String docId = docs[index].id; // هذا هو معرف الجهاز

                      final battery = deviceData["battery"] ?? 0;
                      final isLow = battery < 30;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: isLow
                                ? Colors.red[100]
                                : Colors.green[100],
                            child: Icon(
                              Icons.device_hub,
                              size: 32,
                              color: isLow
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                          title: Text(
                            deviceData["name"] ?? "Unknown Device",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(deviceData["location"] ?? "No location"),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    isLow
                                        ? Icons.battery_alert
                                        : Icons.battery_full,
                                    size: 18,
                                    color: isLow
                                        ? Colors.red[700]
                                        : Colors.green[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$battery% • ${deviceData['status'] ?? 'Offline'}",
                                    style: TextStyle(
                                      color: isLow
                                          ? Colors.red[700]
                                          : Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            // التعديل المهم هنا: نرسل الـ ID فقط
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DeviceDetailsScreen(deviceId: docId),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // زر إضافة جهاز جديد (يبقى كما هو أو يربط بـ Firestore لاحقاً)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddDeviceScreen(),
                  ),
                ),
                icon: const Icon(Icons.add, size: 26),
                label: const Text("Add new device"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ====================== SETTINGS SCREEN ====================== */
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Update Username'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateTo(context, '/update-username'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateTo(context, '/change-password'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete My Account'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateTo(context, '/delete-account'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About This App'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _navigateTo(context, '/about-app'),
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _navigateTo(context, '/logout'),
          ),
        ],
      ),
    );
  }
}
