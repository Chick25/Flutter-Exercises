import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      home: NhapDanhSach(),
    );
  }
}

class NhapDanhSach extends StatefulWidget {
  const NhapDanhSach({super.key});

  @override
  State<NhapDanhSach> createState() => _NhapDanhSachState();
}

class _NhapDanhSachState extends State<NhapDanhSach> {
  final _controller = TextEditingController();

  final List<String> _danhsachSV = [];

  String _keyWord = '';

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final result = _danhsachSV
        .where((thongtin) => thongtin.contains(_keyWord))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nhập danh sách SV',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Xử lý khi nhấn nút
                  final value = _controller.text.trim();
                  if (value.isNotEmpty) {
                    setState(() {
                      _danhsachSV.add(value);
                      _controller.clear();
                    });
                  }
                },
                child: const Text('Thêm'),
              ),

              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Tìm kiếm',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // setState(() {
                  _keyWord = value.trim();
                  // });
                },
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _keyWord = _searchController.text.trim();
                  });
                },
                child: const Text('Tìm kiếm'),
              ),

              // final result = _danhsachSV.where((thongtin) => thongtin.contains(_keyWord)).toList();
              Expanded(
                child: ListView.builder(
                  itemCount: result.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(result[index]));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
