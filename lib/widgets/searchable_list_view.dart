// ignore_for_file: prefer_final_parameters
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
    super.key,
  });

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
  Widget build(final BuildContext context) {
    final searchString = _searchString;
    final List<SearchableListTile> results;
    if (searchString == null) {
      results = widget.children;
    } else {
      results = widget.children
          .where(
            (final element) => element.searchString.toLowerCase().startsWith(
                  searchString.toLowerCase(),
                ),
          )
          .toList();
    }
    return WithKeyboardShortcuts(
      keyboardShortcuts: const [
        KeyboardShortcut(
          description: 'Search the list.',
          keyName: '/',
        )
      ],
      child: ListView.builder(
        itemBuilder: (final context, final index) {
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
                onChanged: (final value) => setState(
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
            shortcuts: const {
              SearchIntent.hotkey: SearchIntent(),
            },
            child: Actions(
              actions: {
                SearchIntent: CallbackAction<SearchIntent>(
                  onInvoke: (final intent) {
                    _textFieldFocusNode.requestFocus();
                    _controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controller.text.length,
                    );
                    return null;
                  },
                ),
              },
              child: child.child,
            ),
          );
        },
        itemCount: results.length + 1,
      ),
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

/// A widget that uses the given [builder] to build a [SearchableListView]
/// instance.
class BuiltSearchableListView<T> extends StatelessWidget {
  /// Create an instance.
  const BuiltSearchableListView({
    required this.items,
    required this.builder,
    super.key,
  });

  /// The items to build from.
  final Iterable<T> items;

  /// The function to build with.
  final SearchableListTile Function(BuildContext context, int index) builder;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final children = [
      for (var i = 0; i < items.length; i++) builder(context, i)
    ];
    return SearchableListView(children: children);
  }
}
