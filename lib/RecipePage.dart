// TODO: TabBar still nembus content

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './model/RecipedDetail.dart';
import 'constants/API.dart';
import 'model/Recipe.dart';

void main() {
  runApp(const RecipePage());
}

class RecipePage extends StatefulWidget {
  final int id;
  const RecipePage({Key? key, this.id = -1}) : super(key: key);

  Future<Map<String, dynamic>> addFavorite() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');

    print(email);
    print(this.id.toString());

    final res =
        await http.post(Uri.parse('${API.BASE_URL}/recipes/favorite'), body: {
      'email': email,
      'id': this.id.toString(),
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed: ${res.body}');
    }
  }

  void deleteFavorite() async {
    final res = await http
        .delete(Uri.parse('${API.BASE_URL}/recipes/favorite/${this.id}'));
    if (res.statusCode == 200) {
      print('berhasil');
    } else {
      throw Exception('Failed');
    }
  }

  Future<List<RecipeDetail>> fetchRecipe() async {
    final res = await http.get(Uri.parse('${API.BASE_URL}/recipe/${this.id}'));
    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);
      var parsed = data.cast<Map<String, dynamic>>();
      return parsed
          .map<RecipeDetail>((json) => RecipeDetail.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed fetching recipe detail');
    }
  }

  @override
  State<RecipePage> createState() => _RecipePageState();
}

Future<List<Recipe>> fetchMyRecipe() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');
  print(email);
  final Map<String, String> headers = {'Content-Type': 'application/json'};
  final uri = Uri.parse('${API.BASE_URL}/recipes/favorite')
      .replace(queryParameters: {'email': email});
  final res = await http.get(uri, headers: headers);
  if (res.statusCode == 200) {
    var data = jsonDecode(res.body);
    var parsed = data['dataRecipes'].cast<Map<String, dynamic>>();
    return parsed.map<Recipe>((json) => Recipe.fromJson(json)).toList();
  } else {
    throw Exception('Failed fetching favorite');
  }
}

class _RecipePageState extends State<RecipePage> {
  late Future<List<RecipeDetail>> recipes;
  late Future<List<Recipe>> futureRecipes;
  List<Recipe> favRecipes = [];
  bool isFavorite = false;

  void checkFavorite() {
    for (var map in favRecipes) {
      if (map.id == widget.id) {
        setState(() {
          isFavorite = true;
        });
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    recipes = RecipePage().fetchRecipe();
    futureRecipes = fetchMyRecipe();
    futureRecipes.then((value) {
      favRecipes = value;
    });
    checkFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          body: TabBarView(
            children: [
              Ingredients(),
              Instruction(),
              Comments(),
            ],
          ),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.orange,
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Recipe Name ${widget.id}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: isFavorite
                            ? Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.favorite,
                                color: Colors.white,
                              ),
                        onPressed: isFavorite
                            ? () {
                                widget.deleteFavorite();
                                setState(() {
                                  isFavorite = false;
                                });
                              }
                            : () async {
                                await widget.addFavorite();
                                setState(() {
                                  isFavorite = true;
                                });
                              },
                      ),
                      () {
                        for (var map in favRecipes) {
                          if (map.id == widget.id) {
                            isFavorite = true;
                            break;
                          }
                        }
                        if (!isFavorite) {
                          return IconButton(
                            onPressed: () async {
                              await widget.addFavorite();
                            },
                            iconSize: 16,
                            icon: Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                          );
                        } else {
                          return IconButton(
                            onPressed: () {
                              widget.deleteFavorite();
                            },
                            iconSize: 16,
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.white,
                            ),
                          );
                        }
                      }(),
                    ],
                  ),
                  background: Image(
                    image: AssetImage('assets/images/kill.jpg'),
                    fit: BoxFit.cover,
                    color: Colors.grey[700]?.withOpacity(0.5),
                    colorBlendMode: BlendMode.modulate,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: 20),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDeligate(
                  TabBar(
                    indicatorColor: Colors.white,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.orange,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 20),
                    tabs: [
                      Tab(
                        text: 'Ingredients',
                      ),
                      Tab(
                        text: 'Instruction',
                      ),
                      Tab(text: 'Comments'),
                    ],
                  ),
                ),
                pinned: true,
              )
            ];
          },
        ),
      ),
    );
  }
}

class _SliverAppBarDeligate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDeligate(this._tabBar);
  final TabBar _tabBar;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  // TODO: implement minExtent
  double get minExtent => _tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class Ingredients extends StatelessWidget {
  const Ingredients({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // kerjain di sini
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 30),
            itemCount: 15,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ListTile(
                  leading: const Icon(Icons.list),
                  trailing: const Text(
                    "GFG",
                    style: TextStyle(color: Colors.green, fontSize: 15),
                  ),
                  title: Text("List item $index"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Instruction extends StatelessWidget {
  const Instruction({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
            child: FutureBuilder<List<RecipeDetail>>(
          future: _RecipePageState().recipes,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text('Tidak ada data'));
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 30),
                itemCount: 15,
                itemBuilder: (BuildContext context, int index) {
                  print(snapshot.data![index].dataSteps[index]);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "${index}. List instruction $index",
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        )),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
        )),
      ],
    );
  }
}

class Comments extends StatelessWidget {
  const Comments({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // kerjain di sini
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/kill.jpg'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Write a nice comment...",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RatingBar(
              initialRating: 3,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              ratingWidget: RatingWidget(
                full: Icon(
                  Icons.star,
                  color: Colors.orange,
                ),
                half: Icon(
                  Icons.star_half,
                  color: Colors.orange,
                ),
                empty: Icon(
                  Icons.star_border,
                  color: Colors.orange,
                ),
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
            MaterialButton(
              onPressed: () {},
              child: Text(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.orange,
            ),
          ],
        ),
        // listview of comments with circle avatar here
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 30),
            itemCount: 15,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/kill.jpg'),
                  ),
                  title: Text("Comment $index"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
