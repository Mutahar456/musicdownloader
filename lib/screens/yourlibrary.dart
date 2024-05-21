import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YourLibrary extends StatefulWidget {
  const YourLibrary({Key? key}) : super(key: key);

  @override
  _YourLibraryState createState() => _YourLibraryState();
}

class _YourLibraryState extends State<YourLibrary> {
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('searchHistory');
    if (history != null) {
      setState(() {
        _searchHistory = history;
      });
      print('Search history loaded: $_searchHistory');
    }
  }

  Future<void> _refreshLibrary() async {
    await _loadHistory();
  }

  Future<void> _removeHistoryItem(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.removeAt(index);
    });
    await prefs.setStringList('searchHistory', _searchHistory);
    print('History item removed: $_searchHistory');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Library',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        body: RefreshIndicator(
          onRefresh: _refreshLibrary,
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  _searchHistory[index],
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                leading: Icon(
                  Icons.history,
                  color: Colors.yellow,
                ),
                onTap: () {
                  // Handle tapping on history item
                },
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm'),
                          content: Text('Are you sure you want to delete this item from history?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                _removeHistoryItem(index);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
