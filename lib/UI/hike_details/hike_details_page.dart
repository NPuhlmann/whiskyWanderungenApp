import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/hike.dart';
import 'hike_details_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HikeDetailsPage extends StatefulWidget {
  const HikeDetailsPage(
      {super.key, required this.hikeData, required this.viewModel});

  final Hike hikeData;
  final HikeDetailsPageViewModel viewModel;

  @override
  State<HikeDetailsPage> createState() => _HikeDetailsPageState();
}

class _HikeDetailsPageState extends State<HikeDetailsPage> {
  final PageController _pageController = PageController();

  // wenn das Widget erstellt wird, sollen die Bilder des Hikes geladen werden
  @override
  void initState() {
    super.initState();
    widget.viewModel.getHikeImages(widget.hikeData.id);
  }

  //wenn das Widget aktualisiert wird, sollen die Bilder des Hikes neu geladen werden
  @override
  void didUpdateWidget(covariant HikeDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.viewModel.getHikeImages(widget.hikeData.id);
  }

  // wenn das Widget entsorgt wird, sollen die Bilder des Hikes gelöscht werden
  @override
  void dispose() {
    widget.viewModel.hikeImages = [];
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
      body: SingleChildScrollView(
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
                          controller: _pageController,
                          itemCount: widget.viewModel.hikeImages.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                                widget.viewModel.hikeImages[index]);
                          },
                          onPageChanged: (index) {
                            if (index ==
                                widget.viewModel.hikeImages.length - 1) {
                              _pageController.jumpToPage(0);
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
                          onPressed: () => print("pressed"),
                          child: Text(
                            AppLocalizations.of(context)!.buyButtonText,
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
      ),
    );
  }
}
