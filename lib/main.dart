import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

void main() {
  runApp(const MyApp());
}

// const mainColor = Color(0xff02bbf0);
const backgroundColor = Color(0xFF1a1a26);
const mainColor = Color(0xff9d7cd8);
const sectionColor = Color(0xFF9abdf5);
const titleColor = Color(0xFFc0caf5);
const textColor = Color(0xFFc0caf5);
const yellow = Color(0xFFdec76e);
const green = Color(0xFF9ece6a);
const pink = Color(0xFFf7768e);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

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
        centerTitle: true,
        title: TextButton(
          style: const ButtonStyle(),
          onPressed: () {},
          child: Text(
            'NOMAD BOX',
            style: GoogleFonts.russoOne(
                fontSize: 26.0,
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
              key: const ValueKey('popular'),
              movieSection: popularMovies,
              sectionTitle: 'Popular Movies',
              boxHeight: 160.0,
              boxWidth: 240.0,
              textWidth: 220.0,
              textSize: 14.5,
              isPoularSection: true,
              isNowSection: false,
              isComingSoonSection: false,
            ),
            MovieSection(
              key: const ValueKey('now-playing'),
              movieSection: nowPlaying,
              sectionTitle: 'Now in Cinemas',
              boxHeight: 120.0,
              boxWidth: 110.0,
              textWidth: 110.0,
              textSize: 12.5,
              isPoularSection: false,
              isNowSection: true,
              isComingSoonSection: false,
            ),
            MovieSection(
              key: const ValueKey('coming-soon'),
              movieSection: comingSoon,
              sectionTitle: 'Coming Soon',
              boxHeight: 120.0,
              boxWidth: 110.0,
              textWidth: 100.0,
              textSize: 12.5,
              isPoularSection: false,
              isNowSection: false,
              isComingSoonSection: true,
            )
          ],
        ),
      ),
    );
  }
}

class MovieSection extends StatelessWidget {
  const MovieSection({
    Key? key,
    required this.movieSection,
    required this.sectionTitle,
    required this.boxHeight,
    required this.boxWidth,
    required this.textWidth,
    required this.textSize,
    required this.isPoularSection,
    required this.isNowSection,
    required this.isComingSoonSection,
  }) : super(key: key);

