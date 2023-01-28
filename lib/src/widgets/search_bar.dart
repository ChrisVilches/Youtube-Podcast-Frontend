import 'dart:async';
import 'package:flutter/material.dart';
import '../services/clipboard_service.dart';
import '../services/locator.dart';
import '../util/youtube_url.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key, required this.isLoading, required this.onSearch});

  final bool isLoading;
  final void Function(String) onSearch;

  @override
  State<StatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _searchController;
  late final StreamSubscription<String> _clipboardEvents;
  String _currentClipboardValue = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    final ClipboardService clipboardService =
        serviceLocator.get<ClipboardService>();

    _clipboardEvents =
        clipboardService.clipboardEvents.stream.listen(_onClipboardUpdated);
    _currentClipboardValue = clipboardService.currentValue;
  }

  void _onClipboardUpdated(String value) {
    setState(() {
      _currentClipboardValue = isVideoOrPlaylistUrl(value) ? value : '';
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    // ignore: discarded_futures
    _clipboardEvents.cancel();
  }

  Future<void> _paste() async {
    if (_currentClipboardValue.isNotEmpty) {
      _searchController.text = _currentClipboardValue;
      if (isVideoOrPlaylistUrl(_currentClipboardValue)) {
        widget.onSearch(_currentClipboardValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a video or playlist URL';
                }
                return null;
              },
            ),
          ),
          if (_currentClipboardValue.isNotEmpty)
            IconButton(
              onPressed: widget.isLoading ? null : _paste,
              icon: const Icon(Icons.paste),
            ),
          IconButton(
            onPressed: widget.isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSearch(_searchController.value.text);
                    }
                  },
            icon: Icon(
              widget.isLoading ? Icons.more_horiz : Icons.search,
            ),
          )
        ],
      ),
    );
  }
}
