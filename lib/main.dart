import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:path/path.dart' hide context;
// import 'package:project1/nhapDSSV.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'cong2so.dart';

class HiveHelper {
  static final String _boxName = 'calendar_events';
  static Box get _box => Hive.box(_boxName);

  static Future<void> addEvent(Map<String, dynamic> event) async {
    final String id = event['id'];
    await _box.put(id, event); 
  }

  static List<Map<String, dynamic>> queryAllEvents() {
    final rawValues = _box.values.toList();
    return rawValues.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('calendar_events');

  await initializeDateFormatting('vi_VN', null);
  runApp(const LichCaNhanApp());
}

class LichCaNhanApp extends StatelessWidget {
  const LichCaNhanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMPLE CALENDAR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 253, 252, 252),
        ),
        useMaterial3: true,
      ),
      home: const CalendarScreen(),
    );
  }
}

// ============== MODELS ==============

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String status;
  final String reviewNote;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    this.status = 'pending',
    this.reviewNote = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      'reviewNote': reviewNote,
    };
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      status: map['status'] ?? 'pending',
      reviewNote: map['reviewNote'] ?? '',
    );
  }
}

// ============== MAIN SCREEN (MOBILE) ==============

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DateTime _today = DateTime.now();

  late DateTime _selectedDate;

  late DateTime _focusedWeekStart;

  final List<CalendarEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    _focusedWeekStart = _today.subtract(
      Duration(days: _today.weekday - 1),
    ); // Start of the week (Monday)
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final datalist = await HiveHelper.queryAllEvents();
    setState(() {
      _events.clear();
      _events.addAll(
        datalist.map((data) => CalendarEvent.fromMap(data)).toList(),
      );
    });
  }

  Future<void> _addEventtoDatabase(String title, String time) async {
    final newEvent = CalendarEvent(
      id: DateTime.now().toString(),
      title: title,
      date: _selectedDate,
      time: time,
    );

    await HiveHelper.addEvent(newEvent.toMap());
    await _loadEvents();
  }

  Future<void> _showReviewDialog(CalendarEvent event) async{
    final noteController = TextEditingController(text: event.reviewNote);
    String selectedStatus = event.status;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Đánh giá sự kiện'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Chưa hoàn thành')),
                    DropdownMenuItem(value: 'completed', child: Text('Hoàn thành')),
                    DropdownMenuItem(value: 'partially_completed', child: Text('Một phần hoàn thành')),
                    DropdownMenuItem(value: 'notCompleted', child: Text('Chưa hoàn thành')),
                  ],
                  onChanged: (value) {
                    if (value != null){
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  }
                ),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Ghi chú', hintText: 'Ví dụ: Hoàn thành phần chính, còn thiếu...'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedEvent = CalendarEvent(
                    id: event.id,
                    title: event.title,
                    date: event.date,
                    time: event.time,
                    status: selectedStatus,
                    reviewNote: noteController.text,
                  );

                  await HiveHelper.addEvent(updatedEvent.toMap());
                  await _loadEvents();
                  Navigator.pop(dialogContext);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }


  void _goToPreviousWeek() {
    setState(() {
      _focusedWeekStart = _focusedWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _focusedWeekStart = _focusedWeekStart.add(const Duration(days: 7));
    });
  }

  List<CalendarEvent> get _eventsForSelectedDate {
    return _events.where((event) {
      return event.date.year == _selectedDate.year &&
          event.date.month == _selectedDate.month &&
          event.date.day == _selectedDate.day;
    }).toList();
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chưa hoàn thành';
      case 'completed':
        return 'Hoàn thành';
      case 'partially_completed':
        return 'Một phần hoàn thành';
      case 'notCompleted':
        return 'Chưa hoàn thành';
      default:
        return '';
    }
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Thêm sự kiện'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              TextField(
                controller: timeController,
                readOnly: true,
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.now()
                  );
                  if (pickedTime != null) {
                    timeController.text = 
                      '${pickedTime.hour.toString().padLeft(2, '0')}:'
                      '${pickedTime.minute.toString().padLeft(2, '0')}';
                  }
              },
                decoration: const InputDecoration(labelText: 'Thời gian', suffixIcon: Icon(Icons.access_time)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await _addEventtoDatabase(titleController.text, timeController.text);
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar')),
      body: Column(
        children: [
          // Your calendar UI elements here
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _goToPreviousWeek,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  'Tuần của ${DateFormat('dd/MM/yyyy').format(_focusedWeekStart)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _goToNextWeek,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7, // Display 7 days
              itemBuilder: (context, index) {
                DateTime day = _focusedWeekStart.add(Duration(days: index));
                bool isSelected =
                    day.year == _selectedDate.year &&
                    day.month == _selectedDate.month &&
                    day.day == _selectedDate.day;
                bool isToday =
                    day.year == _today.year &&
                    day.month == _today.month &&
                    day.day == _today.day;

                List<String> weekDays = [
                  'T2',
                  'T3',
                  'T4',
                  'T5',
                  'T6',
                  'T7',
                  'CN',
                ];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekDays[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        if (isToday)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _eventsForSelectedDate.isEmpty
                ? const Center(
                    child: Text('Không có sự kiện nào trong ngày này'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _eventsForSelectedDate.length,
                    itemBuilder: (context, index) {
                      final event = _eventsForSelectedDate[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8.0),
                          border: const Border(
                            left: BorderSide(color: Colors.blue, width: 4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Thời gian: ${event.time}'),
                            Text('Trạng thái: ${_statusLabel(event.status)}'),
                              if (event.reviewNote.isNotEmpty)
                                Text('Ghi chú: ${event.reviewNote}'),
                              TextButton.icon(
                                onPressed: () => _showReviewDialog(event),
                                icon: const Icon(Icons.rate_review),
                                label: const Text('Đánh giá'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch',
          ),
          NavigationDestination(icon: Icon(Icons.list), label: 'Danh sách'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
