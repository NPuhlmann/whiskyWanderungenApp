import 'package:flutter/material.dart';
import '../../../domain/models/waypoint.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WaypointDetailSheet extends StatefulWidget {
  const WaypointDetailSheet({
    Key? key,
    required this.waypoint,
    required this.onClose,
  }) : super(key: key);

  final Waypoint waypoint;
  final VoidCallback onClose;

  @override
  State<WaypointDetailSheet> createState() => _WaypointDetailSheetState();
}

class _WaypointDetailSheetState extends State<WaypointDetailSheet> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Nach unten wischen
          widget.onClose();
        } else if (details.primaryVelocity! < 0) {
          // Nach oben wischen
          setState(() {
            _isExpanded = true;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isExpanded
            ? MediaQuery.of(context).size.height * 0.9
            : MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Ziehleiste
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Schließen-Button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ),
            // Inhalt
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titel
                      Text(
                        widget.waypoint.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      // Bilder
                      if (widget.waypoint.images.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            itemCount: widget.waypoint.images.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.waypoint.images[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) {
                                      print('Fehler beim Laden des Bildes: $error');
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error, color: Colors.red, size: 48),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Bild konnte nicht geladen werden',
                                              style: TextStyle(color: Colors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    // Verbesserte Caching-Strategie
                                    memCacheWidth: MediaQuery.of(context).size.width.toInt(),
                                    maxHeightDiskCache: 1000,
                                    maxWidthDiskCache: 1000,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Beschreibung
                      Text(
                        widget.waypoint.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      // Koordinaten
                      Text(
                        'Koordinaten: ${widget.waypoint.latitude.toStringAsFixed(6)}, ${widget.waypoint.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 