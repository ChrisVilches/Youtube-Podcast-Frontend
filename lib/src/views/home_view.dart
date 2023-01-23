import 'package:flutter/material.dart';
import '../settings/settings_view.dart';
import '../util/remove_splash.dart';
import 'search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const String _title = 'Youtube Podcast';

  @override
  void initState() {
    super.initState();
    // TODO: I think this should be in the app.dart file, because there's no guarantee
    //       the homeview will load first (e.g. if there's a route that was saved by the device and then restored).
    //       However the example just puts it in the homeview and not in the MyApp class. So maybe remove this TODO
    //       if it seems to work fine.

    // ignore: discarded_futures
    waitAndRemoveSplash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
        actions: <IconButton>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.restorablePushNamed(
              context,
              SettingsView.routeName,
            ),
          ),
        ],
      ),
      body: const SearchView(),
    );
  }
}
