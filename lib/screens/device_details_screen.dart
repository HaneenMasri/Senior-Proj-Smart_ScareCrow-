import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // مكتبة الرسم البياني
import 'detected_movements_screen.dart';
import 'package:rxdart/rxdart.dart';

class DeviceDetailsScreen extends StatefulWidget {
  final String deviceId;

  const DeviceDetailsScreen({super.key, required this.deviceId});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  bool _isServoLoading = false;

  bool _isBuzzerLoading = false;
  bool _isCameraLoading = false;

  Future<void> _triggerBuzzer(int duration) async {
    setState(() => _isBuzzerLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('buzzer_control')
          .doc('action')
          .set({
            'action': 'on',
            'duration': duration,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Buzzer Command Sent!')));
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isBuzzerLoading = false);
    }
  }

  Future<void> _takeManualPhoto() async {
    setState(() => _isCameraLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('camera_control')
          .doc('action')
          .set({
            'action': 'on',
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo Request Sent!')));
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isCameraLoading = false);
    }
  }

  Future<void> _triggerServo(int duration) async {
    setState(() => _isServoLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('servo_control')
          .doc('action')
          .set({
            'action': 'on',
            'duration': duration,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Command Sent!')));
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isServoLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deviceId != 'raspberrypi') {
      return _buildConnectingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Device: ${widget.deviceId}",
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
        backgroundColor: Colors.green.shade700,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pi-devices')
            .doc(widget.deviceId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildImagePreview(),
              const SizedBox(height: 20),

              _buildServoButton(),
              const SizedBox(height: 10),
              _buildBuzzerButton(),
              const SizedBox(height: 10),
              _buildCameraButton(),

              const SizedBox(height: 25),
              const Text(
                "Weekly Activity Status",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _buildActivityChart(),

              const SizedBox(height: 25),
              _buildHistoryButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBuzzerButton() {
    return ElevatedButton.icon(
      onPressed: _isBuzzerLoading ? null : () => _triggerBuzzer(5),
      icon: _isBuzzerLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.volume_up),
      label: const Text("Sound Alarm (Buzzer)"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCameraButton() {
    return ElevatedButton.icon(
      onPressed: _isCameraLoading ? null : _takeManualPhoto,
      icon: _isCameraLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.camera_alt),
      label: const Text("Capture Live Photo"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildConnectingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Device: ${widget.deviceId}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.green),
            const SizedBox(height: 24),
            const Icon(
              Icons.router_outlined,
              size: 80,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),
            const Text(
              "Connecting...",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Configuring device: ${widget.deviceId}",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('detections')
          .where('timestamp', isGreaterThanOrEqualTo: sevenDaysAgo)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading chart");
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        Map<int, int> dayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

        for (var doc in snapshot.data!.docs) {
          Timestamp? ts = doc['timestamp'] as Timestamp?;
          if (ts != null) {
            int day = ts.toDate().weekday;
            dayCounts[day] = (dayCounts[day] ?? 0) + 1;
          }
        }

        return Container(
          height: 250,
          padding: const EdgeInsets.only(
            top: 20,
            right: 20,
            left: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              minY: 0,
              barGroups: dayCounts.entries
                  .map(
                    (e) => BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.toDouble() > 100
                              ? 100
                              : e.value.toDouble(),
                          color: Colors.green,
                          width: 14,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mn', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          days[value.toInt() - 1],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return StreamBuilder<List<QuerySnapshot>>(
      stream: CombineLatestStream.list([
        FirebaseFirestore.instance
            .collection('camera_live_images')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots(),
        FirebaseFirestore.instance
            .collection('detections')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            (snapshot.data![0].docs.isEmpty &&
                snapshot.data![1].docs.isEmpty)) {
          return _buildPlaceholder();
        }

        // استخراج أحدث وثيقة من المجموعتين بناءً على الـ timestamp
        DocumentSnapshot? liveDoc = snapshot.data![0].docs.isNotEmpty
            ? snapshot.data![0].docs.first
            : null;
        DocumentSnapshot? detectDoc = snapshot.data![1].docs.isNotEmpty
            ? snapshot.data![1].docs.first
            : null;

        DocumentSnapshot latestDoc;
        if (liveDoc != null && detectDoc != null) {
          Timestamp tLive = liveDoc['timestamp'] ?? Timestamp(0, 0);
          Timestamp tDetect = detectDoc['timestamp'] ?? Timestamp(0, 0);
          // مقارنة الطوابع الزمنية لعرض الأحدث فعلياً
          latestDoc = tLive.compareTo(tDetect) > 0 ? liveDoc : detectDoc;
        } else {
          latestDoc = liveDoc ?? detectDoc!;
        }

        var data = latestDoc.data() as Map<String, dynamic>;
        String? url = data['image_url'];
        // تحديد النص التوضيحي بناءً على مصدر الصورة
        String sourceLabel =
            latestDoc.reference.parent.id == 'camera_live_images'
            ? "Live Capture"
            : (data['label'] ?? "Detection");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                "Live Security Feed",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            _imageFrame(url, sourceLabel, data['confidence']),
          ],
        );
      },
    );
  }

  // دالة مساعدة لتنسيق واجهة الصورة
  Widget _imageFrame(String? url, String label, dynamic confidence) {
    double confPercent = (confidence ?? 0.0) * 100;
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: url != null
                ? Image.network(url, fit: BoxFit.contain)
                : const SizedBox(),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (confPercent > 0)
                  Text(
                    "${confPercent.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: Icon(
          Icons.camera_enhance_outlined,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildServoButton() {
    return ElevatedButton.icon(
      onPressed: _isServoLoading ? null : () => _triggerServo(5),
      icon: _isServoLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.vpn_key),
      label: const Text("Open Gate"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHistoryButton() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.history, color: Colors.white),
      ),
      title: const Text(
        "Movement History",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetectedMovementsScreen(deviceId: widget.deviceId),
          ),
        );
      },
    );
  }
}
