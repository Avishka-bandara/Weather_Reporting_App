import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  final String city;

  HistoryScreen({required this.city});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, String>> _historyData = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    try {
      final cityRef = _dbRef.child('Weather/${widget.city}/DailyAverage');

      DatabaseEvent event = await cityRef.once();
      final Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      if (data.isEmpty) {
        setState(() {
          _error = 'No historical data available.';
          _historyData = [];
        });
      } else {
        //  Sort the data by date and take the last 5 entries
        final sortedData = data.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key)); // Sort descending by date

        final recentData = sortedData.take(5).map((entry) {
          return {
            "date": entry.key.toString(),
            "temperature": entry.value['AvgTemperature']?.toString() ?? 'N/A',
            "humidity": entry.value['AvgHumidity']?.toString() ?? 'N/A',
            "rainfall": entry.value['AvgRain']?.toString() ?? 'N/A',
          };
        }).toList();

        setState(() {
          _historyData = recentData;
          _error = '';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load data. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
                  ? Center(
                      child: Text(_error,
                          style: TextStyle(color: Colors.white, fontSize: 18)))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: _historyData
                                  .map((data) => _historyCard(
                                        temperature: data['temperature']!,
                                        humidity: data['humidity']!,
                                        rainfall: data['rainfall']!,
                                        date: data['date']!,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _historyCard({
    required String temperature,
    required String humidity,
    required String rainfall,
    required String date,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 10.0,
      margin: EdgeInsets.symmetric(vertical: 9.0),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          children: [
            Text(date,
                style: GoogleFonts.montserrat(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[600])),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Temperature  :-",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "Humidity        :-",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "Rain Fall         :-",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      temperature + '°C',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      humidity + '%',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      rainfall + "mm",
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
