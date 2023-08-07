import 'package:butler/models/news_model.dart';
import 'package:flutter/material.dart';

class ExpandedNews extends StatefulWidget {
  final NewsModel news;
  const ExpandedNews({super.key, required this.news});

  @override
  State<ExpandedNews> createState() => _ExpandedNewsState();
}

class _ExpandedNewsState extends State<ExpandedNews> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("News"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: kToolbarHeight,
              child: Stack(
                children: [
                  Text(widget.news.title ?? "",
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleLarge!),
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.blue,
                        ),
                      )),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
              child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Text(widget.news.content ?? "",
                      style: Theme.of(context).textTheme.titleMedium!),
                ),
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.blue,
                    ),
                  )),
            ],
          ))
        ],
      ),
    );
  }
}
