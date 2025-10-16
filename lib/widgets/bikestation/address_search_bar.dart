import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sortir_a_nantes/services/geocoding_service.dart';

class AddressSearchBar extends StatefulWidget {
  final void Function(LatLng coords, String label) onAddressSelected;

  const AddressSearchBar({super.key, required this.onAddressSelected});

  @override
  State<AddressSearchBar> createState() => _AddressSearchBarState();
}

class _AddressSearchBarState extends State<AddressSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _suggestions = [];

  Future<void> _onQueryChanged(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);
    final results = await GeocodingService.fetchSuggestions(query);
    setState(() {
      _suggestions = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Entrez une adresse",
              border: const OutlineInputBorder(),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
            ),
            onChanged: _onQueryChanged,
            onSubmitted: (value) async {
              final coords = await GeocodingService.geocodeAddress(value);
              if (coords != null) widget.onAddressSelected(coords, value);
            },
          ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: ListView.separated(
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.place, color: Colors.orange),
                    title: Text(
                      suggestion["display_name"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      final coords = LatLng(suggestion["lat"], suggestion["lon"]);
                      widget.onAddressSelected(coords, suggestion["display_name"]);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
