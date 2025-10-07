import 'package:flutter/material.dart';

void main() {
  runApp(const CampCostApp());
}

class CampCostApp extends StatelessWidget {
  const CampCostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'キャンプ費用計算',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const CampCostPage(),
    );
  }
}

class CampCostPage extends StatefulWidget {
  const CampCostPage({super.key});

  @override
  State<CampCostPage> createState() => _CampCostPageState();
}

class _CampCostPageState extends State<CampCostPage> {
  int people = 4;
  double food = 10000;
  double transport = 8000;
  double camp = 12000;

  // メンバー用
  List<TextEditingController> nameControllers = [];
  List<bool> foodExempt = [];
  List<bool> transportExempt = [];
  List<bool> campExempt = [];
  List<double> results = [];

  @override
  void initState() {
    super.initState();
    _initMembers();
  }

  void _initMembers() {
    nameControllers = List.generate(
      people,
      (i) => TextEditingController(text: 'メンバー${i + 1}'), // 初期名をセット
    );
    foodExempt = List.filled(people, false);
    transportExempt = List.filled(people, false);
    campExempt = List.filled(people, false);
    results = [];
  }

  void _changePeople(int delta) {
    setState(() {
      people = (people + delta).clamp(1, 20); // 1〜20人
      _initMembers(); // 名前やチェックもリセット
    });
  }

  void calculate() {
    int foodContributors = foodExempt.where((e) => !e).length;
    int transportContributors = transportExempt.where((e) => !e).length;
    int campContributors = campExempt.where((e) => !e).length;

    double foodPer = foodContributors > 0 ? food / foodContributors : 0;
    double transportPer = transportContributors > 0 ? transport / transportContributors : 0;
    double campPer = campContributors > 0 ? camp / campContributors : 0;

    List<double> newResults = [];
    for (int i = 0; i < people; i++) {
      double total = 0;
      if (!foodExempt[i]) total += foodPer;
      if (!transportExempt[i]) total += transportPer;
      if (!campExempt[i]) total += campPer;
      newResults.add(total);
    }

    setState(() {
      results = newResults;
    });
  }

  Widget _buildResultList() {
    if (results.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text("計算結果", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...List.generate(results.length, (index) {
          final name = nameControllers[index].text.trim().isEmpty
              ? 'メンバー${index + 1}'
              : nameControllers[index].text;
          return Text("$name: ¥${results[index].toStringAsFixed(0)}");
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("キャンプ費用計算")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 人数カウンター
            Row(
              children: [
                const Text("人数", style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _changePeople(-1),
                ),
                Text("$people 人", style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _changePeople(1),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 費用入力欄（横並び）
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "食費(円)",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                    controller: TextEditingController(text: food.toStringAsFixed(0)),
                    onChanged: (v) => setState(() => food = double.tryParse(v) ?? food),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "交通費(円)",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                    controller: TextEditingController(text: transport.toStringAsFixed(0)),
                    onChanged: (v) => setState(() => transport = double.tryParse(v) ?? transport),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "キャンプ場(円)",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    ),
                    controller: TextEditingController(text: camp.toStringAsFixed(0)),
                    onChanged: (v) => setState(() => camp = double.tryParse(v) ?? camp),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text("メンバー設定",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // メンバー一覧
            ...List.generate(people, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: nameControllers[index],
                        decoration: InputDecoration(
                          hintText: "メンバー${index + 1}",
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        children: [
                          FilterChip(
                            label: const Text("食費免除"),
                            selected: foodExempt[index],
                            onSelected: (v) => setState(() => foodExempt[index] = v),
                          ),
                          FilterChip(
                            label: const Text("交通免除"),
                            selected: transportExempt[index],
                            onSelected: (v) => setState(() => transportExempt[index] = v),
                          ),
                          FilterChip(
                            label: const Text("キャンプ免除"),
                            selected: campExempt[index],
                            onSelected: (v) => setState(() => campExempt[index] = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: calculate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
              ),
              child: const Text("計算する"),
            ),

            const SizedBox(height: 12),
            _buildResultList(),
          ],
        ),
      ),
    );
  }
}