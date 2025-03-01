import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/hike.dart';
import 'hike_details_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HikeDetailsPage extends StatefulWidget {
  const HikeDetailsPage(
      {super.key, required this.hikeData, required this.viewModel, this.isFromMyHikes = false});

  final Hike hikeData;
  final HikeDetailsPageViewModel viewModel;
  final bool isFromMyHikes;

  @override
  State<HikeDetailsPage> createState() => _HikeDetailsPageState();
}

class _HikeDetailsPageState extends State<HikeDetailsPage> {
  final PageController _pageController = PageController();

  // wenn das Widget erstellt wird, sollen die Bilder des Hikes geladen werden
  @override
  void initState() {
    super.initState();
    // Zuerst die Bilder leeren, um ein sauberes UI zu haben
    widget.viewModel.clearImagesForUI();
    // Dann die Bilder für die aktuelle Hike-ID laden
    widget.viewModel.getHikeImages(widget.hikeData.id);
  }

  //wenn das Widget aktualisiert wird, sollen die Bilder des Hikes nur neu geladen werden, wenn sich die Hike-ID geändert hat
  @override
  void didUpdateWidget(covariant HikeDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hikeData.id != widget.hikeData.id) {
      // Bilder nur neu laden, wenn sich die Hike-ID geändert hat
      
      // Zuerst den PageController zurücksetzen
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      
      // Dann die Bilder leeren und neu laden
      setState(() {
        // Leere die Bilder im UI, um ein Flackern zu vermeiden
        widget.viewModel.clearImagesForUI();
      });
      
      // Bilder für die neue Hike-ID laden
      widget.viewModel.getHikeImages(widget.hikeData.id);
    }
  }

  // wenn das Widget entsorgt wird, sollen die Bilder des Hikes gelöscht werden
  @override
  void dispose() {
    // Wir setzen die Bilder nicht mehr direkt zurück, um Probleme zu vermeiden
    // widget.viewModel.hikeImages = [];
    _pageController.dispose();
    super.dispose();
  }

  String getDifficultyString(BuildContext context, Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return AppLocalizations.of(context)!.easy;
      case Difficulty.mid:
        return AppLocalizations.of(context)!.middle;
      case Difficulty.hard:
        return AppLocalizations.of(context)!.hard;
      case Difficulty.very_hard:
        return AppLocalizations.of(context)!.very_hard;
      default:
        return AppLocalizations.of(context)!.middle;
    }
  }

  @override
  Widget build(BuildContext context) {
    // das Widget soll einen Scaffold zeigen mit dem Namen des Hikes im Titel
    // Dann soll ca. 1/3 des Bildschirms mit einem Bild des Hikes gefüllt werden
    // das Bild soll ein Karrousel sein, das durch die Bilder des Hikes scrollt
    // darunter soll eine Liste von Textfeldern sein, die die Details des Hikes zeigen
    // die Textfelder sollen die folgenden Informationen zeigen:
    // - Name des Hikes
    // - Schwierigkeitsgrad des Hikes
    // - Länge des Hikes
    // - Höhenmeter des Hikes
    // - Beschreibung des Hikes

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hikeData.name),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // hier sollen die Bilder des Hikes angezeigt werden, sie sollen wischbar sein um mehrere anzeigen zu können wir in einem Carousel
                // die Bilder sollen aus dem ViewModel geholt werden
                // wenn keine Bilder vorhanden sind, soll ein Ladecircle angezeigt werden
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: widget.viewModel.hikeImages.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            PageView.builder(
                              key: ValueKey('pageview_${widget.hikeData.id}'),
                              controller: _pageController,
                              itemCount: widget.viewModel.hikeImages.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  widget.viewModel.hikeImages[index],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(Icons.error, color: Colors.red, size: 48),
                                    );
                                  },
                                );
                              },
                              onPageChanged: (index) {
                                // Nur wenn wir am Ende angekommen sind und es mehr als ein Bild gibt
                                if (index == widget.viewModel.hikeImages.length - 1 && 
                                    widget.viewModel.hikeImages.length > 1) {
                                  // Verzögert zum ersten Bild zurückspringen, um Animation zu vermeiden
                                  Future.delayed(Duration(seconds: 2), () {
                                    if (mounted && _pageController.hasClients) {
                                      _pageController.animateToPage(
                                        0,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  });
                                }
                              },
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: IconButton(
                                icon:
                                    Icon(Icons.arrow_back_ios, color: Colors.white),
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 30,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2.0,
                                        color: Colors.black,
                                        offset: Offset(0, 0),
                                      )
                                    ]),
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
                // hier sollen die Details des Hikes angezeigt werden
                // die Details sollen aus dem Hike Objekt geholt werden
                // zuerst soll in fett der Name und die Infos wie Länge und Höhenmeter angezeigt werden
                // darunter soll die Beschreibung des Hikes angezeigt werden
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.hikeData.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Center(
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.terrain), // Icon für Schwierigkeit
                                  SizedBox(width: 2),
                                  Text(
                                      getDifficultyString(
                                          context, widget.hikeData.difficulty),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.straighten), // Icon für Länge
                                  SizedBox(width: 2),
                                  Text('${widget.hikeData.length}km',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.keyboard_arrow_up_rounded),
                                  // Icon für Höhenmeter
                                  SizedBox(width: 2),
                                  Text('${widget.hikeData.elevation}m',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Row(children: [
                              Icon(Icons.euro_rounded),
                              SizedBox(width: 2),
                              Text(widget.hikeData.price.toString(),
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold))
                            ]))
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.hikeData.description),
                      const SizedBox(height: 20),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (widget.isFromMyHikes) {
                                  // Hier die Logik zum Starten der Wanderung
                                  print("Wanderung starten");
                                  // TODO: Implementiere die Logik zum Starten der Wanderung
                                  // z.B. Navigation zu einer Karte oder einem Tracker
                                } else {
                                  // Hier die Logik zum Kaufen der Wanderung
                                  print("Wanderung kaufen");
                                  // TODO: Implementiere die Logik zum Kaufen der Wanderung
                                  // z.B. Navigation zu einer Zahlungsseite
                                }
                              },
                              child: Text(
                                widget.isFromMyHikes 
                                  ? AppLocalizations.of(context)!.startHikeButtonText 
                                  : AppLocalizations.of(context)!.buyButtonText,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
