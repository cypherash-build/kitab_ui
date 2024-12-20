// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  runApp(const KiTabApp());
}

class KiTabApp extends StatelessWidget {
  const KiTabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KiTab',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        fontFamily: 'Roboto',
      ),
      home: const KiTabHomeScreen(),
    );
  }
}

class KiTabHomeScreen extends StatefulWidget {
  const KiTabHomeScreen({super.key});

  @override
  State<KiTabHomeScreen> createState() => _KiTabHomeScreenState();
}

class _KiTabHomeScreenState extends State<KiTabHomeScreen> {
  late Future<List<String>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _getBookPaths();
  }

  Future<List<String>> _getBookPaths() async {
    try {
      // Get a list of all files in the assets/books folder
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
      final pdfPaths = manifestMap.keys
          .where((path) =>
              path.startsWith('assets/books/') && path.endsWith('.pdf'))
          .toList();
      return pdfPaths;
    } catch (e) {
      print('Error getting book paths: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            // Handle shopping cart action
          },
        ),
        title: const Text('KiTab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options action
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _getBookPaths(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final bookPaths = snapshot.data ?? [];
            if (bookPaths.isEmpty) {
              return const Center(
                child: Text('No books found in assets.'),
              );
            } else {
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.6,
                ),
                itemCount: bookPaths.length,
                itemBuilder: (context, index) {
                  final bookPath = bookPaths[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PdfViewerScreen(filePath: bookPath),
                        ),
                      );
                    },
                    child: BookItem(
                      title: bookPath.split('/').last,
                      author:
                          'Unknown Author', // Replace with author extraction
                      filePath: bookPath,
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

class BookItem extends StatelessWidget {
  final String title;
  final String author;
  final String filePath;

  const BookItem({
    super.key,
    required this.title,
    required this.author,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: PdfViewer.asset(
            filePath,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        Text(
          author,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String filePath;

  const PdfViewerScreen({super.key, required this.filePath});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final TextEditingController _questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: PdfViewer.asset(
        widget.filePath,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuestionDialog(context);
        },
        child: const Icon(Icons.question_answer),
      ),
    );
  }

  Future<void> _showQuestionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ask a Question'),
          content: TextField(
            controller: _questionController,
            decoration: const InputDecoration(hintText: 'Enter your question'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ask'),
              onPressed: () {
                // TODO: Send the question to the LLM and get the answer
                String question = _questionController.text;
                print('Question: $question');
                // ... (Process the question and display the answer)

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
