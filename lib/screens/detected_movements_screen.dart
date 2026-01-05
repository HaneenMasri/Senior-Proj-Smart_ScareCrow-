import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DetectedMovementsScreen extends StatefulWidget {
  final String deviceId;
  final String initialRange;

  const DetectedMovementsScreen({
    super.key,
    required this.deviceId,
    this.initialRange = '7',
  });

  @override
  State<DetectedMovementsScreen> createState() =>
      _DetectedMovementsScreenState();
}

class _DetectedMovementsScreenState extends State<DetectedMovementsScreen> {
  late String _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    // --- التعديل الجوهري هنا لضبط الزمن ---
    DateTime now = DateTime.now();
    DateTime filterDate;

    if (_selectedRange == '1') {
      // إذا تم اختيار "آخر 24 ساعة"، نجعل الفلترة تبدأ من بداية اليوم الحالي (12:00 AM)
      filterDate = DateTime(now.year, now.month, now.day);
    } else {
      // الخيارات الأخرى تحسب عدد الأيام للوراء من لحظة بداية اليوم الحالي
      filterDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: int.parse(_selectedRange) - 1));
    }
    // ---------------------------------------

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Detected Movements",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterHeader(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('detections')
                  .where('timestamp', isGreaterThanOrEqualTo: filterDate)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDynamicChart(docs),
                    const SizedBox(height: 24),
                    const Text(
                      "Detection History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildImageGrid(docs),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "DETECTED MOVEMENTS",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: _selectedRange,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(
                value: '1',
                child: Text("Today"),
              ), // تم تغيير النص ليكون أدق
              DropdownMenuItem(value: '5', child: Text("Last 5 Days")),
              DropdownMenuItem(value: '7', child: Text("Last 7 Days")),
              DropdownMenuItem(value: '30', child: Text("Last Month")),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRange = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicChart(List<QueryDocumentSnapshot> docs) {
    Map<int, int> dayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var doc in docs) {
      DateTime date = (doc['timestamp'] as Timestamp).toDate();
      int day = date.weekday;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 20, right: 20, left: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          barGroups: [1, 2, 3, 4, 5, 6, 7].map((day) {
            double value = (dayCounts[day] ?? 0).toDouble();
            return BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: value > 100 ? 100 : value,
                  color: value > 0
                      ? Colors.orange.shade400
                      : Colors.transparent,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) {
                  const days = ['Mn', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
                  if (v < 1 || v > 7) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[v.toInt() - 1],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
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
  }

  Widget _buildImageGrid(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Center(
        child: Text("No movements detected for this period."),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var data = docs[index].data() as Map<String, dynamic>;
        String formattedTime = DateFormat(
          'dd/MM/yyyy - hh:mm a',
        ).format((data['timestamp'] as Timestamp).toDate());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  data['image_url'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}
