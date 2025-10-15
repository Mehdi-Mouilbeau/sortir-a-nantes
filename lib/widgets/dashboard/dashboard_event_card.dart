import 'package:flutter/material.dart';

class DashboardEventCard extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const DashboardEventCard({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    final name = eventData['nom'] ?? '';
    final image = eventData['media_url'] ?? '';
    final date = eventData['date'] ?? '';

    return Card(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                image,
                height: 70,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 70,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              date.toString().substring(0, 10), // format YYYY-MM-DD
              style: TextStyle(color: Colors.grey[700], fontSize: 8),
              
            ),
          ),
        ],
      ),
    );
  }
}