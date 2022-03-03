import 'package:flutter/material.dart';

import '../intents.dart';
import 'keyboard_shortcuts_list.dart';

/// A list tile that can be searched for within a [SearchableListView].
class SearchableListTile {
  /// Create an instance.
  const SearchableListTile({
    required this.searchString,
    required this.child,
  });

  /// The search string that will find this instance.
  final String searchString;

  /// The child to use.
  final Widget child;
}

/// A [ListView] that can be searched.
class SearchableListView extends StatefulWidget {
  /// Create an instance.
  const SearchableListView({
    required this.children,
    Key? key,
  }) : super(key: key);

  /// The list of children.
  final List<SearchableListTile> children;

  @override
  State<SearchableListView> createState() => _SearchableListViewState();
}

class _SearchableListViewState extends State<SearchableListView> {
  late final TextEditingController _controller;
  late final FocusNode _textFieldFocusNode;
  String? _searchString;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _textFieldFocusNode = FocusNode();
  }

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    final searchString = _searchString;
    final List<SearchableListTile> results;
    if (searchString == null) {
      results = widget.children;
    } else {
      results = widget.children
          .where(
            (element) => element.searchString.toLowerCase().startsWith(
                  searchString.toLowerCase(),
                ),
          )
          .toList();
    }
    return WithKeyboardShortcuts(
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            var labelText = 'Search';
            if (searchString != null) {
              labelText = '$labelText (${results.length} result';
              if (results.length == 1) {
                labelText = '$labelText)';
              } else {
                labelText = '${labelText}s)';
              }
            }
            return ListTile(
              title: TextField(
                controller: _controller,
                focusNode: _textFieldFocusNode,
                decoration: InputDecoration(
                  labelText: labelText,
                ),
                onChanged: (value) => setState(
                  () => _searchString = value.isEmpty ? null : value,
                ),
              ),
              subtitle: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => setState(
                        () {
                          setState(() => _controller.text = '');
                          _searchString = null;
                          _textFieldFocusNode.requestFocus();
                        },
                      ),
                      icon: const Icon(
                        Icons.clear_outlined,
                        semanticLabel: 'Clear',
                      ),
                    ),
            );
          }
          final child = results[index - 1];
          return Shortcuts(
            child: Actions(
              child: child.child,
              actions: {
                SearchIntent: CallbackAction<SearchIntent>(
                  onInvoke: (intent) {
                    _textFieldFocusNode.requestFocus();
                    _controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controller.text.length,
                    );
                    return null;
                  },
                ),
              },
            ),
            shortcuts: const {
              SearchIntent.hotkey: SearchIntent(),
            },
          );
        },
        itemCount: results.length + 1,
      ),
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Search the list.',
          keyName: '/',
        )
      ],
    );
  }

  /// Dispose of things.
  @override
  void dispose() {
    super.dispose();
    _textFieldFocusNode.dispose();
    _controller.dispose();
  }
}
