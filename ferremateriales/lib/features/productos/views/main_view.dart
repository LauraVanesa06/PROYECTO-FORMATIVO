import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerImages = [
  'https://picsum.photos/400/200?random=1',
  'https://picsum.photos/400/200?random=2',
  'https://picsum.photos/400/200?random=3',
];


    final categories = [
      {'icon': Icons.construction, 'label': 'Herramientas'},
      {'icon': Icons.plumbing, 'label': 'Plomería'},
      {'icon': Icons.electrical_services, 'label': 'Electricidad'},
      {'icon': Icons.format_paint, 'label': 'Pintura'},
      {'icon': Icons.grass, 'label': 'Jardín'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ferretería')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carrusel de banners
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: bannerImages.map((url) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Carrusel horizontal de categorías/artículos
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Icon(item['icon'] as IconData, size: 30),
                        ),
                        const SizedBox(height: 10),
                        Text(item['label'] as String, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
