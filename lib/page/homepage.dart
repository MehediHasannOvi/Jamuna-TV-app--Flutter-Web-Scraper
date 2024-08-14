import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:morningnews/model/articalmodel.dart';
import 'package:morningnews/page/articalview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(scrollListener);
  }

  String htmlData = '';
  List<ArticalModel> newsartical = [];
  List<ArticalModel> carouselArticals = [];
  bool isLoading = false;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final List<String> baseUrls = [
    'https://jamuna.tv/news/category/national/page/',
    'https://jamuna.tv/news/category/sports/page/'
        'https://jamuna.tv/news/category/international/page/',
    'https://jamuna.tv/news/category/all-bangladesh/page/',
    'https://jamuna.tv/news/category/entertainment/page/'
  ];

  void scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      loadMoreData();
      setState(() {});
    }
  }

  void loadMoreData() {
    if (isLoading) return; // Prevent multiple simultaneous loads

    setState(() {
      isLoading = true; // Start loading
      currentPage++; // Increment the page number
    });
    fetchData(); // Fetch data for the new page
  }

  Future<void> fetchData() async {
    for (var baseUrl in baseUrls) {
      final Uri url = Uri.parse('$baseUrl$currentPage');
      final response = await http.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        htmlData = response.body;
        getData(baseUrl);
        if (kDebugMode) {
          print('Data fetched successfully from $baseUrl');
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch data from $baseUrl');
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getData(String baseUrl) async {
    final document = html.parse(htmlData);
    final listofartical =
        document.getElementsByClassName('col-md-4 article latestPost excerpt');

    for (var item in listofartical) {
      final articalTitel = item.getElementsByClassName("story-title-page");
      final articalImageGet = item.getElementsByTagName("img");
      final articalImage = articalImageGet[0].attributes['src'];
      final articalurl = item.getElementsByTagName("a")[0].attributes['href'];

      ArticalModel articalModel = ArticalModel(
          title: articalTitel[0].text,
          image: articalImage ?? "",
          link: articalurl ?? "");

      newsartical.add(articalModel);

      // If the current base URL is for 'all-bangladesh', add to carouselArticals
      if (baseUrl == 'https://jamuna.tv/news/category/all-bangladesh/page/') {
        carouselArticals.add(articalModel);
      }
    }
  }

  @override
  void dispose() {
    // _scrollController.removeListener(scrollListener); // Remove the listener
    // _scrollController.dispose(); // Dispose of the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'সকালের খবর',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        controller: _scrollController, // Attach ScrollController
        children: [
          if (carouselArticals
              .isNotEmpty) // Show CarouselSlider if there are articles
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: CarouselSlider.builder(
                itemCount: carouselArticals.length,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  if (carouselArticals[itemIndex].image.isNotEmpty) {
                    return Container(
                      alignment: Alignment.bottomCenter,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blueGrey[100],
                        image: DecorationImage(
                          image: NetworkImage(
                                  carouselArticals[itemIndex].image) ??
                              const NetworkImage(
                                  "https://cdn.vectorstock.com/i/500p/63/92/404-error-page-not-found-sad-kawaii-cat-vector-51806392.avif"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          carouselArticals[itemIndex].title,
                          style: TextStyle(
                              background: Paint()
                                ..color = Colors.black.withOpacity(0.5),
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
                options: CarouselOptions(
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                ),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: newsartical.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ListTile(
                  title: Image.network(newsartical[index].image),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(newsartical[index].title),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Articalview(
                          url: newsartical[index].link,
                          title: newsartical[index].title,
                          image: newsartical[index].image,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          if (isLoading) // Show loading text if loading more data
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                height: 40,
                width: 80,
                child: Center(
                    child: LoadingIndicator(
                  strokeWidth: 2,
                  indicatorType: Indicator.ballPulseSync,
                  colors: [
                    Colors.blue,
                    Colors.red,
                    Colors.yellow,
                    Colors.green
                  ],
                )),
              ),
            ),
        ],
      ),
    );
  }
}
