import 'package:flutter/material.dart';
import '../settings/settings_view.dart';
import 'search_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const String _title = 'Youtube Podcast';

  @override
  Widget build(final BuildContext context) => Scaffold(
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
