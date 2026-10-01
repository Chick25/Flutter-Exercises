import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// import 'catch.dart';
// import 'result_screen.dart';
// import 'result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 253, 252, 252)),
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
 

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time, 
  });
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

  final List<CalendarEvent> _events = [
    CalendarEvent(
      id: '1',
      title: 'Learn Flutter',
      date: DateTime.now(),
      time: '10:00 AM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    _focusedWeekStart = _today.subtract(Duration(days: _today.weekday - 1)); // Start of the week (Monday)
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

  List<CalendarEvent> get _eventsForSelectedDate{
    return _events.where((event){
      return event.date.year == _selectedDate.year &&
             event.date.month == _selectedDate.month &&
             event.date.day == _selectedDate.day;
    }).toList();
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm sự kiện'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                ),
              ),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Thời gian',
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState((){
                    _events.add(
                      CalendarEvent(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        date: _selectedDate,
                        time: timeController.text,
                      ),
                    );
                });
                // Add event logic here
                Navigator.pop(context);
              }
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
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        children: [
          // Your calendar UI elements here
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                IconButton(
                  onPressed: _goToPreviousWeek,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  'Tuần của ${DateFormat('dd/MM/yyyy').format(_focusedWeekStart)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  bool isSelected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;
                  bool isToday = day.year == _today.year && day.month == _today.month && day.day == _today.day;

                  List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = day;
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
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
              )
          ),
          Expanded(
            child: _eventsForSelectedDate.isEmpty ? const Center(child: Text('Không có sự kiện nào trong ngày này'),
            ) : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _eventsForSelectedDate.length,
              itemBuilder: (context, index) {
                final event = _eventsForSelectedDate[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('Thời gian: ${event.time}'),
                    ],
                  ),
                );
              },
            ),
          )

        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed:_showAddEventDialog,
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
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Danh sách',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      )  

    );
  }



}

