import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_detail_page.dart'; // Import the new page

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 icons per row
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.8, // Adjusted to allow more vertical space
          ),
          itemCount: 8, // 2 rows of 4 icons = 8 icons
          itemBuilder: (context, index) {
            return GestureDetector( // Wrap with GestureDetector to detect taps
              onTap: () {
                // Navigate to the MapDetailPage when an icon is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapDetailPage(
                      mapIndex: index + 1, // Pass the index as an integer
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF217055),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.map,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mapa #${index + 1}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
