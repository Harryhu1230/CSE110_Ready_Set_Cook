import 'package:flutter/material.dart';
import 'package:ready_set_cook/models/ingredient.dart';
import 'package:ready_set_cook/models/nutrition.dart';
import 'package:ready_set_cook/models/recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ready_set_cook/services/recipes_database.dart';
import 'package:ready_set_cook/models/recipe.dart';
import 'package:ready_set_cook/shared/constants.dart';
import 'package:uuid/uuid.dart';

class CreateRecipe extends StatefulWidget {
  final Function toggleView;
  CreateRecipe({this.toggleView});
  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  RecipesDatabaseService recipeDB;
  final _ingredientKey = GlobalKey<FormState>();
  final _instructionKey = GlobalKey<FormState>();

  String _recipeName = "";
  double _rating = 0;
  int _numRatings = 0;
  String calories = "";
  String protein = "";
  String totalCarbs = "";
  String totalFat = "";
  List<Ingredient> _ingredients = [];
  List<String> _instructions = [];
  List<Nutrition> _nutritions = [];
  bool instruction_added = false;
  bool ingredient_added = false;
  String _instruction_error = "";
  String _ingredient_error = "";

  String _ingredientName = "";
  int _quantity = 0;
  String _unit = "";
  String instruction = "";

  TextEditingController _controller1 = TextEditingController();
  TextEditingController _controller2 = TextEditingController();
  TextEditingController _controller3 = TextEditingController();
  TextEditingController _controller4 = TextEditingController();
  TextEditingController _controller5 = TextEditingController();
  TextEditingController _controller6 = TextEditingController();
  TextEditingController _controller7 = TextEditingController();
  TextEditingController _controller8 = TextEditingController();

  _createIngredient() {
    ingredient_added = true;
    _ingredients.add(new Ingredient(
        nameOfIngredient: _ingredientName,
        quantity: _quantity.toString(),
        unit: _unit));
    _controller1.clear();
    _controller2.clear();
    _controller3.clear();
    setState(() {});
  }

  _createInstruction() {
    instruction_added = true;
    _instructions.add(instruction);
    _controller4.clear();
    setState(() {});
  }

  _createNutrients() {
    _nutritions.add(new Nutrition(
        calories: calories,
        protein: protein,
        totalFat: totalFat,
        totalCarbs: totalCarbs));
    _controller5.clear();
    _controller6.clear();
    _controller7.clear();
    _controller8.clear();
  }

  Future<void> _createRecipe() async {
    var _recipeId = Uuid().v4();
    recipeDB.addCustomRecipe(new Recipe(
        recipeId: _recipeId,
        name: _recipeName,
        ingredients: _ingredients,
        instructions: _instructions,
        nutritions: _nutritions,
        rating: _rating,
        numRatings: _numRatings));
    _controller1.clear();
    _controller2.clear();
    _controller3.clear();
    _controller4.clear();
    _ingredients.clear();
    _instructions.clear();

    _ingredientKey.currentState.save();
    _instructionKey.currentState.save();
    // }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _uid = FirebaseAuth.instance.currentUser.uid;
    recipeDB = RecipesDatabaseService(uid: _uid);

    final _tabPages = <Widget>[
      Center(
          child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
              key: _ingredientKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _controller1,
                      // key: ValueKey("ingredient name"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter an ingredient name";
                        } else {
                          return null;
                        }
                      },
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Enter Ingredient Name'),
                      onChanged: (val) {
                        setState(() => _ingredientName = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _controller2,
                      // key: ValueKey("quantity"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a quantity";
                        } else {
                          return null;
                        }
                      },
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Enter Quantity'),
                      onChanged: (val) {
                        setState(() => _quantity = int.parse(val));
                      },
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _controller3,
                      // key: ValueKey("unit"),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a unit";
                        }
                        return null;
                      },
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Enter Unit'),
                      onChanged: (val) {
                        setState(() => _unit = val);
                      },
                    ),
                    SizedBox(height: 15),
                    SizedBox(height: 20.0),
                    RaisedButton(
                        color: Colors.blue[400],
                        child: Text(
                          'Add Ingredient',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_ingredientKey.currentState.validate())
                            _createIngredient();
                        }),
                    Text(_ingredient_error,
                        style: TextStyle(color: Colors.red, fontSize: 14)),
                  ],
                ),
              )),
        ),
      )),
      Center(
          child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
              key: _instructionKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _controller4,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter an instruction";
                        }
                        return null;
                      },
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Enter Instruction'),
                      onChanged: (val) {
                        setState(() => instruction = val);
                      },
                    ),
                    SizedBox(height: 20.0),
                    RaisedButton(
                        color: Colors.blue[400],
                        child: Text(
                          'Add Instruction',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_instructionKey.currentState.validate())
                            _createInstruction();
                        }),
                    Text(_instruction_error,
                        style: TextStyle(color: Colors.red, fontSize: 14)),
                  ],
                ),
              )),
        ),
      )),
      Center(
          child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
              child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _controller5,
                  decoration:
                      textInputDecoration.copyWith(hintText: 'Enter Calories'),
                  onChanged: (val) {
                    setState(() => calories = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _controller6,
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Enter Protein Amount'),
                  onChanged: (val) {
                    setState(() => protein = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _controller7,
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Enter Total Fats'),
                  onChanged: (val) {
                    setState(() => totalFat = val);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _controller8,
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Enter Total Carbohydrates'),
                  onChanged: (val) {
                    setState(() => totalCarbs = val);
                  },
                ),
                SizedBox(height: 20.0),
                RaisedButton(
                    color: Colors.blue[400],
                    child: Text(
                      'Add Nutrients',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _createNutrients),
              ],
            ),
          )),
        ),
      )),
    ];
    final _tabs = <Tab>[
      const Tab(icon: Icon(Icons.add), text: 'Ingredients'),
      const Tab(icon: Icon(Icons.add), text: 'Instructions'),
      const Tab(icon: Icon(Icons.add), text: 'Nutrients')
    ];
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Recipe'),
          backgroundColor: Colors.cyan,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.done),
              label: Text('Add Recipe'),
              onPressed: () {
                if (ingredient_added && instruction_added) {
                  _createRecipe();
                  Navigator.of(context).pop();
                }
                if (!ingredient_added) {
                  setState(() {
                    _ingredient_error = "Please enter an ingredient";
                  });
                }
                if (!instruction_added) {
                  setState(() {
                    _instruction_error = "Please enter an instruction";
                  });
                }
              },
            ),
          ],
          // If `TabController controller` is not provided, then a
          // DefaultTabController ancestor must be provided instead.
          // Another way is to use a self-defined controller, c.f. "Bottom tab
          // bar" example.
          bottom: TabBar(
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
