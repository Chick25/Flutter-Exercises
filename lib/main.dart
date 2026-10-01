import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// import 'catch.dart';
import 'result_screen.dart';
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
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            color: Colors.white,
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7, // Display 7 days
                itemBuilder: (context, index) {
                  DateTime day = DateTime.now().add(Duration(days: index));
                  bool isSelected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = day;
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('dd/MM').format(day),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Text(
                  'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '(${_eventsForSelectedDate.length} sự kiện)',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          Expanded(
            child: _eventsForSelectedDate.isEmpty ? const Center(child: Text('Không có sự kiện nào trong ngày này'),
            ) : ListView.builder(
              itemCount: _eventsForSelectedDate.length,
              itemBuilder: (context, index) {
                final event = _eventsForSelectedDate[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Text('Thời gian: ${event.time}'),
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
      )

    );
  }



}

