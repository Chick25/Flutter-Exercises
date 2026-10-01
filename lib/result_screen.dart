import 'package:flutter/material.dart';
import '2manhinh.dart'; // Import đúng tên file màn hình nhập điểm ở trên

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Các biến lưu trạng thái (lúc đầu chưa nhập điểm nên để trống/null)
  double? _score;
  String _resultText = '';
  Color? _boxColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Màn hình đánh giá')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị số điểm vừa nhập (nếu chưa nhập thì hiện thông báo)
            Text(
              _score != null ? 'Số bạn vừa nhập: $_score' : 'Chưa có điểm đánh giá',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),

            // 1. Ô chữ nhật (Lúc đầu chưa có màu thì là màu trắng, có viền đen)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _boxColor ?? Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),

            const SizedBox(height: 30),

            // 2. Chữ kết quả ("Yếu", "Khá", "Tốt")
            Text(
              _resultText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _boxColor ?? Colors.black,
              ),
            ),

            const SizedBox(height: 50),

            // 3. Nút bấm để chuyển sang màn hình nhập điểm
            ElevatedButton(
              onPressed: () async {
                // Chuyển sang màn hình nhập điểm và CHỜ nhận dữ liệu trả về
                final int? returnedScore = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InputScreen(),
                  ),
                );

                // Khi màn hình nhập điểm pop về và có dữ liệu trả về
                if (returnedScore != null) {
                  setState(() {
                    _score = returnedScore.toDouble();

                    // Xử lý logic màu sắc và chữ theo đúng yêu cầu:
                    // Dưới 4: Yếu (Đỏ)
                    // Từ 6.5 đến 8: Khá (Vàng)
                    // Trên 8: Tốt (Xanh)
                    if (_score! < 5) {
                      _resultText = 'Yếu';
                      _boxColor = Colors.red;
                    } else if (_score! >= 5 && _score! <= 8) {
                      _resultText = 'Khá';
                      _boxColor = Colors.yellow;
                    } else {
                      _resultText = 'Tốt';
                      _boxColor = Colors.green;
                    }
                  });
                }
              },
              child: const Text('Nhập điểm'),
            ),
          ],
        ),
      ),
    );
  }
}