import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/visited_service.dart';
import '../services/places_api_service.dart';
import '../models/place.dart';

class VisitsScreen extends StatelessWidget {
  const VisitsScreen({super.key});

  static const primaryBlue = Color(0xFF0D4F8B);

  // Foto URL
  String? _photoUrl(PlacesApiService api, Place p, {int maxWidth = 500}) {
    if (p.photoRef == null || p.photoRef!.isEmpty) return null;
    return api.placePhotoUrl(photoRef: p.photoRef!, maxWidth: maxWidth);
  }

  // Mood list
  static const moods = [
    'Happy',
    'Energetic',
    'Relaxed',
    'Romantic',
    'Adventurous',
    'Curious',
  ];

  void _openSurvey(BuildContext context, Place place) {
    final visited = context.read<VisitedService>();
    final existing = visited.surveyOf(place.id);

    String selectedMood = existing?.selectedMood ?? 'Curious';
    Map<String, double> felt = Map<String, double>.from(
      existing?.feltScores ??
          {
            for (final m in moods) m: 0.0,
          },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: primaryBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Quick Survey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Times New Roman',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Q1
                    const Text(
                      'Which mood did you pick when you chose this place?',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Times New Roman',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMood,
                          isExpanded: true,
                          items: moods
                              .map(
                                (m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                m,
                                style: const TextStyle(
                                  fontFamily: 'Times New Roman',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setModal(() => selectedMood = v);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Q2
                    const Text(
                      'How much did this place make you feel these moods? (0–10)',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Times New Roman',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...moods.map((m) {
                      final v = felt[m] ?? 0.0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$m: ${v.toStringAsFixed(0)}/10',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Times New Roman',
                              fontSize: 13,
                            ),
                          ),
                          Slider(
                            value: v,
                            min: 0,
                            max: 10,
                            divisions: 10,
                            onChanged: (newV) {
                              setModal(() => felt[m] = newV);
                            },
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4EEDF),
                        foregroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        visited.setSurvey(
                          place.id,
                          VisitSurvey(
                            selectedMood: selectedMood,
                            feltScores: felt,
                          ),
                        );
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Survey saved for: ${place.name}'),
                          ),
                        );
                      },
                      child: const Text(
                        'Save Survey',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visited = context.watch<VisitedService>().visited;
    final visitedSvc = context.watch<VisitedService>();

    final api = PlacesApiService('AIzaSyCRWOtfsyFdobFs6h79dXyBhYb4fhoC8hc');

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Visits",
          style: TextStyle(
            fontFamily: 'Times New Roman',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: visited.isEmpty
          ? const Center(
        child: Text(
          "No visited places yet.",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Times New Roman',
            fontSize: 14,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: visited.length,
        itemBuilder: (context, i) {
          final p = visited[i];
          final imgUrl = _photoUrl(api, p);
          final survey = visitedSvc.surveyOf(p.id);

          final google = p.googleRating?.toStringAsFixed(1) ?? '-';
          final distKm = p.distanceKm.toStringAsFixed(1);

          return GestureDetector(
            onTap: () => _openSurvey(context, p),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 78,
                      height: 78,
                      child: imgUrl == null
                          ? Container(
                        color: Colors.black12,
                        child: const Icon(Icons.photo,
                            color: Colors.black45),
                      )
                          : Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black12,
                          child: const Icon(Icons.broken_image,
                              color: Colors.black45),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.address ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Google: $google/5  •  $distKm km',
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (survey != null)
                          Text(
                            'Survey saved ✓ (picked: ${survey.selectedMood})',
                            style: const TextStyle(
                              fontFamily: 'Times New Roman',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          )
                        else
                          const Text(
                            'Tap to answer the survey',
                            style: TextStyle(
                              fontFamily: 'Times New Roman',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ),

                  IconButton(
                    tooltip: 'Remove from visits',
                    onPressed: () {
                      context.read<VisitedService>().removeVisited(p.id);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
