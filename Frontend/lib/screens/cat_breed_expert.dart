import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Correct import


class CatBreedInformation extends StatefulWidget {
  const CatBreedInformation({super.key});

  @override
  State<CatBreedInformation> createState() => _CatBreedInformationState();
}

class _CatBreedInformationState extends State<CatBreedInformation> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  

  final gemini = GenerativeModel(
    apiKey: dotenv.get('GEMINI-API'),
    model: 'models/gemini-2.5-flash',
  );

  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': userMessage,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
      _controller.clear();
    });

    _focusNode.unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    final systemPrompt =
        '''
Return a JSON object ONLY (no extra text) describing the requested cat breed. The JSON must include these keys (use empty string if data not available):
{
  "name",
  "origin",
  "size",
  "weight",
  "height",
  "lifespan",
  "temperament",
  "grooming_needs",
  "shedding_level",
  "energy_level",
  "intelligence",
  "affection_level",
  "vocalization",
  "health_issues",
  "coat_type",
  "coat_pattern",
  "description"
}
Now provide the JSON for the user's request below.
User request: "$userMessage"
''';

    try {
      final response = await gemini.generateContent([
        Content.text(systemPrompt),
      ]);
      final text = response.text ?? '';

      Map<String, dynamic>? parsed;
      try {
        parsed = json.decode(text) as Map<String, dynamic>;
      } catch (_) {
        final start = text.indexOf('{');
        final end = text.lastIndexOf('}');
        if (start != -1 && end != -1 && end > start) {
          final candidate = text.substring(start, end + 1);
          try {
            parsed = json.decode(candidate) as Map<String, dynamic>;
          } catch (_) {
            parsed = null;
          }
        }
      }

      setState(() {
        if (parsed != null) {
          _messages.add({
            'role': 'ai',
            'data': parsed,
            'timestamp': DateTime.now(),
          });
        } else {
          _messages.add({
            'role': 'ai',
            'text': text.isNotEmpty ? text : 'No response',
            'timestamp': DateTime.now(),
          });
        }
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'text': 'Error: ${e.toString()}',
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }
  }

  Widget _buildStructuredCard(Map<String, dynamic> data) {
    final primaryColor = const Color(0xFFFD9340);
    final backgroundColor = Colors.white;
    final textColor = const Color(0xFF2C3E50);
    final subtitleColor = const Color(0xFF7F8C8D);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with cat name
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.catching_pokemon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data['name']?.toString().toUpperCase() ?? 'UNKNOWN CAT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Basic Information
              Text(
                'BASIC INFORMATION',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),

              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 350 ? 2 : 1;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3.5,
                    children: [
                      _buildFactTile(
                        'Origin',
                        data['origin'],
                        Icons.public,
                        primaryColor,
                      ),
                      _buildFactTile(
                        'Size',
                        data['size'],
                        Icons.aspect_ratio,
                        primaryColor,
                      ),
                      _buildFactTile(
                        'Coat Type',
                        data['coat_type'],
                        Icons.texture,
                        primaryColor,
                      ),
                      _buildFactTile(
                        'Coat Pattern',
                        data['coat_pattern'],
                        Icons.pattern,
                        primaryColor,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Physical Characteristics
              Text(
                'PHYSICAL CHARACTERISTICS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Weight',
                      data['weight'],
                      Icons.fitness_center,
                      primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      'Height',
                      data['height'],
                      Icons.height,
                      primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Lifespan
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.timelapse,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIFESPAN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['lifespan'] ?? '—',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Personality & Traits
              Text(
                'PERSONALITY & TRAITS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),

              // Rating Grid for personality traits
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 400 ? 2 : 1;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 4,
                    children: [
                      _buildRatingBar(
                        'Energy Level',
                        data['energy_level'],
                        Icons.bolt,
                        primaryColor,
                      ),
                      _buildRatingBar(
                        'Affection Level',
                        data['affection_level'],
                        Icons.favorite,
                        primaryColor,
                      ),
                      _buildRatingBar(
                        'Intelligence',
                        data['intelligence'],
                        Icons.psychology,
                        primaryColor,
                      ),
                      _buildRatingBar(
                        'Vocalization',
                        data['vocalization'],
                        Icons.mic,
                        primaryColor,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Care & Maintenance
              Text(
                'CARE & MAINTENANCE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),

              Column(
                children: [
                  _buildInfoSection(
                    'Temperament',
                    data['temperament'],
                    Icons.emoji_emotions,
                    primaryColor,
                  ),
                  _buildInfoSection(
                    'Grooming Needs',
                    data['grooming_needs'],
                    Icons.clean_hands,
                    primaryColor,
                  ),
                  _buildInfoSection(
                    'Shedding Level',
                    data['shedding_level'],
                    Icons.brush,
                    primaryColor,
                  ),
                  _buildInfoSection(
                    'Health Issues',
                    data['health_issues'],
                    Icons.health_and_safety,
                    primaryColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: primaryColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['description'] ?? 'No description available',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFactTile(
    String label,
    dynamic value,
    IconData icon,
    Color primaryColor,
  ) {
    final val = (value == null || (value is String && value.isEmpty))
        ? '—'
        : value.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7F8C8D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    val,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    dynamic value,
    IconData icon,
    Color primaryColor,
  ) {
    final val = (value == null || (value is String && value.isEmpty))
        ? '—'
        : value.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              val,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(
    String label,
    dynamic value,
    IconData icon,
    Color primaryColor,
  ) {
    String ratingText = '—';
    int ratingStars = 0;

    if (value != null && value is String && value.isNotEmpty) {
      // Try to parse rating from text (e.g., "High" = 5 stars, "Medium" = 3 stars)
      final lowerValue = value.toLowerCase();
      if (lowerValue.contains('high') || lowerValue.contains('very')) {
        ratingStars = 5;
        ratingText = 'High';
      } else if (lowerValue.contains('medium') ||
          lowerValue.contains('moderate')) {
        ratingStars = 3;
        ratingText = 'Medium';
      } else if (lowerValue.contains('low')) {
        ratingStars = 1;
        ratingText = 'Low';
      } else {
        ratingText = value;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 14,
                        color: index < ratingStars
                            ? primaryColor
                            : Colors.grey.shade300,
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ratingText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    String label,
    dynamic value,
    IconData icon,
    Color primaryColor,
  ) {
    final val = (value == null || (value is String && value.isEmpty))
        ? 'Not specified'
        : value.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: primaryColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    val,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F8C8D),
                      height: 1.4,
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

  Widget _buildMessageBubble(Map<String, dynamic> msg, BuildContext context) {
    final isUser = msg['role'] == 'user';
    final primaryColor = const Color(0xFFFD9340);

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: isUser ? 20 : 0,
        right: isUser ? 0 : 20,
      ),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isUser ? 16 : 4),
                topRight: Radius.circular(isUser ? 4 : 16),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
              color: isUser ? primaryColor : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: msg.containsKey('data')
                ? _buildStructuredCard(msg['data'] as Map<String, dynamic>)
                : Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.catching_pokemon,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cat Expert',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isUser
                                ? Colors.white
                                : const Color(0xFF2C3E50),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
            child: Text(
              _formatTime(msg['timestamp'] as DateTime?),
              style: const TextStyle(fontSize: 10, color: Color(0xFF95A5A6)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(time.year, time.month, time.day);

    if (messageDay == today) {
      return 'Today ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == yesterday) {
      return 'Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFD9340);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Header
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                screenHeight * 0.02,
                16,
                screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: primaryColor,
                        size: screenWidth > 350 ? 20 : 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.catching_pokemon,
                      color: primaryColor,
                      size: screenWidth > 350 ? 20 : 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cat Breed Expert',
                          style: TextStyle(
                            fontSize: screenWidth > 350 ? 18 : 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Feline information & care guide',
                          style: TextStyle(
                            fontSize: screenWidth > 350 ? 12 : 11,
                            color: const Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (screenWidth > 320)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'AI Powered',
                        style: TextStyle(
                          fontSize: 11,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Chat Area
            Expanded(
              child: Container(
                color: const Color(0xFFF8F9FA),
                child: _messages.isEmpty
                    ? SingleChildScrollView(
                        child: Container(
                          height: screenHeight * 0.7,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: screenWidth * 0.4,
                                height: screenWidth * 0.4,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.catching_pokemon,
                                  color: primaryColor,
                                  size: screenWidth * 0.15,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Cat Breed Guide 🐱',
                                style: TextStyle(
                                  fontSize: screenWidth > 350 ? 24 : 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Learn about any cat breed',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenWidth > 350 ? 16 : 15,
                                  color: const Color(0xFF34495E),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                ),
                                child: Text(
                                  'Get detailed information about cat breeds including personality, grooming needs, health, and care requirements.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth > 350 ? 14 : 13,
                                    color: const Color(0xFF7F8C8D),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildSuggestionChip('Siamese', primaryColor),
                                  _buildSuggestionChip('Persian', primaryColor),
                                  _buildSuggestionChip(
                                    'Maine Coon',
                                    primaryColor,
                                  ),
                                  _buildSuggestionChip('Bengal', primaryColor),
                                  _buildSuggestionChip('Sphynx', primaryColor),
                                  _buildSuggestionChip('Ragdoll', primaryColor),
                                  _buildSuggestionChip(
                                    'British Shorthair',
                                    primaryColor,
                                  ),
                                  _buildSuggestionChip(
                                    'Scottish Fold',
                                    primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          MediaQuery.of(context).viewInsets.bottom + 80,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index], context);
                        },
                      ),
              ),
            ),

            // Input Area
            Container(
              padding: EdgeInsets.fromLTRB(
                12,
                8,
                12,
                8 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF2C3E50),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Type cat breed name...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF95A5A6),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                              maxLines: 1,
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _isLoading ? null : _sendMessage,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: screenWidth > 350 ? 48 : 44,
                          height: screenWidth > 350 ? 48 : 44,
                          alignment: Alignment.center,
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: screenWidth > 350 ? 22 : 20,
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

  Widget _buildSuggestionChip(String text, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
