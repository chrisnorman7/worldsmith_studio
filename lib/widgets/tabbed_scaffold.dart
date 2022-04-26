// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The directions for the [SwitchPageIntent] class.
enum SwitchPageDirections {
  /// Go to the next page.
  forwards,

  /// Go to the previous page.
  backwards,
}

/// An intent to switch pages.
class SwitchPageIntent extends Intent {
  /// Create an instance.
  const SwitchPageIntent(this.direction);

  /// The direction to switch in.
  final SwitchPageDirections direction;
}

/// The intent to change pages in a [TabbedScaffold].
class GotoPageIntent extends Intent {
  /// Create an instance.
  const GotoPageIntent(this.page);

  /// The page number to go to.
  final int page;
}

const _pageNumbers = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
  LogicalKeyboardKey.digit0,
];

/// A tab for a [TabbedScaffold].
class TabbedScaffoldTab {
  /// Create an instance.
  const TabbedScaffoldTab({
    required this.title,
    required this.icon,
    required this.builder,
    this.actions,
    this.floatingActionButton,
  });

  /// The title of the scaffold.
  final String title;

  /// The icon to use for the [BottomNavigationBarItem] that shows this tab.
  final Widget icon;

  /// The child to use.
  final WidgetBuilder builder;

  /// The actions to use for the app bar.
  final List<Widget>? actions;

  /// The floating action button to use.
  final FloatingActionButton? floatingActionButton;
}

/// A scaffold with multiple tabs.
class TabbedScaffold extends StatefulWidget {
  /// Create an instance.
  const TabbedScaffold({
    required this.tabs,
    super.key,
  });

  /// The tabs to use.
  final List<TabbedScaffoldTab> tabs;

  /// Create state for this widget.
  @override
  TabbedScaffoldState createState() => TabbedScaffoldState();
}

/// State for [TabbedScaffold].
class TabbedScaffoldState extends State<TabbedScaffold> {
  late int _index;

  /// Set the initial index.
  @override
  void initState() {
    super.initState();
    _index = 0;
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final gotoPageAction = CallbackAction<GotoPageIntent>(
      onInvoke: (final intent) {
        final page = intent.page;
        if (page < widget.tabs.length) {
          setState(() {
            _index = page;
          });
        }
        return null;
      },
    );
    final switchPageAction = CallbackAction<SwitchPageIntent>(
      onInvoke: (final intent) {
        final direction = intent.direction;
        var index = _index;
        switch (direction) {
          case SwitchPageDirections.forwards:
            index += 1;
            if (index >= widget.tabs.length) {
              index = 0;
            }
            break;
          case SwitchPageDirections.backwards:
            index -= 1;
            if (index < 0) {
              index = widget.tabs.length - 1;
            }
            break;
        }
        setState(() => _index = index);
        return null;
      },
    );
    final tab = widget.tabs[_index];
    return Shortcuts(
      shortcuts: {
        for (var i = 0; i < _pageNumbers.length; i++)
          SingleActivator(_pageNumbers[i], control: true): GotoPageIntent(i),
        const SingleActivator(
          LogicalKeyboardKey.tab,
          control: true,
        ): const SwitchPageIntent(SwitchPageDirections.forwards),
        const SingleActivator(
          LogicalKeyboardKey.tab,
          control: true,
          shift: true,
        ): const SwitchPageIntent(SwitchPageDirections.backwards)
      },
      child: Actions(
        actions: {
          GotoPageIntent: gotoPageAction,
          SwitchPageIntent: switchPageAction
        },
        child: Scaffold(
          appBar: AppBar(
            actions: tab.actions,
            title: Text(tab.title),
          ),
          body: Builder(builder: tab.builder),
          floatingActionButton: tab.floatingActionButton,
          bottomNavigationBar: BottomNavigationBar(
            items: widget.tabs
                .map(
                  (final e) => BottomNavigationBarItem(
                    icon: e.icon,
                    label: e.title,
                  ),
                )
                .toList(),
            currentIndex: _index,
            onTap: (final index) => setState(() => _index = index),
          ),
        ),
      ),
    );
  }
}