  final Future<List<MovieData>> movieSection;
  final String sectionTitle;
  final double boxHeight, boxWidth, textWidth, textSize;
  final bool isPoularSection, isNowSection, isComingSoonSection;

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
          height: isPoularSection ? 260.0 : 195.0,
          child: FutureBuilder(
            future: movieSection,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: makeList(
                      snapshot,
                      boxHeight,
                      boxWidth,
                      textWidth,
                      textSize,
                      isPoularSection,
                      isNowSection,
                      isComingSoonSection),
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

ListView makeList(
  AsyncSnapshot<List<MovieData>> snapshot,
  double? boxHeight,
  double? boxWidth,
  double? textWidth,
  double? fontSize,
  bool isPopularSection,
  bool isNowSection,
  bool isComingSoonSection,
) {
  if (!snapshot.hasData) {
    return ListView();
  }
  return ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: snapshot.data!.length,
    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
    itemBuilder: (context, index) {
      var movie = snapshot.data![index];
      final today = DateTime.utc(2023, 4, 21);
      final calculateDay =
          DateTime.parse(movie.releaseDate).difference(today).inDays;

      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: SizedBox(
                width: boxWidth,
                child: Stack(
                  children: [
                    SizedBox(
                      height: boxHeight,
                      // if theres no backdrop image, replace it with poster image
                      child: movie.thumb != null
                          ? FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image:
                                  'https://image.tmdb.org/t/p/w500${movie.thumb}',
                              fit: BoxFit.cover,
                            )
                          : FadeInImage.memoryNetwork(
                              width: boxWidth,
                              placeholder: kTransparentImage,
                              image:
                                  'https://image.tmdb.org/t/p/w500${movie.poster}',
                              fit: BoxFit.cover,
                            ),
                    ),
                    // shadow behind rating
                    if (isPopularSection)
                      Container(
                        width: boxWidth,
                        height: boxHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: sectionColor.withOpacity(0.5),
                              offset: const Offset(0, 130),
                              spreadRadius: 10,
                              blurRadius: 70,
                            ),
                          ],
                        ),
                      ),
                    if (isPopularSection)
                      Positioned(
                        left: 8,
                        top: 104,
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.russoOne(
                            fontSize: 60.0,
                            color: backgroundColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    Positioned(
                      right: isPopularSection ? 8 : 8,
                      top: isPopularSection ? 136 : 97,
                      child: movie.lang == 'en'
                          ? const LangTextWidget(
                              langText: 'ENG',
                            )
                          : movie.lang == 'ko'
                              ? const LangTextWidget(langText: 'KOR')
                              : const LangTextWidget(langText: 'SPA'),
                    ),
                    // d-day widget
                    if (isComingSoonSection)
                      Positioned(
                        top: 5,
                        left: 5,
                        child: CircleAvatar(
                          backgroundColor: pink,
                          radius: 16.0,
                          child: Text(
                            'D-${calculateDay + 1}',
                            style: GoogleFonts.rubik(
                              fontSize: 13.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),

          // movie title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7.0),
            child: SizedBox(
              width: textWidth,
              child: Column(
                children: [
                  Text(
                    movie.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontSize: fontSize,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: isPopularSection ? 1 : 2,
                    // maxLines: 2,
                  ),
                  if (isNowSection && movie.title.length < 16)
                    const SizedBox(
                      height: 15.0,
                    ),
                  if (isPopularSection || isNowSection)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isPopularSection)
                            // popularity
                            Text(
                              '${(movie.popularity * 0.01).toStringAsFixed(1)}%',
                              style: GoogleFonts.rubik(
                                color: textColor,
                                fontSize: 13,
                              ),
                            ),
                          // separator
                          if (isPopularSection)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('|',
                                  style: GoogleFonts.rubik(
                                    color: textColor,
                                    fontSize: 12.0,
                                  )),
                            ),
                          const IconWidget(
                            icon: Icons.thumb_up_alt_outlined,
                            color: green,
                          ),
                          // vote
                          Text(
                            '${movie.voteCount}',
                            style: GoogleFonts.rubik(
                              color: textColor,
                              fontSize: isPopularSection ? 13 : 12,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Icon(
                              Icons.circle,
                              color: textColor,
                              size: isPopularSection ? 5.0 : 4.0,
                            ),
                          ),
                          // rating
                          const IconWidget(
                            icon: Icons.star_rounded,
                            color: yellow,
                          ),
                          Text(
                            movie.averageVote is int
                                ? '${movie.averageVote}.0'
                                : '${movie.averageVote}',
                            style: GoogleFonts.rubik(
                              color: textColor,
                              fontSize: isPopularSection ? 13 : 12,
                            ),
                          )
                        ],
                      ),
                    ),
                  if (isPopularSection) const BookNowButton(),
                ],
              ),
            ),
          ),
        ],
      );
    },
    separatorBuilder: (context, index) => const SizedBox(width: 15),
  );
}

// class PopularityWidget extends StatelessWidget {
//   const PopularityWidget({
//     super.key,
//     required this.movie,
//   });

