import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerImages = [
      'assets/images/oferta.jpg',
      'assets/images/oferta2.png',
      'assets/images/oferta3.jpg',
    ];

    final categories = [
      {'icon': Icons.construction, 'label': 'Herramientas'},
      {'icon': Icons.plumbing, 'label': 'Plomería'},
      {'icon': Icons.flash_on, 'label': 'Electricidad'},
      {'icon': Icons.format_paint, 'label': 'Pintura'},
      {'icon': Icons.grass, 'label': 'Jardín'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de cabecera
              SizedBox(
                width: double.infinity,
                height: 100,
                child: Image.asset(
                  'assets/images/logo.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // Carrusel de imágenes locales
              CarouselSlider(
                options: CarouselOptions(
                  height: 140,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: bannerImages.map((path) {
                  return Builder(
                    builder: (BuildContext context) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          path,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Lista horizontal de categorías con efecto hover
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 24),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _HoverCategoryButton(
                      icon: category['icon'] as IconData,
                      label: category['label'] as String,
                      onTap: () {
                        print('Clic en: ${category['label']}');
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget personalizado con efecto hover
class _HoverCategoryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HoverCategoryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HoverCategoryButton> createState() => _HoverCategoryButtonState();
}

class _HoverCategoryButtonState extends State<_HoverCategoryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _isHovered ? Colors.brown.shade100 : Colors.grey.shade200,
              child: Icon(
                widget.icon,
                color: _isHovered ? Colors.brown.shade800 : Colors.brown,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                color: _isHovered ? Colors.brown.shade800 : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
