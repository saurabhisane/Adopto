import 'package:adopto/widgets/pet_grid_list.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class CustomInfographic extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const CustomInfographic({
    super.key,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 32,
          width: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: kGreyTextColor,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: kBrownColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}

class PetDetailsInfoCard extends StatelessWidget {
  final PetData pet;

  const PetDetailsInfoCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    // Format age display
    final ageDisplay = pet.age.isEmpty ? 'Unknown' : pet.age;

    // Format gender display
    final genderDisplay = pet.isGenderMale ? 'Male' : 'Female';

    // Category display
    final categoryDisplay = pet.category?.isNotEmpty == true ? pet.category! : pet.breed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Pet basic info
        ListTile(
          /// name
          title: Text(pet.name),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: kBrownColor,
          ),

          /// category/breed
          subtitle: Row(
            children: [
              const Icon(
                Icons.pets_outlined,
                color: kGreyTextColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  categoryDisplay,
                  style: const TextStyle(
                    color: kGreyTextColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          /// breed info (if different from category)
          trailing: pet.breed.isNotEmpty
              ? Chip(
                  label: Text(
                    pet.breed,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: kPrimaryColor,
                )
              : null,
        ),

        /// Pet more details
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Gender
              CustomInfographic(
                color: kPrimaryColor,
                title: 'Gender',
                value: genderDisplay,
              ),

              /// Age
              CustomInfographic(
                color: const Color(0xffF78F8F),
                title: 'Age',
                value: ageDisplay,
              ),

              /// Category
              CustomInfographic(
                color: const Color(0xffF4D757),
                title: 'Type',
                value: categoryDisplay.length > 10
                    ? '${categoryDisplay.substring(0, 10)}...'
                    : categoryDisplay,
              ),
            ],
          ),
        ),
      ],
    );
  }
}