//   final MovieData movie;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // popularity
//           Text(
//             '${(movie.popularity * 0.01).toStringAsFixed(1)}%',
//             style: GoogleFonts.rubik(
//               color: textColor,
//               fontSize: 13,
//             ),
//           ),
//           // separator
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Text('|',
//                 style: GoogleFonts.rubik(
//                   color: textColor,
//                   fontSize: 12.0,
//                 )),
//           ),
//           const IconWidget(
//             icon: Icons.thumb_up_alt_outlined,
//             color: green,
//           ),
//           // vote
//           Text(
//             '${movie.voteCount}',
//             style: GoogleFonts.rubik(
//               color: textColor,
//               fontSize: 13,
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(left: 5.0),
//             child: Icon(
//               Icons.circle,
//               color: textColor,
//               size: 5.0,
//             ),
//           ),
//           // rating
//           const IconWidget(
//             icon: Icons.star_rounded,
//             color: yellow,
//           ),
//           Text(
//             movie.averageVote is int
//                 ? '${movie.averageVote}.0'
//                 : '${movie.averageVote}',
//             style: GoogleFonts.rubik(
//               color: textColor,
//               fontSize: 13,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

class BookNowButton extends StatelessWidget {
  const BookNowButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 28.0,
        width: 100.0,
        decoration: BoxDecoration(
          color: textColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: TextButton(
          onPressed: () {},
          child: SizedBox(
            height: 28.0,
            child: Text(
              'Book Now',
              style: GoogleFonts.rubik(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: backgroundColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class LangTextWidget extends StatelessWidget {
  const LangTextWidget({
    super.key,
    required this.langText,
  });
  final String langText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          width: 1.0,
          color: backgroundColor,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          langText,
          style: GoogleFonts.russoOne(
            color: backgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class IconWidget extends StatelessWidget {
  const IconWidget({
    super.key,
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Icon(
        icon,
        color: color,
        size: 18,
      ),
    );
  }
}

class ApiService {
  static const baseUrl = 'https://movies-api.nomadcoders.workers.dev';

  static Future<List<MovieData>> getMovies(path) async {
    List<MovieData> movieInstances = [];

    final url = Uri.parse('$baseUrl/$path');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final movies = data['results'];

      for (var movie in movies) {
        final movieInstance = MovieData.fromJson(movie);

        // getting released date of each movie
        DateTime releasedDate = DateTime.parse(movieInstance.releaseDate);

        if (path == 'popular') {
          movieInstances.add(movieInstance);
          movieInstances.sort(
            (a, b) => b.popularity.compareTo(a.popularity),
          );
        } else if (path == 'now-playing') {
          DateTime maxDate = DateTime.parse(data['dates']['maximum']);
          DateTime minDate = DateTime.parse(data['dates']['minimum']);
          // min and max date boundaries including today
          if ((releasedDate.isAtSameMomentAs(minDate)) ||
              (releasedDate.isAtSameMomentAs(maxDate)) ||
              (releasedDate.isAfter(minDate) &&
                  releasedDate.isBefore(maxDate))) {
            movieInstances.add(movieInstance);
            movieInstances.sort(
              (a, b) => a.releaseDate.compareTo(b.releaseDate),
            );
          }
        } else if (path == 'coming-soon') {
          DateTime maxDate = DateTime.parse(data['dates']['maximum']);
          DateTime minDate = DateTime.parse(data['dates']['minimum']);

          if ((releasedDate.isAtSameMomentAs(minDate)) ||
              (releasedDate.isAtSameMomentAs(maxDate)) ||
              (releasedDate.isAfter(minDate) &&
                  releasedDate.isBefore(maxDate))) {
            movieInstances.add(movieInstance);
            movieInstances
                .sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
          }
        }
      }

      return movieInstances;
    }
    throw Exception('failed to fetch movies: ${response.statusCode}');
  }
}

class MovieData {
  final String title, id, releaseDate, lang;
  final String? thumb, poster;
  double popularity;
  dynamic averageVote;
  int voteCount;

  MovieData.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        thumb = json['backdrop_path'], // null safety
        id = json['id'].toString(),
        popularity = json['popularity'],
        releaseDate = json['release_date'],
        poster = json['poster_path'],
        averageVote = json['vote_average'],
        voteCount = json['vote_count'],
        lang = json['original_language'];
}
