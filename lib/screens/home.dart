import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'history.dart';

class SensorDataScreen extends StatefulWidget {
  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  String _selectedCity = 'kandy'; // Default city
  String _humidity = 'Loading...';
  String _temperature = 'Loading...';
  String _rainfall = 'Loading...';

  List<String> _cities = ['kandy', 'colombo', 'galle']; 

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  void _fetchSensorData() {
    final cityRef = _dbRef.child('Weather/$_selectedCity');

    cityRef.child('Humidity').onValue.listen((event) {
      setState(() {
        _humidity = event.snapshot.value.toString();
      });
    });

    cityRef.child('Temperature').onValue.listen((event) {
      setState(() {
        _temperature = event.snapshot.value.toString();
      });
    });

    cityRef.child('Rain').onValue.listen((event) {
      setState(() {
        _rainfall = event.snapshot.value.toString();
      });
    });
  }

  void _onCityChanged(String? newCity) {
    if (newCity != null) {
      setState(() {
        _selectedCity = newCity;
        _fetchSensorData(); // Fetch data for the newly selected city
      });
    }
  }

  Color _getTemperatureColor() {
    final temperature = double.tryParse(_temperature) ?? 0;
    return temperature > 30 ? Colors.red : Colors.blue;
  }

  Color _getRainfallColor() {
    final rainfall = double.tryParse(_rainfall) ?? 0;
    return rainfall < 500 ? Colors.red : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.wb_sunny,
            //     color: Colors.amberAccent, size: 30), // Weather-related icon
            SizedBox(width: 8),
            Text(
              'Weather Report',
              style: GoogleFonts.poppins(
                fontSize: 20,
                // fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.fromLTRB(15, 40, 15, 15),
          child: Column(
            children: [
              _buildCityDropdown(),
              SizedBox(height: 20),
              _buildSensorCard(
                value: '$_temperature°C',
                label: 'Temperature',
                icon: Icons.thermostat_outlined,
                color: _getTemperatureColor(),
              ),
              SizedBox(height: 10),
              _buildSensorCard(
                value: '$_humidity%',
                label: 'Humidity',
                icon: Icons.water_drop_outlined,
                color: Colors.blue, // No condition for humidity color
              ),
              SizedBox(height: 10),
              _buildSensorCard(
                value: '$_rainfall mm',
                label: 'Rain Fall',
                icon: Icons.grain_outlined,
                color: _getRainfallColor(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300, 60),
                    backgroundColor: Colors.yellow[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    )),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HistoryScreen(city: _selectedCity)),
                  );
                },
                child: Text(
                  "View History",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButton<String>(
          value: _selectedCity,
          onChanged: _onCityChanged,
          items: _cities.map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(
                city,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 10.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(
                icon,
                color: color,
                size: 50,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.montserrat(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
