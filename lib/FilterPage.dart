import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tubes_app/HomePage.dart';
import 'package:tubes_app/SearchResPage.dart';
import 'model/Recipe.dart';
import 'package:http/http.dart' as http;

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedFoodCategory = "";
  String? selectedCookingTimeCategory = "";

  TextEditingController keywordController = TextEditingController();

  final List<String> foodCategories = [
    'Daging',
    'Sayur',
    'Boga Bahari',
    'Makanan Pembuka',
    'Makanan Penutup',
  ];

  final List<String> cookingTimeCategories = [
    'Less than 30 minutes',
    '30 minutes to 1 hour',
    'More than 1 hour',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: Colors.white,
          elevation: 0,
          title: SizedBox(
            width: 250,
            child: TextField(
              controller: keywordController,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.bottom,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                hintStyle: TextStyle(color: Colors.grey),
                hintText: "Cari Resep...",
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            ListTile(
              title: Text(
                'Food type categories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: foodCategories.length,
              itemBuilder: (BuildContext context, int index) {
                final category = foodCategories[index];
                final isSelected = selectedFoodCategory == category;

                return CheckboxListTile(
                  title: Text(category),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        selectedFoodCategory = category;
                      } else {
                        selectedFoodCategory = "";
                      }
                    });
                  },
                );
              },
            ),
            ListTile(
              title: Text(
                'Cooking Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: cookingTimeCategories.length,
              itemBuilder: (BuildContext context, int index) {
                final category = cookingTimeCategories[index];
                final isSelected = selectedCookingTimeCategory == category;

                return RadioListTile(
                  title: Text(category),
                  value: category,
                  groupValue: selectedCookingTimeCategory,
                  onChanged: (String? value) {
                    setState(() {
                      selectedCookingTimeCategory = value;
                    });
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigator.pop(context);
            String keyword = keywordController.text;
            print('inputted keyword: $keyword');
            print('Selected food category: $selectedFoodCategory');
            print('Selected cooking time category: $selectedCookingTimeCategory');

            Navigator.push(context, MaterialPageRoute(
              builder: (context) => SearchResPage(
                keyword: keyword, 
                kategori: selectedFoodCategory.toString(), 
                durasi: selectedCookingTimeCategory.toString())
            ));
          },
          child: Icon(Icons.check),
          backgroundColor: Color(0xFF43AA8B),
        ),
      ),
    );
  }
}
