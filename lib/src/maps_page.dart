import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/localization_service.dart';
import 'pages/map_detail_page.dart'; // Import the correct map detail page

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    print('DEBUG: MapsPage build with language: ${localization.currentLanguage}');

    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: const Color(0xFFA8D5BA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFFA8D5BA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFeafaf1),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/Chaac-light 1.png',
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      localization.translate('maps'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.85,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      print('DEBUG: Map icon #${index + 1} tapped');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapDetailPage(
                            mapIndex: index + 1,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: const Color(0xFF217055),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              width: 54,
                              height: 54,
                              child: const Icon(
                                Icons.map,
                                color: Color(0xFF217055),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              localization.translate('map_item_title_${index + 1}'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white, 
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text(
                                localization.translate('mayan_region_tag'),
                                style: const TextStyle(
                                  color: Color(0xFF217055),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

