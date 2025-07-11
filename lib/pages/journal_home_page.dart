import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sunset_entry.dart';
import 'add_new_entry.dart';
import 'favorite_sunsets.dart';
import 'photo_gallery.dart';

class JournalHomePage extends StatefulWidget {
  const JournalHomePage({super.key});

  @override
  State<JournalHomePage> createState() => _JournalHomePageState();
}

class _JournalHomePageState extends State<JournalHomePage> {
  final List<SunsetEntry> _entries = [];
  String _searchQuery = '';
  DateTime? _selectedDate;
  int _selectedIndex = 0;

  void _deleteEntry(SunsetEntry entry) {
    setState(() => _entries.remove(entry));
  }

  List<SunsetEntry> get _filteredEntries {
    final query = _searchQuery.toLowerCase();
    List<SunsetEntry> exactMatches = [];
    List<SunsetEntry> looseMatches = [];

    for (var entry in _entries) {
      final match = entry.caption.toLowerCase().contains(query) ||
          entry.description.toLowerCase().contains(query);

      if (!match) continue;

      if (_selectedDate != null) {
        if (entry.rawDate.year != _selectedDate!.year) continue;

        if (entry.rawDate.month == _selectedDate!.month &&
            entry.rawDate.day == _selectedDate!.day) {
          exactMatches.add(entry);
        } else {
          looseMatches.add(entry);
        }
      } else {
        looseMatches.add(entry);
      }
    }

    exactMatches.sort((a, b) => b.rawDate.compareTo(a.rawDate));
    looseMatches.sort((a, b) => b.rawDate.compareTo(a.rawDate));
    return [...exactMatches, ...looseMatches];
  }

  List<SunsetEntry> get _favoriteEntries =>
      _entries.where((e) => e.isFavorite).toList();

  void _onNavBarTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return FavoriteSunsetsPage(
          favoriteEntries: _favoriteEntries,
          onDelete: _deleteEntry,
        );
      case 2:
        return PhotoGallery(
          entries: _entries,
          title: "Sunset Gallery",
          onDelete: _deleteEntry,
        );
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "The sunset is\nbeautiful, isn’t it?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "Search by caption or description...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 20),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Filtered by date: ${DateFormat('MMMM d, y').format(_selectedDate!)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          Expanded(
            child: _filteredEntries.isEmpty
                ? const Center(child: Text("No matching sunset entries found."))
                : ListView.builder(
              itemCount: _filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = _filteredEntries[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryDetailScreen(
                            entry: entry,
                            onDelete: _deleteEntry,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.file(
                            entry.image,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: Colors.pink.shade50,
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.date,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text("Caption: ${entry.caption}"),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    entry.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: entry.isFavorite
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() => entry.isFavorite =
                                    !entry.isFavorite);
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false; // prevent pop
        }
        return true; // allow app to exit
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _selectedIndex == 0
                ? "Sunset Journal"
                : _selectedIndex == 1
                ? "Favorite Sunsets"
                : "Sunset Gallery",
          ),
          backgroundColor: Colors.pink.shade300,
          foregroundColor: Colors.white,
          actions: _selectedIndex == 0
              ? [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Filter',
              onPressed: () => setState(() => _selectedDate = null),
            ),
          ]
              : [],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddNewEntryPage(
                  onSave: (entry) =>
                      setState(() => _entries.insert(0, entry)),
                ),
              ),
            );
          },
          backgroundColor: Colors.pink.shade300,
          child: const Icon(Icons.add),

        )
            : null,
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavBarTapped,
          selectedItemColor: Colors.pink.shade300,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favorites",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: "Gallery",
            ),
          ],
        ),
      ),
    );
  }
}