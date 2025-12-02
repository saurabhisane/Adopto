import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class BirdBreedInformation extends StatefulWidget {
  const BirdBreedInformation({super.key});

  @override
  State<BirdBreedInformation> createState() => _BirdBreedInformationState();
}

class _BirdBreedInformationState extends State<BirdBreedInformation> {
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
Return a JSON object ONLY (no extra text) describing the requested bird species/breed. The JSON must include these keys (use empty string if data not available):
{
  "name",
  "scientific_name",
  "origin",
  "size",
  "weight",
  "wingspan",
  "lifespan",
  "diet",
  "temperament",
  "vocalization",
  "cage_requirements",
  "breeding_season",
  "conservation_status",
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
              // Header with bird name
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
                        Icons.air,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data['name']?.toString().toUpperCase() ?? 'UNKNOWN BIRD',
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
                      _buildFactTile('Scientific Name', data['scientific_name'], Icons.science, primaryColor),
                      _buildFactTile('Origin', data['origin'], Icons.public, primaryColor),
                      _buildFactTile('Size', data['size'], Icons.aspect_ratio, primaryColor),
                      _buildFactTile('Conservation', data['conservation_status'], Icons.eco, primaryColor),
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
                    child: _buildMetricCard('Weight', data['weight'], Icons.fitness_center, primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard('Wingspan', data['wingspan'], Icons.open_with, primaryColor),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Lifespan & Diet
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard('Lifespan', data['lifespan'], Icons.timelapse, primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildInfoCard('Diet', data['diet'], Icons.restaurant, primaryColor),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Behavior & Care
              Text(
                'BEHAVIOR & CARE',
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
                  _buildInfoSection('Temperament', data['temperament'], Icons.psychology, primaryColor),
                  _buildInfoSection('Vocalization', data['vocalization'], Icons.mic, primaryColor),
                  _buildInfoSection('Cage Requirements', data['cage_requirements'], Icons.home_work, primaryColor),
                  _buildInfoSection('Breeding Season', data['breeding_season'], Icons.egg, primaryColor),
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
                        Icon(
                          Icons.description,
                          color: primaryColor,
                          size: 18,
                        ),
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

  Widget _buildFactTile(String label, dynamic value, IconData icon, Color primaryColor) {
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
              child: Icon(
                icon,
                color: primaryColor,
                size: 16,
              ),
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

  Widget _buildMetricCard(String label, dynamic value, IconData icon, Color primaryColor) {
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
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 16,
                  ),
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

  Widget _buildInfoCard(String label, dynamic value, IconData icon, Color primaryColor) {
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
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 16,
                  ),
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
            const SizedBox(height: 8),
            Text(
              val,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, dynamic value, IconData icon, Color primaryColor) {
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
              child: Icon(
                icon,
                color: primaryColor,
                size: 16,
              ),
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
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                                  Icons.air,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Bird Expert',
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
                            color: isUser ? Colors.white : const Color(0xFF2C3E50),
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
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF95A5A6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.air,
                      color: primaryColor,
                      size: screenWidth > 350 ? 24 : 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bird Species Expert',
                          style: TextStyle(
                            fontSize: screenWidth > 350 ? 18 : 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bird information & care guide',
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                  Icons.air,
                                  color: primaryColor,
                                  size: screenWidth * 0.15,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Bird Species Guide 🦜',
                                style: TextStyle(
                                  fontSize: screenWidth > 350 ? 24 : 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Learn about any bird species',
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
                                  'Get detailed information about bird species including habitat, diet, care, and conservation status.',
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
                                  _buildSuggestionChip('Parrot', primaryColor),
                                  _buildSuggestionChip('Eagle', primaryColor),
                                  _buildSuggestionChip('Owl', primaryColor),
                                  _buildSuggestionChip('Hummingbird', primaryColor),
                                  _buildSuggestionChip('Peacock', primaryColor),
                                  _buildSuggestionChip('Penguin', primaryColor),
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
                  top: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
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
                                hintText: 'Type bird species...',
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
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
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