import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class Articalview extends StatefulWidget {
  final String url;
  final String title;
  final String image;
  const Articalview(
      {super.key, required this.url, required this.title, required this.image});

  @override
  State<Articalview> createState() => _ArticalviewState();
}

class _ArticalviewState extends State<Articalview> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String htmlData = '';
  List<String> paragraphs = [];

  Future<void> fetchData() async {
    final Uri url = Uri.parse(widget.url);
    final response = await http.get(url);
    if (response.statusCode == 200 || response.statusCode == 201) {
      htmlData = response.body;

      setState(() {});

      getData();
      if (kDebugMode) {
        print('Data fetched successfully');
      }
    } else {
      if (kDebugMode) {
        print('Failed to fetch data');
      }
    }
  }

  Future getData() async {
    final document = html.parse(htmlData);
    final data = document.getElementsByClassName('article-content');
    if (data.isNotEmpty) {
      final pTags = data[0].getElementsByTagName('p');
      for (var pTag in pTags) {
        paragraphs.add(pTag.text);
      }
      setState(() {});
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(widget.url))) {
      throw Exception('Could not launch ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ListView(
            children: [
              Image.network(widget.image),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                paragraphs.join('\n'),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: _launchUrl,
                    child: const Text(
                      'Source',
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.black),
                    )),
              ),
            ],
          ),
        ));
  }
}
