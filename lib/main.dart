import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FoldersScreen(),
    );
  }
}

class FoldersScreen extends StatefulWidget {
  @override
  _FoldersScreenState createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  Database? _database;
  List<Map<String, dynamic>> _folders = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Organizer App')),
      body: _folders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                var folder = _folders[index];
                return ListTile(
                  leading: Image.asset(folder['imageUrl'] ?? 'assets/images/10_of_hearts.png'),
                  title: Text(folder['name']),
                  subtitle: Text('${folder['cardCount']} Cards'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardsScreen(folderId: folder['id']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class CardsScreen extends StatefulWidget {
  final int folderId;

  CardsScreen({required this.folderId});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late Database _database;
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      var database = await openDatabase(
        join(await getDatabasesPath(), 'card_organizer.db'),
      );

      var cardData = await database.query(
        'Cards',
        where: 'folderId = ?',
        whereArgs: [widget.folderId],
      );

      print('Cards fetched for folder ${widget.folderId}: $cardData');
      setState(() {
        _cards = cardData;
        _database = database;
      });
    } catch (e) {
      print('Error fetching cards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cards in Folder')),
      body: _cards.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                var card = _cards[index];
                return GestureDetector(
                  onLongPress: () {
                    _showCardOptions(context, card['id']);
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Image.asset(card['imageUrl'] ?? 'assets/images/10_of_hearts.png'),
                        Text(card['name']),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showCardOptions(BuildContext context, int cardId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Card Options'),
          actions: [
            TextButton(
              onPressed: () {
                _updateCard(cardId);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                _deleteCard(cardId);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCard() async {
    await _database.insert('Cards', {
      'name': 'New Card',
      'suit': 'Hearts',
      'imageUrl': 'assets/images/new_card.png',
      'folderId': widget.folderId,
    });
    _initializeDatabase(); 
  }

  Future<void> _updateCard(int cardId) async {
    await _database.update('Cards', {
      'name': 'Updated Card',
    }, where: 'id = ?', whereArgs: [cardId]);
    _initializeDatabase(); 
  }

  Future<void> _deleteCard(int cardId) async {
    await _database.delete('Cards', where: 'id = ?', whereArgs: [cardId]);
    _initializeDatabase(); 
  }
}
