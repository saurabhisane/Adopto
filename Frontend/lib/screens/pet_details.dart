import 'package:adopto/widgets/pet_details_info_card.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/pet_grid_list.dart';
import 'adopt_form.dart';

class PetDetailsScreen extends StatelessWidget {
  final PetData pet;

  const PetDetailsScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPinkishColor,
      body: CustomScrollView(
        slivers: [
          // pet image
          SliverAppBar(
            forceMaterialTransparency: true,
            expandedHeight: 400,
            flexibleSpace: FlexibleSpaceBar(
              background: pet.imageUrl.startsWith('http')
                  ? Image.network(pet.imageUrl, fit: BoxFit.cover)
                  : Image.asset(pet.imageUrl, fit: BoxFit.cover),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: kPrimaryColor),
                onPressed: () {},
              ),
            ],
          ),

          // pet details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  /// indicator
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: kGreyTextColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),

                  /// pet details info
                  PetDetailsInfoCard(pet: pet),
                  const SizedBox(height: 32),

                  // Owner info and description removed — not provided by backend
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.all(0)),
            onPressed: () async {
              final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => AdoptFormScreen(pet: pet)));
              if (res == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adoption request submitted')));
                // Optionally pop back to home or refresh
                Navigator.of(context).pop();
              }
            },
            child: Ink(
              decoration: BoxDecoration(gradient: kLinearGradient, borderRadius: BorderRadius.circular(24)),
              child: Container(
                alignment: Alignment.center,
                child: const Text('ADOPT NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
