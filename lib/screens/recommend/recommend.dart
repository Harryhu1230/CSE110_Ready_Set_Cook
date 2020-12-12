import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ready_set_cook/screens/recipes/recipe.dart';
import 'package:ready_set_cook/screens/recommend/filtered_recommend.dart';
import 'package:ready_set_cook/services/recipes_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recommendTile.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter/services.dart';

class RecRecipe {
  int id;
  int calories;
  String carbs;
  String fat;
  String image;
  String imageType;
  String protein;
  String title;
  double spoonacularScore;
  String summary;

  RecRecipe(
      {this.id,
      this.carbs,
      this.fat,
      this.protein,
      this.image,
      this.imageType,
      this.title,
      this.spoonacularScore,
      this.summary});

  RecRecipe.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    calories = json['calories'];
    carbs = json['carbs'];
    fat = json['fat'];
    protein = json['protein'];
    image = json['image'];
    imageType = json['imageType'];
    title = json['title'];
    spoonacularScore = json['spoonacularScore'];
    summary = json['summary'];
  }
}

class RecipeMapper {
  final List<RecRecipe> recipes;

  RecipeMapper({
    this.recipes,
  });

  factory RecipeMapper.fromMap(Map<String, dynamic> map) {
    List<RecRecipe> recipes = [];
    if (map['recipes'] != null) {
      map['recipes']
          .forEach((recipe) => recipes.add(RecRecipe.fromMap(recipe)));
    }
    return RecipeMapper(
      recipes: recipes,
    );
  }
}

class Recommend extends StatefulWidget {
  @override
  _RecommendState createState() => _RecommendState();
}

class _RecommendState extends State<Recommend> {
  List<String> ingredientArray = [];
  List<RecRecipe> recipeList = [];

  Future<void> loadFromStorage() async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    CollectionReference _documentRef = FirebaseFirestore.instance
        .collection('grocery')
        .doc(uid)
        .collection('groceryList');

