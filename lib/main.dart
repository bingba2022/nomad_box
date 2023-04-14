import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

const mainColor = Color(0xFF884da7);
const subColor = Color(0xFFBEAEC7);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final Future<List<PopularMovie>> movies = ApiService.getPolularMovies();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: TextButton(
          style: const ButtonStyle(),
          onPressed: () {},
          child: Text(
            'NOMAD BOX',
            style: GoogleFonts.rubikBubbles(
              fontSize: 20.0,
              color: mainColor,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
            color: mainColor,
            iconSize: 30.0,
          )
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Text(
                'Popular Movies',
                style: GoogleFonts.rubik(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: FutureBuilder(
              future: movies,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: makeList(snapshot),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

ListView makeList(AsyncSnapshot<List<PopularMovie>> snapshot) {
  return ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: snapshot.data!.length,
    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
    itemBuilder: (context, index) {
      var movie = snapshot.data![index];

      return Column(
        children: [
          Container(
            width: 300,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                  color: Colors.black.withOpacity(0.2),
                )
              ],
            ),
            child: SizedBox(
              height: 190,
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${movie.thumb}',
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      );
    },
    separatorBuilder: (context, index) => const SizedBox(width: 15),
  );
}

class ApiService {
  static const baseUrl = 'https://movies-api.nomadcoders.workers.dev';
  static const popular = 'popular';

  static Future<List<PopularMovie>> getPolularMovies() async {
    List<PopularMovie> movieInstances = [];
    final url = Uri.parse('$baseUrl/$popular');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final movies = data['results'];
      for (var movie in movies) {
        final instance = PopularMovie.fromJson(movie);
        movieInstances.add(instance);
      }
      return movieInstances;
    }
    throw Error();
  }
}

class PopularMovie {
  final String title, thumb, id;

  PopularMovie.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        thumb = json['backdrop_path'] ?? '', // null safety
        id = json['id'].toString();
}
