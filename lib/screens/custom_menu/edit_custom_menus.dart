// ignore_for_file: prefer_final_parameters
import 'package:flutter/material.dart';
import 'package:worldsmith/worldsmith.dart';

import '../../constants.dart';
import '../../project_context.dart';
import '../../util.dart';
import '../../widgets/cancel.dart';
import 'edit_custom_menu.dart';

/// A widget for viewing and editing a list of [CustomMenu] instances.
class EditCustomMenus extends StatefulWidget {
  /// Create an instance.
  const EditCustomMenus({
    required this.projectContext,
    super.key,
  });

  /// The project context to use.
  final ProjectContext projectContext;

  /// Create state for this widget.
  @override
  EditCustomMenusState createState() => EditCustomMenusState();
}

/// State for [EditCustomMenus].
class EditCustomMenusState extends State<EditCustomMenus> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) {
    final world = widget.projectContext.world;
    final menus = world.menus;
    return Cancel(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Menus'),
        ),
        body: ListView.builder(
          itemBuilder: (final context, final index) {
            final menu = menus[index];
            return ListTile(
              autofocus: index == 0,
              title: Text(menu.title),
              subtitle: Text('${menu.items.length}'),
              onTap: () async {
                await pushWidget(
                  context: context,
                  builder: (context) => EditCustomMenu(
                    projectContext: widget.projectContext,
                    menu: menu,
                  ),
                );
                setState(() {});
              },
            );
          },
          itemCount: menus.length,
        ),
        floatingActionButton: FloatingActionButton(
          autofocus: menus.isEmpty,
          onPressed: () async {
            final menu = CustomMenu(
              id: newId(),
              title: 'Untitled Menu',
            );
            world.menus.add(menu);
            widget.projectContext.save();
            await pushWidget(
              context: context,
              builder: (context) => EditCustomMenu(
                projectContext: widget.projectContext,
                menu: menu,
              ),
            );
            setState(() {});
          },
          tooltip: 'New Custom Menu',
          child: createIcon,
        ),
      ),
    );
  }
}
