import 'package:flutter/material.dart';
// import 'dart.math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Add2number(),
    );
  }
}

class Add2number extends StatefulWidget {
  const Add2number({super.key});

  @override
  State<Add2number> createState() => _Add2numberState();
}

class _Add2numberState extends State<Add2number> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  int _sum = 0;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 238, 238),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            vertical: 8.0,
            horizontal: 12.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _numberInput(_a, 'Số thứ nhất'),
                  const SizedBox(width: 16),
                  _numberInput(_b, 'Số thứ hai'),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '$_sum',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final a = int.tryParse(_a.text);
                  final b = int.tryParse(_b.text);
                  if (a == null || b == null) {
                    return;
                  }
                  setState(() {_sum = a + b;
                  });
                },
                child: const Text('Tính tổng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberInput(TextEditingController controller, String label) {
    return SizedBox(
      width: 120,
      height: 120,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }
}