    await _documentRef.get().then((ds) {
      // print(ds.toString());
      if (ds != null) {
        ds.docs.forEach((ingredient) {
          ingredientArray.add(ingredient['name']);
        });
      }
    });
  }

  Future<bool> getFav(String recipeId) async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    bool result = false;
    CollectionReference _documentRef = FirebaseFirestore.instance
        .collection('recipes')
        .doc(uid)
        .collection('recipesList');

    await _documentRef.get().then((ds) {
      if (ds != null) {
        ds.docs.forEach((recipe) {
          var id = recipe['recipeId'];
          if (id == recipeId) {
            result = true;
          }
        });
      }
    });
    return result;
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  Widget buildList() {
    return recipeList.length != 0
        ? RefreshIndicator(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: ListView.builder(
                itemCount: recipeList.length,
                itemBuilder: (context, index) {
                  return new RecommendTile(
                    name: recipeList[index].title,
                    recipeId: recipeList[index].id.toString(),
                    imageType: recipeList[index].imageType,
                    spoonRating: recipeList[index].spoonacularScore,
                  );
                },
              ),
            ),
            onRefresh: getRecipes)
        : Center(
            child: noRecipes
                ? Text("No Recipes Found with Given Tags")
                : CircularProgressIndicator(),
          );
  }

  List<String> dietaryPreference = [
    "vegan",
    "vegetarian",
    "keto",
    "pescatarian",
    "dairy-free",
    "dessert",
    "mexican",
    "chinese"
  ];
  List<String> selectedDietaryPreference = [];

  void _openFilterDialog() async {
    await FilterListDialog.display(context,
        allTextList: dietaryPreference,
        height: 480,
        borderRadius: 20,
        headlineText: "Select Type of Recipes",
        searchFieldHintText: "Search Here",
        selectedTextList: selectedDietaryPreference,
        onApplyButtonClick: (list) {
      if (list != null) {
        setState(() {
          selectedDietaryPreference = List.from(list);
          useAPI();
          buildList();
        });
      }
      Navigator.pop(context);
    });
  }

  Future<void> _showMyDialog() async {
    TextEditingController numberController = new TextEditingController();
    String newNumber;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter number between 1-20'),
          content: TextFormField(
            controller: numberController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.number,
            validator: (input) {
              if (int.tryParse(input) == 0) {
                return "Please Enter Valid Number";
              }
              if (int.parse(input) > 20 || int.parse(input) < 1) {
                return "Please Enter Valid Number";
              }
              return null;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(
              width: 150,
            ),
            TextButton(
              child: Text('Change'),
              onPressed: () {
                setState(() {
                  newNumber = numberController.text;
                  this.number = int.parse(newNumber);
                  debugPrint(this.number.toString());
                  useAPI();
                  buildList();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildListWithDropDown() {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Column(children: [
        Container(
          height: 130,
          child: Column(children: <Widget>[
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Text("Change Filters",
                      style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 70.0,
                    height: 50.0,
                    child: RaisedButton(
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        "Recipes Displayed: " + this.number.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _showMyDialog,
                    ),
                  ),
                  ButtonTheme(
                    minWidth: 70.0,
                    height: 50.0,
                    child: RaisedButton(
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        "Diet and Cuisine",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _openFilterDialog,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        Expanded(
          child: buildList(),
        ),
      ]),
    );
  }

  // Default number of recipes returned is five
  int number = 5;
  // &tags=vegetarian,dessert
  String tags = "";
  // Consts for API
  String apiKey = '344f6c52e4a341fb9f0ed8a1d7037bda';
  String apiURL = 'https://api.spoonacular.com';
  String imageUrl = 'https://spoonacular.com/recipeImages/';

  bool noRecipes = false;
  void useAPI() async {
    // Tags are separated by commas
    String newTags = "";
    for (int i = 0; i < selectedDietaryPreference.length; i++) {
      if (i != selectedDietaryPreference.length - 1) {
        newTags += selectedDietaryPreference[i] + ",";
      } else {
        newTags += selectedDietaryPreference[i];
      }
    }
    tags = newTags;
    debugPrint(tags);
    var response = await http
        .get('$apiURL/recipes/random?number=$number&tags=$tags&apiKey=$apiKey');

    if (response.statusCode == 200) {
      debugPrint("API Response Generated");
      Map<String, dynamic> recipesData = jsonDecode(response.body);
      RecipeMapper recipeMapper = RecipeMapper.fromMap(recipesData);
      if (recipeMapper.recipes.isEmpty == true) {
        noRecipes = true;
      }
      // Return the Recipe List
      setState(() {
        recipeList = recipeMapper.recipes;
      });
    } else {
      debugPrint("API Response Error");
      throw Exception('Failed to load recipes');
    }
  }

  Future<void> getRecipes() async {
    setState(() {
      useAPI();
    });
  }

  @override
  void initState() {
    super.initState();
    getRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser.uid;
    String name = "";
    double rating = 0;
    String imageUrl;
    bool fav = false;
    String recipeId;
    final Size size = MediaQuery.of(context).size;
    double padding = 25;
    final sidePadding = EdgeInsets.symmetric(horizontal: padding);
    final _tabPages = <Widget>[
      // Build Storage Recipes
      Center(
          child: FutureBuilder(
              future: loadFromStorage(),
              builder: (context, loadSnapshot) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('allRecipes')
                      .orderBy("rating", descending: true)
                      .snapshots(),
                  builder: (ctx, allRecipeSnapshot) {
                    if (allRecipeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(child: CircularProgressIndicator());
                    }
                    final recipesdoc = allRecipeSnapshot.data.documents;
                    return Container(
                      width: size.width,
                      height: size.height,
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Expanded(
                                child: Padding(
                                  padding: sidePadding,
                                  child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      itemCount: recipesdoc.length,
                                      itemBuilder: (ctx, index) {
                                        recipeId = allRecipeSnapshot
                                            .data.documents[index]["recipeId"];
                                        name = allRecipeSnapshot
                                            .data.documents[index]['name'];
                                        var temp = allRecipeSnapshot
                                            .data.documents[index]['rating'];
                                        rating =
                                            roundDouble(temp.toDouble(), 1);
                                        imageUrl = allRecipeSnapshot
                                            .data.documents[index]['imageUrl'];
                                        // return Text("jsjs");
                                        return FilteredRecipe(
                                          recipeId: recipeId,
                                          ingredientArray: ingredientArray,
                                          name: name,
                                          rating: rating,
                                          imageUrl: imageUrl,
                                          fav: fav,
                                          uid: uid,
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              })),
      // Build API Recipes
      Center(
        child: buildListWithDropDown(),
      ),
    ];
    final _tabs = <Tab>[
      const Tab(
        icon: Icon(Icons.backpack),
        text: 'Suggested from Storage',
      ),
      const Tab(icon: Icon(Icons.approval), text: 'Based on Filters')
    ];
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: TabBar(
            tabs: _tabs,
          ),
        ),
        body: TabBarView(
          children: _tabPages,
        ),
      ),
    );
  }
}
