import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 45, 168, 206)),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const AnimePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.adjust),
                        label: 'Pokemon',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.live_tv),
                        label: 'Anime',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.adjust),
                        label: Text('Pokemon'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.live_tv),
                        label: Text('Anime'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GeneratorPageState createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  String _pokemonName = '';
  String _imageUrl = '';
  List<String> _abilities = [];
  String _height = '';
  String _weight = '';
  String _errorMessage = '';

  Future<void> _searchPokemon() async {
    setState(() {
      _errorMessage = '';
    });

    final pokemonName = _controller.text.trim().toLowerCase();
    if (pokemonName.isEmpty) {
      return;
    }

    final url = 'https://pokeapi.co/api/v2/pokemon/$pokemonName';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _pokemonName = data['name'];
          _imageUrl = data['sprites']['front_default'];
          _abilities = List<String>.from(
              data['abilities'].map((ability) => ability['ability']['name']));
          _height = '${data['height'] / 10} m';
          _weight = '${data['weight'] / 10} kg';
        });
      } else {
        setState(() {
          _errorMessage = 'Pokémon no encontrado. Intenta de nuevo.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hubo un error al buscar el Pokémon.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Ingresa el nombre del Pokémon',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _searchPokemon,
            child: const Text('Buscar'),
          ),
          const SizedBox(height: 20),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.purple, fontSize: 16),
            ),
          if (_pokemonName.isNotEmpty) ...[
            Text(
              'Nombre: $_pokemonName',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.network(_imageUrl),
            const SizedBox(height: 10),
            Text('Habilidades: ${_abilities.join(', ')}'),
            const SizedBox(height: 10),
            Text('Altura: $_height'),
            const SizedBox(height: 10),
            Text('Peso: $_weight'),
          ]
        ],
      ),
    );
  }
}

class AnimePage extends StatefulWidget {
  const AnimePage({super.key});

  @override
  _AnimePageState createState() => _AnimePageState();
}

class _AnimePageState extends State<AnimePage> {
  final TextEditingController _controller = TextEditingController();
  String _animeTitle = '';
  String _animePosterImage = '';
  String _animeRating = '';
  String _animeDescription = '';
  String _errorMessage = '';

  Future<void> _searchAnime() async {
    setState(() {
      _errorMessage = '';
    });

    final animeTitle = _controller.text.trim();
    if (animeTitle.isEmpty) {
      return;
    }

    final url = 'https://kitsu.io/api/edge/anime?filter[text]=$animeTitle';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'].isEmpty) {
          setState(() {
            _errorMessage = 'Anime no encontrado. Intenta de nuevo.';
          });
        } else {
          final animeData = data['data'][0];

          setState(() {
            _animeTitle = animeData['attributes']['canonicalTitle'];
            _animePosterImage =
                animeData['attributes']['posterImage']['tiny'] ?? '';
            _animeRating = animeData['attributes']['averageRating'];
            _animeDescription = animeData['attributes']['synopsis'];
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Hubo un error al buscar el anime.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hubo un error al buscar el anime.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        // Allows scrolling for overflowed content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Anime name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchAnime,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.purple, fontSize: 16),
              ),
            if (_animeTitle.isNotEmpty) ...[
              Text(
                'Title: $_animeTitle',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_animePosterImage.isNotEmpty)
                Image.network(
                  _animePosterImage,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'No se pudo cargar la imagen.',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                )
              else
                const Text(
                  'No hay imagen disponible.',
                  style: TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 10),
              Text('Rating: $_animeRating'),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Description: $_animeDescription',
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
