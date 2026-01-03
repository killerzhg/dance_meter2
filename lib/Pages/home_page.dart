import 'dart:async';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }}

class _HomePageState extends State<HomePage> {
  String buttonName = '开始计费';
  final List<int> minuteOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  //let表示这个变量会稍后被初始化，但在使用前一定会有值
  int? selectedMinute=4;

  final List<int> priceOptions = [20, 30, 40, 50];
  int? selectedPrice=20;

  // 1. 将计时器、分钟和秒提升为成员变量
  Timer? _timer; // 用于持有计时器对象，以便可以取消它
  int _minutes = 0; // 用于存储计时的分钟数
  int _seconds = 0; // 用于存储计时的秒数

  double _totalPrice = 0.0;

  //格式化时间显示
  String _formatDuration() {
    // String.padLeft(2, '0') 用于确保数字总是两位数，例如 01, 02...
    final String minutesStr = _minutes.toString().padLeft(2, '0');
    final String secondsStr = _seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  void dispose() {
    // 在 Widget 销毁时确保计时器也被取消，防止内存泄漏
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("永信茶吧跳舞计费器"), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 将 Text 组件与计时变量绑定
                Text(
                  _formatDuration(), // 使用格式化方法显示时间
                  style: const TextStyle(
                    fontSize: 48, // 放大字体让时间更清晰
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  '${_totalPrice.toStringAsFixed(2)} 元',
                  style: const TextStyle(
                    fontSize: 48, // 放大字体让时间更清晰
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("每首歌 "),
                    DropdownMenu<int>(
                      initialSelection: minuteOptions[3],
                      onSelected: (int? value) {
                        setState(() {
                          selectedMinute = value;
                        });
                      },
                      dropdownMenuEntries: minuteOptions
                          .map<DropdownMenuEntry<int>>((int value) {
                        return DropdownMenuEntry<int>(
                            value: value, label: value.toString());
                      }).toList(),
                      width: 100,
                    ),
                    const Text(" 分钟"),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("每首歌 "),
                    DropdownMenu(
                      initialSelection: priceOptions.first,
                      onSelected: (int? value) {
                        setState(() {
                          selectedPrice = value;
                        });
                      },
                      dropdownMenuEntries: priceOptions
                          .map<DropdownMenuEntry<int>>((int value) {
                        return DropdownMenuEntry<int>(
                            value: value, label: value.toString());
                      }).toList(),
                      width: 100,
                    ),
                    const Text(" 元    "),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // 安全检查：确保用户已经选择了价格和时间
                    if (selectedMinute == null || selectedPrice == null) {
                      // 可以弹出一个提示框告诉用户选择
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请先选择每首歌的时间和价格！')),
                      );
                      return; // 阻止计时开始
                    }

                    // 3. 更新按钮点击逻辑
                    if (buttonName == '开始计费') {
                      _totalPrice = 0;  // 重置总价格
                      _minutes = 0;     // 重置分钟
                      _seconds = 0;     // 重置秒
                      setState(() {
                        buttonName = '停止计费';
                      });

                      // 开始计时
                      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                        setState(() {
                          _seconds++;
                          if (_seconds == 60) {
                            _seconds = 0;
                            _minutes++;
                            _totalPrice += selectedPrice!/selectedMinute!;
                          }
                        });
                      });
                    } else {
                      setState(() {
                        buttonName = '开始计费';
                        // 4. 停止并重置计时器
                        _timer?.cancel(); // 停止计时器
                      });
                    }
                  },
                  child: Text(buttonName),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
