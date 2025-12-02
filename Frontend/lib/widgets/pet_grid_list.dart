import 'package:flutter/material.dart';

import '../screens/pet_details.dart';

/// Pet Grid List
class PetGridList extends StatelessWidget {
  final List<PetData> pets;

  const PetGridList({super.key, required this.pets});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      itemCount: pets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        return PetGridTile(
          pet: pets[index],
        );
      },
    );
  }
}

/// Pet Grid Tile
class PetGridTile extends StatelessWidget {
  final PetData pet;

  const PetGridTile({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final hasValidImage = pet.imageUrl.isNotEmpty && pet.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailsScreen(pet: pet),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            // Background with image or error state
            if (hasValidImage)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: NetworkImage(pet.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.grey[400],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No Image',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Text overlay with dark gradient for visibility
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            pet.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Breed
                          Text(
                            pet.breed,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Gender and Age Row
                          Row(
                            children: [
                              // Gender
                              Icon(
                                pet.isGenderMale ? Icons.male : Icons.female,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pet.isGenderMale ? 'Boy' : 'Girl',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              // Age
                              const SizedBox(width: 4),
                              Text(
                                "Age : ${pet.age} year",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
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
}/// Pet Data Model
class PetData {
  final String? id;
  final String name;
  final String imageUrl;
  final String breed;
  final String? category;
  final String age;
  final bool isGenderMale;

  const PetData({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.breed,
    this.category,
    required this.age,
    required this.isGenderMale,
  });

  factory PetData.fromJson(Map<String, dynamic> json) {
    final gender = (json['gender'] ?? '').toString().toLowerCase();
    return PetData(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name'] ?? '',
      breed: json['breed'] ?? '',
      category: json['category'] ?? json['type'] ?? '',
      age: json['age'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      isGenderMale: gender == 'male' || gender == 'm',
    );
  }
}
