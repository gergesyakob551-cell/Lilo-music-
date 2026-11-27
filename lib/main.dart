import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const LiloMusicApp());
}

class Song {
  final String title;
  final String artist;
  final String category;
  final String url;

  Song({
    required this.title,
    required this.artist,
    required this.category,
    required this.url,
  });
}

class LiloMusicApp extends StatelessWidget {
  const LiloMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lilo Music',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A061E),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isFavorite = true;
  int currentTab = 0;
  int currentSongIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String searchQuery = '';

  final List<Song> songs = [
    Song(
      title: 'ليالي النيون - Lilo Beat',
      artist: 'Lilo Music',
      category: 'أغاني جديدة',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    ),
    Song(
      title: 'لحظة هدوء ورومانسية',
      artist: 'Lilo Studio',
      category: 'أغاني رومانسية',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    ),
    Song(
      title: 'موسيقى ليلية حزينة',
      artist: 'Night Vibes',
      category: 'موسيقى حزينة',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerComplete.listen((_) => _nextSong());
  }

  Future<void> _playSong(int index) async {
    setState(() {
      currentSongIndex = index;
      isPlaying = true;
    });
    await _player.stop();
    await _player.play(UrlSource(songs[index].url));
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await _player.pause();
      setState(() => isPlaying = false);
    } else {
      if (position == Duration.zero) {
        await _playSong(currentSongIndex);
      } else {
        await _player.resume();
        setState(() => isPlaying = true);
      }
    }
  }

  void _nextSong() {
    int next = (currentSongIndex + 1) % songs.length;
    _playSong(next);
  }

  void _prevSong() {
    int prev = (currentSongIndex - 1 + songs.length) % songs.length;
    _playSong(prev);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = songs[currentSongIndex];
    final filteredSongs = songs
        .where((s) => s.title.contains(searchQuery) || s.category.contains(searchQuery))
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.5),
              radius: 1.2,
              colors: [Color(0xFF2B1055), Color(0xFF12082E), Color(0xFF060314)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _neonCircleButton(Icons.menu),
                      Row(
                        children: [
                          _neonCircleButton(Icons.notifications_none, hasBadge: true),
                          const SizedBox(width: 10),
                          _neonCircleButton(Icons.settings),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: currentTab == 2
                      ? _buildFullPlayer(currentSong)
                      : _buildHomeContent(filteredSongs),
                ),
                GestureDetector(
                  onTap: () => setState(() => currentTab = 2),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade900.withOpacity(0.95),
                          Colors.indigo.shade900.withOpacity(0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.purpleAccent.withOpacity(0.7)),
                      boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: const Icon(Icons.music_note, color: Colors.amber),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${currentSong.artist} • اضغط لفتح المشغل',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.pinkAccent,
                            size: 20,
                          ),
                          onPressed: () => setState(() => isFavorite = !isFavorite),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white),
                          onPressed: _nextSong,
                        ),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purpleAccent,
                              boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.6), blurRadius: 8)],
                            ),
                            child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 22),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous, color: Colors.white),
                          onPressed: _prevSong,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF09041C),
                    border: Border(top: BorderSide(color: Colors.purpleAccent.withOpacity(0.4))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(0, Icons.home, 'الرئيسية'),
                      _navItem(1, Icons.bar_chart, 'استكشاف'),
                      _navItem(2, Icons.play_circle_outline, 'مشغل الموسيقى'),
                      _navItem(3, Icons.person, 'حسابي'),
                      _navItem(4, Icons.workspace_premium, 'Premium'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(List<Song> filteredSongs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Icon(Icons.headphones, size: 70, color: Colors.purpleAccent.shade100),
                    ),
                    const Icon(Icons.workspace_premium, size: 30, color: Colors.amber),
                  ],
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500), Colors.white],
                  ).createShader(bounds),
                  child: const Text(
                    'Lilo Music',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Text(
                  '—  FEEL THE MUSIC  —',
                  style: TextStyle(color: Colors.white70, letterSpacing: 3, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.purpleAccent.withOpacity(0.6)),
            ),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'ابحث عن أغانيك المفضلة ...',
                hintStyle: TextStyle(color: Colors.white60, fontSize: 13),
                icon: Icon(Icons.search, color: Colors.white70),
                suffixIcon: Icon(Icons.mic, color: Colors.pinkAccent),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _quickActionCard('الأغاني أونلاين', 'أحدث الأغاني', Icons.language, Colors.blueAccent)),
              const SizedBox(width: 8),
              Expanded(child: _quickActionCard('قوائم التشغيل', 'أنشئ قائمتك', Icons.queue_music, Colors.cyanAccent)),
              const SizedBox(width: 8),
              Expanded(child: _quickActionCard('المفضلة', 'أغانيك المحبوبة', Icons.favorite, Colors.pinkAccent)),
              const SizedBox(width: 8),
              Expanded(child: _quickActionCard('تحميل الأغاني', 'استمع بدون نت', Icons.download_rounded, Colors.lightBlueAccent)),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orangeAccent),
              SizedBox(width: 6),
              Text('الأكثر استماعاً (اضغط للتشغيل)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(filteredSongs.length, (i) {
            final song = filteredSongs[i];
            final originalIndex = songs.indexOf(song);
            final active = originalIndex == currentSongIndex && isPlaying;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: active ? Colors.purpleAccent.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: active ? Colors.cyanAccent : Colors.purpleAccent.withOpacity(0.4)),
              ),
              child: ListTile(
                onTap: () => _playSong(originalIndex),
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(active ? Icons.equalizer : Icons.music_note, color: Colors.amber),
                ),
                title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(song.category, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                trailing: Icon(active ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.cyanAccent, size: 32),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFullPlayer(Song song) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Colors.purpleAccent, Color(0xFF1A0836)]),
              border: Border.all(color: Colors.amber, width: 2),
              boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 25)],
            ),
            child: const Icon(Icons.headphones, size: 95, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(song.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(song.category, style: const TextStyle(color: Colors.cyanAccent, fontSize: 14)),
          const SizedBox(height: 20),
          Slider(
            activeColor: Colors.pinkAccent,
            inactiveColor: Colors.white24,
            min: 0,
            max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1,
            value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1),
            onChanged: (val) => _player.seek(Duration(seconds: val.toInt())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatTime(position), style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_formatTime(duration), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.skip_next, size: 36), onPressed: _nextSong),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.purpleAccent]),
                    boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.6), blurRadius: 15)],
                  ),
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(icon: const Icon(Icons.skip_previous, size: 36), onPressed: _prevSong),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _neonCircleButton(IconData icon, {bool hasBadge = false}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.6)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        if (hasBadge)
          const Positioned(right: 2, top: 2, child: CircleAvatar(radius: 4, backgroundColor: Colors.redAccent)),
      ],
    );
  }

  Widget _quickActionCard(String title, String subtitle, IconData icon, Color glowColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: glowColor.withOpacity(0.7)),
      ),
      child: Column(
        children: [
          Icon(icon, color: glowColor, size: 24),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          Text(subtitle, style: const TextStyle(fontSize: 8.5, color: Colors.white60), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => currentTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.pinkAccent : Colors.white60, size: 22),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
