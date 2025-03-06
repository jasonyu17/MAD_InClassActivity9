import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void createDatabase() async {
  // Open or create the database
  var _database = await openDatabase(
    join(await getDatabasesPath(), 'card_organizer.db'),
    onCreate: (db, version) async {
      // Create Folders table
      await db.execute('''
        CREATE TABLE Folders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Create Cards table
      await db.execute('''
        CREATE TABLE Cards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          suit TEXT,
          imageUrl TEXT,
          folderId INTEGER,
          FOREIGN KEY(folderId) REFERENCES Folders(id)
        )
      ''');

      // Prepopulate Folders table
      List<String> folderNames = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
      for (var folderName in folderNames) {
        await db.insert('Folders', {'name': folderName});
      }

      // Prepopulate Cards table
      List<Map<String, dynamic>> cards = [];
      List<String> suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
      List<String> cardNames = [
        'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'
      ];

      for (var suit in suits) {
        for (var i = 0; i < cardNames.length; i++) {
          cards.add({
            'name': cardNames[i],
            'suit': suit,
            'imageUrl': 'assets/images/${cardNames[i].toLowerCase()}_of_${suit.toLowerCase()}.png',
            'folderId': suits.indexOf(suit) + 1, // Folder ID mapping
          });
        }
      }

      // Insert card data into Cards table
      for (var card in cards) {
        await db.insert('Cards', card);
      }
    },
    version: 1,
  );
}

void main() {
  createDatabase();
}
