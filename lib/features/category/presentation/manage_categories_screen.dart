import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:spendsnap/data/db/database.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState
    extends State<ManageCategoriesScreen> {

  final db = AppDatabase();

  List<Category> categories = [];

  /*final availableColors = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.brown,
  ];

  final availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.receipt_long,
    Icons.local_hospital,
    Icons.movie,
    Icons.trending_up,
    Icons.home,
    Icons.school,
    Icons.flight,
    Icons.sports_esports,
    Icons.category,
  ];*/

  final availableColors = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.cyan,
    Colors.indigo,
    Colors.pink,  
    Colors.grey,
    Colors.lime,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,  
    Colors.yellow,
    Colors.blueGrey,
    Colors.black12
  ];
  

  final availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.receipt_long,
    Icons.local_hospital,
    Icons.movie,
    Icons.trending_up,
    Icons.home,
    Icons.school,
    Icons.flight,
    Icons.sports_esports,
    Icons.category,
    Icons.pets,
    Icons.coffee,
    Icons.fastfood,
    Icons.local_gas_station,
    Icons.directions_bus,
    Icons.directions_subway,
    Icons.directions_bike,
    Icons.directions_boat,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.local_mall,
    Icons.local_florist,
    Icons.local_grocery_store,
    Icons.local_library,
    Icons.local_pharmacy,
    Icons.local_play,
    Icons.local_see,
    Icons.local_shipping,
    Icons.local_taxi,
    Icons.local_convenience_store,
    Icons.local_dining,
    Icons.local_drink,
    Icons.local_fire_department,
    Icons.local_hotel,
    Icons.local_laundry_service,
    Icons.local_offer,
    Icons.local_parking,
    Icons.local_police,
    Icons.local_post_office,
    Icons.local_printshop,
    Icons.local_see,
    Icons.inventory_sharp,
    Icons.luggage,
    Icons.monetization_on,
    Icons.money,
    Icons.payments,
    Icons.savings,
    Icons.sell,
    Icons.shopping_cart,
    Icons.store,
    Icons.support,
    Icons.swipe,
    Icons.transfer_within_a_station,
    Icons.wallet,
    Icons.work,
    Icons.cake
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final data = await db.getUserCategories(user.uid);

    setState(() {
      categories = data;
    });
  }

  Future<void> _showAddCategoryDialog() async {

    final nameController = TextEditingController();
    final keywordsController = TextEditingController();

    int selectedColor = Colors.blue.value;

    int selectedIcon =
        Icons.category.codePoint;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await showDialog(
      context: context,

      builder: (_) {

        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(

              title: const Text("Add Category"),

              content: SingleChildScrollView(

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    // 🔥 NAME
                    TextField(
                      controller: nameController,

                      decoration: const InputDecoration(
                        labelText: "Category Name",
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🔥 KEYWORDS
                    TextField(
                      controller: keywordsController,

                      decoration: const InputDecoration(
                        labelText: "Keywords",
                        hintText: "food,hotel,zomato",
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 COLOR PICKER
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Color",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,

                      children: availableColors.map((c) {

                        final isSelected =
                            c.value == selectedColor;

                        return GestureDetector(

                          onTap: () {

                            setDialogState(() {
                              selectedColor = c.value;
                            });
                          },

                          child: CircleAvatar(

                            radius: isSelected ? 22 : 18,

                            backgroundColor: c,

                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );

                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 ICON PICKER
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Icon",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,

                      children: availableIcons.map((icon) {

                        final isSelected =
                            icon.codePoint == selectedIcon;

                        return GestureDetector(

                          onTap: () {

                            setDialogState(() {
                              selectedIcon =
                                  icon.codePoint;
                            });
                          },

                          child: CircleAvatar(

                            radius: 22,

                            backgroundColor: isSelected
                                ? Color(selectedColor)
                                : Colors.grey.shade200,

                            child: Icon(
                              icon,

                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );

                      }).toList(),
                    ),
                  ],
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () async {

                    final name =
                        nameController.text.trim();

                    final keywords =
                        keywordsController.text.trim();

                    if (name.isEmpty) return;

                    await db.insertCategory(

                      CategoriesCompanion.insert(

                        userId: user.uid,

                        name: name,

                        colorValue: selectedColor,

                        iconCodePoint:
                            selectedIcon,

                        keywords: keywords,
                      ),
                    );

                    if (!mounted) return;

                    Navigator.pop(context);

                    _loadCategories();
                  },

                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditCategoryDialog(
      Category category) async {

    final nameController =
        TextEditingController(text: category.name);

    final keywordsController =
        TextEditingController(text: category.keywords);

    int selectedColor = category.colorValue;
    int selectedIcon = category.iconCodePoint;

    await showDialog(
      context: context,

      builder: (_) {

        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(

              title: const Text("Edit Category"),

              content: SingleChildScrollView(

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    // 🔥 NAME
                    TextField(
                      controller: nameController,

                      decoration: const InputDecoration(
                        labelText: "Category Name",
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🔥 KEYWORDS
                    TextField(
                      controller: keywordsController,

                      decoration: const InputDecoration(
                        labelText: "Keywords",
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 COLOR PICKER
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Color",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,

                      children: availableColors.map((c) {

                        final isSelected =
                            c.value == selectedColor;

                        return GestureDetector(

                          onTap: () {

                            setDialogState(() {
                              selectedColor = c.value;
                            });
                          },

                          child: CircleAvatar(

                            radius: isSelected ? 22 : 18,

                            backgroundColor: c,

                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );

                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 ICON PICKER
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Icon",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,

                      children: availableIcons.map((icon) {

                        final isSelected =
                            icon.codePoint == selectedIcon;

                        return GestureDetector(

                          onTap: () {

                            setDialogState(() {
                              selectedIcon =
                                  icon.codePoint;
                            });
                          },

                          child: CircleAvatar(

                            radius: 22,

                            backgroundColor: isSelected
                                ? Color(selectedColor)
                                : Colors.grey.shade200,

                            child: Icon(
                              icon,

                              color: isSelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );

                      }).toList(),
                    ),
                  ],
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () async {

                    final updated =
                        category.copyWith(

                      name:
                          nameController.text.trim(),

                      keywords:
                          keywordsController.text.trim(),

                      colorValue: selectedColor,

                      iconCodePoint: selectedIcon,
                    );

                    await db.updateCategory(updated);

                    if (!mounted) return;

                    Navigator.pop(context);

                    _loadCategories();
                  },

                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Manage Categories"),
      ),

      body: categories.isEmpty

          ? const Center(
              child: Text("No categories found"),
            )

          : ListView.builder(
              itemCount: categories.length,

              itemBuilder: (_, index) {

                final c = categories[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  child: ListTile(

                    leading: CircleAvatar(
                      backgroundColor:
                          Color(c.colorValue)
                              .withOpacity(0.2),

                      child: Icon(
                        IconData(
                          c.iconCodePoint,
                          fontFamily: 'MaterialIcons',
                        ),

                        color: Color(c.colorValue),
                      ),
                    ),

                    title: Text(c.name),

                    subtitle: Text(c.keywords),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),

                      onPressed: () async {

                        await db.deleteCategory(c.id);

                        _loadCategories();
                      },
                    ),

                    onLongPress: () {
                      _showEditCategoryDialog(c);
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,

        child: const Icon(Icons.add),
      ),
    );
  }
}