import 'dart:math';
import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;
  final Random _random = Random();

  // Vị trí và kích thước hiện tại của hình
  double _left = 0;
  double _top = 0;
  double _width = 200;
  double _height = 80;

  // Màu sắc và hình dạng
  Color _color = Colors.blue;
  BorderRadius _borderRadius = BorderRadius.circular(12);
  bool _initialized = false;

  void _onTap(Size screenSize) {
    setState(() {
      _counter++;

      // 1. Random kích thước mới
      _width = 100 + _random.nextDouble() * 150;
      _height = 80 + _random.nextDouble() * 120;

      // 2. Random vị trí mới (đảm bảo không tràn khỏi màn hình)
      _left = _random.nextDouble() * max(0, screenSize.width - _width);
      _top = _random.nextDouble() * max(0, screenSize.height - _height);

      // 3. Random màu sắc
      _color = Color.fromRGBO(
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
        1,
      );

      // 4. Random hình dạng: 50% bo góc, 50% thành hình tròn/elip
      _borderRadius = _random.nextBool()
          ? BorderRadius.circular(12 + _random.nextDouble() * 20)
          : BorderRadius.circular(min(_width, _height) / 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bắt tôi đi! 🎯'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          // Đặt vị trí ban đầu ở giữa màn hình (chỉ 1 lần)
          if (!_initialized) {
            _left = (size.width - _width) / 2;
            _top = (size.height - _height) / 2 - 50;
            _initialized = true;
          }

          return Stack(
            children: [
              // Hiệu ứng di chuyển mượt mà
              AnimatedPositioned(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutBack, // chạy hơi vượt đích rồi lùi lại, sinh động
                left: _left,
                top: _top,
                child: GestureDetector(
                  onTap: () => _onTap(size),
                  // Hiệu ứng biến đổi hình dạng + đổi màu
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: _width,
                    height: _height,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: _borderRadius,
                      // Đổ bóng theo màu để nổi bật
                      boxShadow: [
                        BoxShadow(
                          color: _color.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_counter',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}