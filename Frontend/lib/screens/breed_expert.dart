import 'package:adopto/screens/bird_breed_expert.dart';
import 'package:adopto/screens/cat_breed_expert.dart';
import 'package:adopto/screens/dog_breed_expert.dart';
import 'package:flutter/material.dart';

class BreedExpert extends StatelessWidget {
  const BreedExpert({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFD9340);
    final textColor = const Color(0xFF2C3E50);
    final subtitleColor = const Color(0xFF7F8C8D);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.pets,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Breed Experts',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Professional guides for all animal breeds',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select an expert to learn about different breeds, their characteristics, care requirements, and more.',
                      style: TextStyle(
                        fontSize: 15,
                        color: subtitleColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.9),
                        primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('3', 'Experts', Icons.group),
                      _buildStatItem('200+', 'Breeds', Icons.format_list_numbered),
                      _buildStatItem('AI', 'Powered', Icons.auto_awesome),
                    ],
                  ),
                ),
              ),

              // Experts Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Available Experts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dog Expert Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Dog Breed Information
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DogBreedExpert(), // Your dog breed screen
                      ),
                    );
                  },
                  child: _buildExpertCard(
                    title: 'Dog Breed Expert',
                    subtitle: 'Canine Specialist',
                    description: 'Learn about dog breeds, temperament, training, and care requirements.',
                    icon: Icons.pets,
                    color: primaryColor,
                    iconBgColor: primaryColor.withOpacity(0.1),
                    stats: '150+ Breeds',
                  ),
                ),
              ),

              // Cat Expert Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Cat Breed Information
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CatBreedInformation(), // Your cat breed screen
                      ),
                    );
                  },
                  child: _buildExpertCard(
                    title: 'Cat Breed Expert',
                    subtitle: 'Feline Specialist',
                    description: 'Discover cat breeds, personalities, grooming needs, and health information.',
                    icon: Icons.catching_pokemon,
                    color: const Color(0xFF764BA2),
                    iconBgColor: const Color(0xFF764BA2).withOpacity(0.1),
                    stats: '70+ Breeds',
                  ),
                ),
              ),

              // Bird Expert Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Bird Breed Information
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BirdBreedInformation(), // Your bird breed screen
                      ),
                    );
                  },
                  child: _buildExpertCard(
                    title: 'Bird Species Expert',
                    subtitle: 'Avian Specialist',
                    description: 'Explore bird species, habitats, diet, vocalization, and conservation status.',
                    icon: Icons.air,
                    color: const Color(0xFF667EEA),
                    iconBgColor: const Color(0xFF667EEA).withOpacity(0.1),
                    stats: '100+ Species',
                  ),
                ),
              ),

              // Coming Soon Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'More Experts Coming Soon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'re working on adding more animal experts to our platform.',
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildComingSoonChip('Fish Expert', Icons.water),
                          _buildComingSoonChip('Reptile Expert', Icons.settings_ethernet),
                          _buildComingSoonChip('Small Pet Expert', Icons.mouse),
                          _buildComingSoonChip('Livestock Expert', Icons.agriculture),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Features Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'What You\'ll Get',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: Icons.auto_awesome,
                      title: 'AI-Powered Insights',
                      description: 'Get detailed, accurate information powered by advanced AI',
                      color: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.verified,
                      title: 'Verified Information',
                      description: 'All data is verified by animal experts and veterinarians',
                      color: const Color(0xFF764BA2),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.update,
                      title: 'Regular Updates',
                      description: 'Information is regularly updated with latest research',
                      color: const Color(0xFF667EEA),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.accessibility,
                      title: 'User-Friendly',
                      description: 'Easy to use interface designed for all users',
                      color: const Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                margin: const EdgeInsets.only(top: 40, bottom: 20),
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: Colors.grey.shade50,
                child: Column(
                  children: [
                    Text(
                      'Breed Experts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your trusted companion for animal breed information',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialIcon(Icons.email, primaryColor),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.share, primaryColor),
                        const SizedBox(width: 16),
                        _buildSocialIcon(Icons.info, primaryColor),
                      ],
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

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildExpertCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required Color iconBgColor,
    required String stats,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF7F8C8D),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stats,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
}