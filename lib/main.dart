// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

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
const orange = Color(0xFFb26a46);
const blue = Color(0xFF057b91);
const burgundy = Color(0xFF800020);
const cream = Color(0xFFffe5b4);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(
                  0.9,
                ),
                shadows: <Shadow>[
                  const Shadow(
                    offset: Offset(2.5, 2.5),
                    blurRadius: 2.0,
                    color: mainColor,
                  )
                ]),
          ),
        ),
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
              textWidth: 111.0,
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

      return GestureDetector(
        onTap: () {
          Get.to(
            () => DetailScreen(
              title: movie.title,
              id: movie.id,
              lang: movie.lang,
              poster: movie.poster,
              averageVote: movie.averageVote,
              voteCount: movie.voteCount,
              thumb: movie.thumb,
            ),
            transition: Transition.fade,
            duration: const Duration(
              milliseconds: 200,
            ),
          );
        },
        child: Column(
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
                                width: boxWidth,
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
                    if (isPopularSection)
                      BookNowButton(
                        text: 'Book Now',
                        fontSize: 12.0,
                        boxHeignt: 28.0,
                        boxWidth: 100.0,
                        fontWeight: FontWeight.w500,
                        id: movie.id,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
    separatorBuilder: (context, index) => const SizedBox(width: 15),
  );
}

class BookNowButton extends StatelessWidget {
  const BookNowButton({
    super.key,
    required this.fontSize,
    required this.boxHeignt,
    required this.boxWidth,
    required this.text,
    required this.fontWeight,
    required this.id,
  });

  final double fontSize, boxHeignt, boxWidth;
  final String text, id;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    Future<MovieDetailModel> movie;
    movie = ApiService.getMovieById(id);
    return FutureBuilder(
        future: movie,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: boxHeignt,
              width: boxWidth,
              decoration: BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: TextButton(
                onPressed: () {
                  if (snapshot.data!.homepage.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                              title: const Icon(
                                Icons.warning_rounded,
                                color: Colors.red,
                              ),
                              content: Text(
                                'Ticket Unavailable',
                                style: GoogleFonts.rubik(
                                  fontSize: 15.0,
                                ),
                              ),
                              actions: [
                                CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    })
                              ],
                            ));
                  } else {
                    launchUrl(Uri.parse(snapshot.data!.homepage));
                  }
                },
                child: SizedBox(
                  height: 28.0,
                  child: Text(
                    text,
                    style: GoogleFonts.rubik(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: backgroundColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        });
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

  static Future<MovieDetailModel> getMovieById(String id) async {
    final url = Uri.parse('$baseUrl/movie?id=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final movie = jsonDecode(response.body);

      MovieDetailModel.fromJson(movie);
      return MovieDetailModel.fromJson(movie);
    }
    throw Error();
  }

  static Future<List<MovieGenreModel>> getGenres(String id) async {
    List<MovieGenreModel> genreInstances = [];
    final url = Uri.parse('$baseUrl/movie?id=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final movie = jsonDecode(response.body);
      final genres = movie['genres'];
      for (var genre in genres) {
        final genreInstance = MovieGenreModel.fromJson(genre);
        genreInstances.add(genreInstance);
      }

      return genreInstances;
    }
    throw Error();
  }

  // get each movie detail
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

class MovieDetailModel {
  final String title, overview, homepage;
  final int runtime;

  MovieDetailModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        overview = json['overview'],
        runtime = json['runtime'],
        homepage = json['homepage'];
}

class MovieGenreModel {
  final String name, genreId;

  MovieGenreModel.fromJson(Map<String, dynamic> json)
      : genreId = json['id'].toString(),
        name = json['name'];
}

class DetailScreen extends StatefulWidget {
  final String title, id, lang;
  final String? poster, thumb;
  final dynamic averageVote;
  final int voteCount;

  const DetailScreen({
    Key? key,
    required this.title,
    required this.id,
    required this.lang,
    required this.poster,
    required this.averageVote,
    required this.voteCount,
    required this.thumb,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<MovieDetailModel> movie;
  late Future<List<MovieGenreModel>> genre;

  @override
  void initState() {
    super.initState();
    movie = ApiService.getMovieById(widget.id);
    genre = ApiService.getGenres(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            expandedHeight: MediaQuery.of(context).size.height,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                    ),
                  ),
                  FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: 'https://image.tmdb.org/t/p/w500${widget.poster}',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0.2, 1.0],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end, // temporarily

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(widget.title,
                                style: GoogleFonts.russoOne(
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                )),
                          ),
                          RatingBar.builder(
                            initialRating: widget.averageVote / 2.0,
                            unratedColor: Colors.white.withOpacity(0.4),
                            minRating: 0,
                            maxRating: 5,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 28.0,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star_rounded,
                              color: yellow,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                          SizedBox(
                            height: 60.0,
                            width: 300.0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder(
                                    future: movie,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        int mins = snapshot.data!.runtime;
                                        int hrs = mins ~/ 60;
                                        int remainingMins = mins % 60;
                                        return Text(
                                          '${hrs}h ${remainingMins}min',
                                          style: GoogleFonts.rubik(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 14.0,
                                          ),
                                        );
                                      }
                                      return const Text('....');
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    child: Text(
                                      '|',
                                      style: GoogleFonts.rubik(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                  FutureBuilder(
                                    future: genre,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Expanded(
                                          child: Wrap(
                                            spacing: 5.0,
                                            runSpacing: 5.0,
                                            children: List.generate(
                                                snapshot.data!.length, (index) {
                                              return Container(
                                                width: 70,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                  border: Border.all(
                                                      width: 2.0,
                                                      color: snapshot
                                                                  .data![index]
                                                                  .name ==
                                                              'Animation'
                                                          ? pink
                                                          : snapshot
                                                                      .data![
                                                                          index]
                                                                      .name ==
                                                                  'Adventure'
                                                              ? green
                                                              : snapshot
                                                                          .data![
                                                                              index]
                                                                          .name ==
                                                                      'Family'
                                                                  ? yellow
                                                                  : snapshot.data![index].name ==
                                                                          'Fantasy'
                                                                      ? mainColor
                                                                      : snapshot.data![index].name ==
                                                                              'Comedy'
                                                                          ? orange
                                                                          : snapshot.data![index].name == 'Action'
                                                                              ? blue
                                                                              : snapshot.data![index].name == 'Science Fiction'
                                                                                  ? cream
                                                                                  : snapshot.data![index].name == 'Thriller'
                                                                                      ? burgundy
                                                                                      : snapshot.data![index].name == 'Crime'
                                                                                          ? sectionColor
                                                                                          : Colors.white30),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    snapshot.data![index].name,
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.rubik(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 11.0,
                                                      color: snapshot
                                                                  .data![index]
                                                                  .name ==
                                                              'Animation'
                                                          ? pink
                                                          : snapshot
                                                                      .data![
                                                                          index]
                                                                      .name ==
                                                                  'Adventure'
                                                              ? green
                                                              : snapshot
                                                                          .data![
                                                                              index]
                                                                          .name ==
                                                                      'Family'
                                                                  ? yellow
                                                                  : snapshot.data![index].name ==
                                                                          'Fantasy'
                                                                      ? mainColor
                                                                      : snapshot.data![index].name ==
                                                                              'Comedy'
                                                                          ? orange
                                                                          : snapshot.data![index].name == 'Action'
                                                                              ? blue
                                                                              : snapshot.data![index].name == 'Science Fiction'
                                                                                  ? cream
                                                                                  : snapshot.data![index].name == 'Thriller'
                                                                                      ? burgundy
                                                                                      : snapshot.data![index].name == 'Crime'
                                                                                          ? sectionColor
                                                                                          : Colors.white30,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        );
                                      }
                                      return const Text(
                                        '...',
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 23.0,
                          ),
                          Text(
                            'Storyline',
                            style: GoogleFonts.rubik(
                              color: textColor,
                              fontSize: 23.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          FutureBuilder(
                            future: movie,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 40.0,
                                        top: 10.0,
                                      ),
                                      child: Text(snapshot.data!.overview,
                                          style: GoogleFonts.rubik(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5,
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 30.0,
                                        bottom: 110.0,
                                      ),
                                      child: BookNowButton(
                                        fontSize: 20.0,
                                        boxHeignt: 50.0,
                                        boxWidth: 250.0,
                                        text: 'Buy Ticket',
                                        fontWeight: FontWeight.w600,
                                        id: widget.id,
                                      ),
                                    )
                                  ],
                                );
                              }
                              return const Text('...');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
