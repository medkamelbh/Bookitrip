import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

class TunisiaHistoryTimeline extends StatefulWidget {
  final dynamic theme;

  const TunisiaHistoryTimeline({super.key, required this.theme});

  @override
  State<TunisiaHistoryTimeline> createState() => _TunisiaHistoryTimelineState();
}

class _TunisiaHistoryTimelineState extends State<TunisiaHistoryTimeline> {
  int _selectedEraIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, dynamic>> _eras = [
    {
      "year": "814 AEC.",
      "title": "Les secrets de Didon",
      "desc":
      "Fondatrice de Carthage, Didon transforme un rivage désert en empire maritime prospère. Les navires partent à l’aventure sur toute la Méditerranée.",
      "image": "assets/images/punic_column.jpg",
      "icon": Icons.sailing,
      "audio": "assets/sounds/punic.mp3",
      "funFact":
      "Saviez-vous que Carthage pouvait envoyer 500 navires en Méditerranée ?"
    },
    {
      "year": "146 AEC.",
      "title": "Les géants de marbre",
      "desc":
      "Carthage renaît de ses cendres sous Rome. Les thermes flamboyants, les amphithéâtres et mosaïques racontent le quotidien des Romains.",
      "image": "assets/images/roman_ruins.jpg",
      "icon": Icons.account_balance,
      "audio": "assets/sounds/roman.mp3",
      "funFact": "Certaines mosaïques romaines de Tunisie datent de plus de 2000 ans."
    },
    {
      "year": "698",
      "title": "Les flèches de la foi",
      "desc":
      "L’arrivée des Arabes fait fleurir la médina de Tunis. La Grande Mosquée de Zitouna devient le cœur intellectuel et spirituel.",
      "image": "assets/images/islamic_arch.jpg",
      "icon": Icons.mosque,
      "audio": "assets/sounds/islamic.mp3",
      "funFact":
      "La mosquée de Zitouna a été un centre d’enseignement pendant plus de mille ans."
    },
    {
      "year": "1881",
      "title": "La Tunisie moderne",
      "desc":
      "Architecture coloniale française fusionnée avec le patrimoine tunisien : un pays entre tradition et modernité.",
      "image": "assets/images/modern_tunis.jpg",
      "icon": Icons.apartment,
      "audio": "assets/sounds/modern.mp3",
      "funFact":
      "De nombreuses avenues de Tunis gardent encore le style architectural français."
    },
    {
      "year": "1956",
      "title": "Indépendance et renouveau",
      "desc":
      "Naissance de la République tunisienne, modernisation et affirmation de l’identité nationale.",
      "image": "assets/images/independence.jpg",
      "icon": Icons.flag,
      "audio": "assets/sounds/independence.mp3",
      "funFact": "La Tunisie est devenue une république le 20 mars 1956."
    },
  ];

  void _playAudio(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
          AssetSource(assetPath.replaceFirst("assets/", "")));
    } catch (e) {
      debugPrint("Erreur audio : $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "cultures.tunisia_chronicles".tr(),
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: theme.text,
            ),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 1 ),
            itemCount: _eras.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedEraIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedEraIndex = index);
                  _playAudio(_eras[index]["audio"]);
                },
                child: Container(
                  width: 85,
                  margin: const EdgeInsets.only(right: 0),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: isSelected ? 50 : 35,
                        width: isSelected ? 50 : 35,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primary
                              : Colors.grey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                                color: theme.primary.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]
                              : [],
                        ),
                        child: Icon(
                          _eras[index]["icon"],
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: isSelected ? 26 : 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _eras[index]["year"],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.primary : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Container(
            key: ValueKey<int>(_selectedEraIndex),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.CardBG,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    _eras[_selectedEraIndex]["image"],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 15),

                // Titre
                Text(
                  _eras[_selectedEraIndex]["title"].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  _eras[_selectedEraIndex]["desc"],
                  style: GoogleFonts.poppins(
                    color: theme.text,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Fun Fact
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "💡 ${_eras[_selectedEraIndex]["funFact"]}",
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
