import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Function(TextStyle) onTextStyleChanged;

  SettingsPage({required this.onTextStyleChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextStyle _selectedTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );
  bool _dataSaver = false;
  bool _offlineMode = false;
  bool _allowExplicitContent = false;
  bool _showUnplayableSongs = false;
  double _crossfadeValue = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            _buildSettingsSection(
              title: 'Data Saver',
              child: SwitchListTile(
                title: Text('Off'),
                value: _dataSaver,
                onChanged: (bool value) {
                  setState(() {
                    _dataSaver = value;
                  });
                },
              ),
            ),
            _buildSettingsSection(
              title: 'Playback',
              children: [
                SwitchListTile(
                  title: Text('Offline mode'),
                  subtitle: Text(
                      'If you activate: when you go offline, you will only be able to play the music and podcasts you have downloaded.'),
                  value: _offlineMode,
                  onChanged: (bool value) {
                    setState(() {
                      _offlineMode = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Allow Explicit Content'),
                  value: _allowExplicitContent,
                  onChanged: (bool value) {
                    setState(() {
                      _allowExplicitContent = value;
                    });
                  },
                ),
                ListTile(
                  title: Text('Crossfade'),
                  subtitle: Slider(
                    value: _crossfadeValue,
                    min: 0,
                    max: 12,
                    divisions: 12,
                    label: _crossfadeValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _crossfadeValue = value;
                      });
                    },
                  ),
                ),
                SwitchListTile(
                  title: Text('Show unplayable songs'),
                  value: _showUnplayableSongs,
                  onChanged: (bool value) {
                    setState(() {
                      _showUnplayableSongs = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Text Style', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 20),
            Text('Font Size'),
            Slider(
              value: _selectedTextStyle.fontSize ?? 20,
              min: 10,
              max: 40,
              divisions: 6,
              label: '${_selectedTextStyle.fontSize?.round()}',
              onChanged: (value) {
                setState(() {
                  _selectedTextStyle = _selectedTextStyle.copyWith(fontSize: value);
                });
                widget.onTextStyleChanged(_selectedTextStyle);
              },
            ),
            SizedBox(height: 20),
            Text('Font Weight'),
            DropdownButton<FontWeight>(
              value: _selectedTextStyle.fontWeight,
              onChanged: (FontWeight? newValue) {
                setState(() {
                  _selectedTextStyle = _selectedTextStyle.copyWith(fontWeight: newValue);
                });
                widget.onTextStyleChanged(_selectedTextStyle);
              },
              items: FontWeight.values
                  .map((weight) => DropdownMenuItem(
                child: Text(weight.toString().split('.').last),
                value: weight,
              ))
                  .toList(),
            ),
            SizedBox(height: 20),
            Text('Font Color'),
            Row(
              children: [
                ColorOption(
                  color: Colors.black,
                  isSelected: _selectedTextStyle.color == Colors.black,
                  onTap: () {
                    setState(() {
                      _selectedTextStyle = _selectedTextStyle.copyWith(color: Colors.black);
                    });
                    widget.onTextStyleChanged(_selectedTextStyle);
                  },
                ),
                ColorOption(
                  color: Colors.white,
                  isSelected: _selectedTextStyle.color == Colors.white,
                  onTap: () {
                    setState(() {
                      _selectedTextStyle = _selectedTextStyle.copyWith(color: Colors.white);
                    });
                    widget.onTextStyleChanged(_selectedTextStyle);
                  },
                ),
                // Add more colors as needed
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage('https://example.com/your-profile-image.jpg'), // Replace with actual profile image URL
      ),
      title: Text('Mutahar Hashmi '),
      subtitle: Text('3 years premium client'),
    );
  }

  Widget _buildSettingsSection({required String title, List<Widget>? children, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          if (child != null) child,
          if (children != null) ...children,
        ],
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  ColorOption({required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
