import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// const mainColor = Color(0xff02bbf0);
const backgroundColor = Color(0xFF1a1a26);
const mainColor = Color(0xff9d7cd8);
const sectionColor = Color(0xFF9abdf5);
const titleColor = Color(0xFFc0caf5);

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

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

  final Future<List<MovieData>> popularMovies = ApiService.getMovies('popular');

  final Future<List<MovieData>> nowPlaying =
      ApiService.getMovies('now-playing');

  final Future<List<MovieData>> comingSoon =
      ApiService.getMovies('coming-soon');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0.0,
        centerTitle: false,
        title: TextButton(
          style: const ButtonStyle(),
          onPressed: () {},
          child: Text(
            'NOMAD BOX',
            style: GoogleFonts.russoOne(
                fontSize: 28.0,
                fontWeight: FontWeight.w600,
                color: mainColor,
                shadows: <Shadow>[
                  const Shadow(
                    offset: Offset(1.5, 1.5),
                    blurRadius: 2.0,
                    color: Colors.white,
                  )
                ]),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
            color: sectionColor,
            iconSize: 30.0,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MovieSection(
              movieSection: popularMovies,
              sectionTitle: 'Popular Movies',
              boxHeight: 160.0,
              boxWidth: 240.0,
              textWidth: 240.0,
              textSize: 16.0,
            ),
            MovieSection(
              movieSection: nowPlaying,
              sectionTitle: 'Now in Cinemas',
              boxHeight: 120.0,
              boxWidth: 110.0,
              textWidth: 100.0,
              textSize: 13.0,
            ),
            MovieSection(
              movieSection: comingSoon,
              sectionTitle: 'Coming Soon',
              boxHeight: 120.0,
              boxWidth: 110.0,
              textWidth: 100.0,
              textSize: 13.0,
            )
          ],
        ),
      ),
    );
  }
}

class MovieSection extends StatelessWidget {
  MovieSection({
    super.key,
    required this.movieSection,
    required this.sectionTitle,
    required this.boxHeight,
    required this.boxWidth,
    required this.textWidth,
    required this.textSize,
  });

  final Future<List<MovieData>> movieSection;
  String sectionTitle;
  double boxHeight, boxWidth, textWidth, textSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Text(
              sectionTitle,
              style: GoogleFonts.rubik(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
                color: sectionColor,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 200.0,
          child: FutureBuilder(
            future: movieSection,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: makeList(
                      snapshot, boxHeight, boxWidth, textWidth, textSize),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }
}

ListView makeList(AsyncSnapshot<List<MovieData>> snapshot, boxHeight, boxWidth,
    textWidth, fontSize) {
  return ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: snapshot.data!.length,
    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
    itemBuilder: (context, index) {
      var movie = snapshot.data![index];

      return Column(
        children: [
          Container(
            width: boxWidth,
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
              height: boxHeight,
              child: Image.network(
                'https://image.tmdb.org/t/p/w500${movie.thumb}',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: SizedBox(
              width: textWidth,
              child: Text(
                movie.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontSize: fontSize,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    },
    separatorBuilder: (context, index) => const SizedBox(width: 15),
  );
}

class ApiService {
  static const baseUrl = 'https://movies-api.nomadcoders.workers.dev';
  // static const popular = 'popular';
  // static const now_playing = 'now-playing';

  static Future<List<MovieData>> getMovies(path) async {
    List<MovieData> movieInstances = [];

    final url = Uri.parse('$baseUrl/$path');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final movies = data['results'];

      for (var movie in movies) {
        final instance = MovieData.fromJson(movie);
        movieInstances.add(instance);

        // sort by popularity
        if (path == 'popular') {
          movieInstances.sort(
            (a, b) => b.popularity.compareTo(a.popularity),
          );

          // sort by release date
        } else if (path == 'coming-soon') {
          movieInstances.sort(
            (a, b) => a.releaseDate.compareTo(b.releaseDate),
          );
        }
      }
      return movieInstances;
    }
    throw Error();
  }
}

class MovieData {
  final String title, thumb, id, releaseDate;
  double popularity;

  MovieData.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        thumb = json['backdrop_path'] ?? '', // null safety
        id = json['id'].toString(),
        popularity = json['popularity'],
        releaseDate = json['release_date'];
}
