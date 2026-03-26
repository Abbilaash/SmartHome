import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

enum AppThemeMode { white, green, dark }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppThemeMode _themeMode = AppThemeMode.white;

  void _onThemeChanged(AppThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  ThemeData _buildTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7FB38A),
            secondary: Color(0xFFA1C9AA),
            surface: Color(0xFF1A1D1B),
          ),
          scaffoldBackgroundColor: const Color(0xFF121513),
          cardTheme: CardThemeData(
            color: const Color(0xFF1F2421),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      case AppThemeMode.green:
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2E7D32),
            secondary: Color(0xFF66BB6A),
            surface: Color(0xFFF4FAF5),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4FAF5),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      case AppThemeMode.white:
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1F2937),
            secondary: Color(0xFF4B5563),
            surface: Colors.white,
            outline: Color(0xFFC9D2DD),
            outlineVariant: Color(0xFFE1E7EF),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartHome',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(_themeMode),
      home: MainScreen(themeMode: _themeMode, onThemeChanged: _onThemeChanged),
    );
  }
}

// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeChanged;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Start at Home (middle)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AssistantPage(),
      const HomePage(),
      SettingsPage(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant),
            label: 'Assistant',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Room> rooms = [
    Room(
      name: 'Living Room',
      devices: [
        Device(name: 'Tube Light', icon: Icons.lightbulb, isOn: false),
        Device(name: 'Fan', icon: Icons.air, isOn: false),
        Device(name: 'Bulb', icon: Icons.wb_incandescent, isOn: true),
      ],
      temperature: 24,
      humidity: 65,
    ),
    Room(
      name: 'Bedroom',
      devices: [
        Device(name: 'Tube Light', icon: Icons.lightbulb, isOn: true),
        Device(name: 'Fan', icon: Icons.air, isOn: true),
        Device(name: 'Bulb', icon: Icons.wb_incandescent, isOn: false),
      ],
      temperature: 22,
      humidity: 60,
    ),
    Room(
      name: 'Kitchen',
      devices: [
        Device(name: 'Tube Light', icon: Icons.lightbulb, isOn: true),
        Device(name: 'Fan', icon: Icons.air, isOn: false),
        Device(name: 'Bulb', icon: Icons.wb_incandescent, isOn: true),
      ],
      temperature: 26,
      humidity: 70,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // App Name/Logo
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primary.withOpacity(0.12),
                    child: Icon(Icons.home, size: 24, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'SmartHome',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Rooms List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RoomDetailsPage(room: rooms[index]),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: scheme.outlineVariant.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.meeting_room,
                                  color: scheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  rooms[index].name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.thermostat,
                                      color: scheme.secondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${rooms[index].temperature}°C',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.opacity,
                                      color: scheme.secondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${rooms[index].humidity}%',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Room Details Page
class RoomDetailsPage extends StatefulWidget {
  final Room room;

  const RoomDetailsPage({super.key, required this.room});

  @override
  State<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends State<RoomDetailsPage> {
  late Room room;

  @override
  void initState() {
    super.initState();
    room = widget.room;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(room.name)),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // Temperature and Humidity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MetricCard(
                      icon: Icons.thermostat,
                      label: 'Temperature',
                      value: '${room.temperature}°C',
                      scheme: scheme,
                    ),
                    _MetricCard(
                      icon: Icons.opacity,
                      label: 'Humidity',
                      value: '${room.humidity}%',
                      scheme: scheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Devices List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Devices',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: room.devices.length,
                          itemBuilder: (context, index) {
                            Device device = room.devices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: scheme.outlineVariant.withOpacity(0.5),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: device.isOn
                                            ? scheme.primary.withOpacity(0.12)
                                            : scheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        device.icon,
                                        color: device.isOn
                                            ? scheme.primary
                                            : scheme.onSurfaceVariant,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        device.name,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: device.isOn,
                                      onChanged: (value) {
                                        setState(() {
                                          device.isOn = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Assistant Page
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _hasMicPermission = false;
  String _recognizedText = 'Your speech will appear here.';
  String _statusText = 'Tap the mic to allow permission and start listening';

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _ensureMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      _hasMicPermission = true;
      return true;
    }

    final requested = await Permission.microphone.request();
    _hasMicPermission = requested.isGranted;

    if (!mounted) return _hasMicPermission;

    if (requested.isPermanentlyDenied) {
      setState(() {
        _statusText =
            'Microphone permission permanently denied. Enable it from app settings.';
      });
      return false;
    }

    if (!_hasMicPermission) {
      setState(() {
        _statusText =
            'Microphone permission denied. Please allow microphone access.';
      });
      return false;
    }

    setState(() {
      _statusText = 'Microphone permission granted. Tap mic to speak.';
    });
    return true;
  }

  Future<void> _initSpeech() async {
    if (!_hasMicPermission) {
      final granted = await _ensureMicrophonePermission();
      if (!granted) return;
    }

    final enabled = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        setState(() {
          _isListening = status == 'listening';
          _statusText = _isListening
              ? 'Listening... speak now'
              : 'Tap the mic to start listening';
        });
      },
      onError: (errorNotification) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _statusText =
              'Speech input unavailable: ${errorNotification.errorMsg}';
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _speechEnabled = enabled;
      if (!enabled) {
        _statusText = 'Speech recognition is not available on this device.';
      }
    });
  }

  Future<void> _toggleListening() async {
    final granted = await _ensureMicrophonePermission();
    if (!granted) return;

    if (!_speechEnabled) {
      await _initSpeech();
      if (!_speechEnabled) return;
    }

    if (!_speech.hasPermission) {
      setState(() {
        _statusText =
            'Speech permission unavailable. Please check microphone settings.';
      });
      return;
    }

    if (_speech.isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _statusText = 'Tap the mic to start listening';
      });
      return;
    }

    await _speech.listen(
      onResult: (result) {
        final spoken = result.recognizedWords;
        if (spoken.isNotEmpty) {
          debugPrint('Recognized speech: $spoken');
        }
        if (!mounted) return;
        setState(() {
          _recognizedText = spoken.isEmpty ? 'Listening...' : spoken;
        });
      },
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      cancelOnError: true,
    );

    if (!mounted) return;
    setState(() {
      _isListening = true;
      _statusText = 'Listening... speak now';
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assistant, size: 72, color: scheme.primary),
              const SizedBox(height: 20),
              Text(
                'Voice Assistant',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Control your home with voice commands',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? scheme.secondary : scheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isListening ? scheme.secondary : scheme.primary)
                                .withOpacity(0.35),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _statusText,
                style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.6),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _recognizedText,
                  style: TextStyle(color: scheme.onSurface, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.settings, size: 36, color: scheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            // Settings Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildThemeSection(context),
                  const SizedBox(height: 12),
                  _buildSettingCard(
                    context,
                    'Wi-Fi',
                    Icons.wifi,
                    'Connected to SmartHome Network',
                  ),
                  _buildSettingCard(
                    context,
                    'Notifications',
                    Icons.notifications,
                    'Alerts enabled',
                  ),
                  _buildSettingCard(
                    context,
                    'About',
                    Icons.info,
                    'SmartHome v1.0',
                  ),
                  _buildSettingCard(
                    context,
                    'Help & Support',
                    Icons.help,
                    'Mail: abbilaashat@gmail.com\nfor queries contect A T Abbilaash via this email.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            RadioListTile<AppThemeMode>(
              contentPadding: EdgeInsets.zero,
              title: const Text('White'),
              value: AppThemeMode.white,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) onThemeChanged(value);
              },
            ),
            RadioListTile<AppThemeMode>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Green'),
              value: AppThemeMode.green,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) onThemeChanged(value);
              },
            ),
            RadioListTile<AppThemeMode>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark'),
              value: AppThemeMode.dark,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) onThemeChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: scheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: scheme.outlineVariant.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, color: scheme.primary, size: 26),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Models
class Room {
  final String name;
  final List<Device> devices;
  final int temperature;
  final int humidity;

  Room({
    required this.name,
    required this.devices,
    required this.temperature,
    required this.humidity,
  });
}

class Device {
  final String name;
  final IconData icon;
  bool isOn;

  Device({required this.name, required this.icon, required this.isOn});
}
