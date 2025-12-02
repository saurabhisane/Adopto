import 'package:adopto/constants.dart';
import 'package:adopto/screens/breed_expert.dart';
import 'package:adopto/screens/profile.dart';
import 'package:adopto/widgets/pet_category_tab_card.dart';
import 'package:adopto/widgets/pet_grid_list.dart';
import 'package:adopto/services/pet_service.dart';
import 'package:provider/provider.dart';
import 'package:adopto/providers/auth_provider.dart';
import 'package:adopto/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:adopto/widgets/location_picker.dart';
import 'package:adopto/screens/add_pet.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<PetData> _pets = [];
  bool _loading = true;
  String? _error;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final category = CategoryData.categories[_selectedCategoryIndex].title;
      final list = await PetService.fetchPets(
        category: category == 'All' ? null : category,
      );
      if (list == null) {
        setState(() {
          _error = 'Failed to load pets';
          _loading = false;
        });
        return;
      }
      setState(() {
        _pets = list.map((e) => PetData.fromJson(e)).toList();
        _loading = false;
      });
    } catch (err) {
      setState(() {
        _error = err.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    size: 20,
                    color: kBrownColor,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            );
          },
        ),
        title: Text(
          'Adopto',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: kBrownColor,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: const NetworkImage(kDummyProfilePicUrl),
                  backgroundColor: Colors.grey[200],
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                kPrimaryColor.withOpacity(0.9),
                kPrimaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const LocationPicker(),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.blue.shade50, Colors.green.shade50],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BreedExpert(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: kPrimaryColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: kPrimaryColor.withOpacity(0.1),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.pets_rounded,
                                      color: kPrimaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Explore Different Breeds',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Get expert information about pet breeds',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimaryColor.withOpacity(0.1),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: kPrimaryColor,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PetCategoryTabBar(
            categories: CategoryData.categories,
            onTabChanged: (index) {
              setState(() {
                _selectedCategoryIndex = index;
              });
              _loadPets();
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : PetGridList(pets: _filterPets()),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: kPrimaryColor),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                // perform logout
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddPetScreen()),
          );
          if (res == true) {
            // refresh list
            _loadPets();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<PetData> _filterPets() {
    final cat = CategoryData.categories[_selectedCategoryIndex].title;
    if (cat == 'All') return _pets;
    // support `category` field from backend
    return _pets
        .where(
          (p) => (p.breed == cat || (p.category ?? '') == cat || cat == 'All'),
        )
        .toList();
  }
}
