import 'dart:async';

import 'package:flutter/material.dart';

import '../intents.dart';

/// A list tile that can be searched for within a [SearchableListView].
class SearchableListTile {
  /// Create an instance.
  const SearchableListTile({
    required this.searchString,
    this.autofocus = false,
    this.subtitle,
    this.title,
    this.onTap,
    this.selected = false,
  });

  /// The search string that will find this instance.
  final String searchString;

  /// Whether or not the resulting [ListTile] should be autofocused.
  final bool autofocus;

  /// The title for the [ListTile].
  final Widget? title;

  /// The [ListTile] subtitle.
  final Widget? subtitle;

  /// The on tap function.
  final VoidCallback? onTap;

  /// Whether the [ListTile] should be selected.
  final bool selected;
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
  Timer? _searchTimer;
  late final List<FocusNode> focusNodes;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _textFieldFocusNode = FocusNode();
    focusNodes = [];
  }

  /// Build the widget.
  @override
  Widget build(BuildContext context) {
    while (focusNodes.length < widget.children.length) {
      focusNodes.add(FocusNode());
    }
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Search'),
              focusNode: _textFieldFocusNode,
              onChanged: (value) {
                _searchTimer?.cancel();
                if (value.isEmpty) {
                  _searchTimer = null;
                } else {
                  _searchTimer = Timer(
                    const Duration(milliseconds: 500),
                    () {
                      _searchTimer = null;
                      value = value.toLowerCase();
                      for (var i = 0; i < widget.children.length; i++) {
                        final child = widget.children[i];
                        if (child.searchString
                            .toLowerCase()
                            .startsWith(value)) {
                          focusNodes[i].requestFocus();
                          return;
                        }
                      }
                      _controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _controller.text.length,
                      );
                    },
                  );
                }
              },
            ),
            subtitle: IconButton(
              onPressed: () => setState(() {
                _controller.text = '';
                _textFieldFocusNode.requestFocus();
              }),
              icon: const Icon(
                Icons.clear_outlined,
                semanticLabel: 'Clear',
              ),
            ),
          );
        }
        final child = widget.children[index - 1];
        return Shortcuts(
          child: Actions(
            child: ListTile(
              autofocus: child.autofocus,
              focusNode: focusNodes[index - 1],
              onTap: child.onTap,
              selected: child.selected,
              subtitle: child.subtitle,
              title: child.title,
            ),
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
              )
            },
          ),
          shortcuts: const {SearchIntent.hotkey: SearchIntent()},
        );
      },
      itemCount: widget.children.length + 1,
    );
  }

  /// Dispose of things.
  @override
  void dispose() {
    super.dispose();
    _textFieldFocusNode.dispose();
    _controller.dispose();
    _searchTimer?.cancel();
    while (focusNodes.isNotEmpty) {
      focusNodes.removeLast().dispose();
    }
  }
}
