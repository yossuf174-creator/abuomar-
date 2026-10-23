import 'package:flutter/material.dart';

void main() {
  runApp(const ElectricalSimulatorApp());
}

class ElectricalSimulatorApp extends StatelessWidget {
  const ElectricalSimulatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Electrical Circuit Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const SimulatorHomePage(),
    );
  }
}

class SimulatorHomePage extends StatefulWidget {
  const SimulatorHomePage({Key? key}) : super(key: key);

  @override
  State<SimulatorHomePage> createState() => _SimulatorHomePageState();
}

class _SimulatorHomePageState extends State<SimulatorHomePage> {
  // حالات العناصر والقواطع في الدائرة
  bool isSourceActive = true;
  bool isMcbOn = true;
  bool isRcboOn = true;
  double sourceVoltage = 230.0;
  double loadResistance = 1000.0; // أوم (1 كيلو أوم)
  double capacitanceValue = 0.001; // فاراد (1 ملي فاراد)

  // متغيرات نتائج المحاكاة
  double calculatedVoltage = 0.0;
  double calculatedCurrent = 0.0;
  String simulationStatus = 'جاهز للمحاكاة';

  void runAdvancedSimulation() {
    if (!isSourceActive || !isMcbOn || !isRcboOn) {
      setState(() {
        calculatedVoltage = 0.0;
        calculatedCurrent = 0.0;
        simulationStatus = 'الدائرة مفصولة (تأكد من القواطع والمصدر)';
      });
      return;
    }

    // تطبيق منطق الحسابات الكهربائية
    double v = sourceVoltage;
    double i = loadResistance > 0 ? v / loadResistance : 0.0;

    setState(() {
      calculatedVoltage = v;
      calculatedCurrent = i;
      simulationStatus = 'تمت المحاكاة بنجاح بجهد ${v.toStringAsFixed(1)} فولت';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('محاكي الدوائر الكهربائية الهندسي'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // شاشة لوحة القياس الرقمية الاحترافية
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMeterReading('الجهد (V)', '${calculatedVoltage.toStringAsFixed(1)} V', Colors.redAccent),
                _buildMeterReading('التيار (I)', '${calculatedCurrent.toStringAsFixed(3)} A', Colors.blueAccent),
                _buildMeterReading('الحمل (R)', '${loadResistance.toStringAsFixed(0)} Ω', Colors.greenAccent),
              ],
            ),
          ),

          // لوحة الرسم والمحاكاة التفاعلية المرئية
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(
                painter: CircuitPainter(
                  mcbOn: isMcbOn,
                  rcboOn: isRcboOn,
                  active: isSourceActive,
                ),
                child: Center(
                  child: Text(
                    simulationStatus,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),

          // لوحة التحكم بالقواطع والمصادر والمقاومة
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[850],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMcbOn ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          isMcbOn = !isMcbOn;
                        });
                        runAdvancedSimulation();
                      },
                      icon: const Icon(Icons.power),
                      label: Text(isMcbOn ? 'MCB: شغال' : 'MCB: مفصول'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRcboOn ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          isRcboOn = !isRcboOn;
                        });
                        runAdvancedSimulation();
                      },
                      icon: const Icon(Icons.security),
                      label: Text(isRcboOn ? 'RCBO: شغال' : 'RCBO: مفصول'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(
                  value: loadResistance,
                  min: 10,
                  max: 2000,
                  divisions: 50,
                  label: '${loadResistance.toStringAsFixed(0)} أوم',
                  onChanged: (value) {
                    setState(() {
                      loadResistance = value;
                    });
                    runAdvancedSimulation();
                  },
                ),
                Text('قيمة المقاومة: ${loadResistance.toStringAsFixed(0)} أوم', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: runAdvancedSimulation,
                  child: const Text('تشغيل تحليل الدائرة الانتقالي'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeterReading(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

// رسام الدائرة الكهربائية المخصص للأسلاك (حار، بارد، أرضي)
class CircuitPainter extends CustomPainter {
  final bool mcbOn;
  final bool rcboOn;
  final bool active;

  CircuitPainter({required this.mcbOn, required this.rcboOn, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final paintPhase = Paint()
      ..color = (active && mcbOn && rcboOn) ? Colors.redAccent : Colors.grey
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final paintNeutral = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final paintGround = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // مسارات الأسلاك المعيارية الرئيسية
    canvas.drawLine(const Offset(40, 40), const Offset(200, 40), paintPhase);
    canvas.drawLine(const Offset(200, 40), const Offset(200, 120), paintPhase);

    canvas.drawLine(const Offset(40, 90), const Offset(160, 90), paintNeutral);
    canvas.drawLine(const Offset(40, 140), const Offset(120, 140), paintGround);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
