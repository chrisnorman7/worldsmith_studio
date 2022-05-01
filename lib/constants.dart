import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:short_uuids/short_uuids.dart';

/// The application version.
const appVersion = '0.1.0';

/// The app name.
const appName = 'Worldsmith Studio';

/// The JSON encoder to use.
const indentedJsonEncoder = JsonEncoder.withIndent('  ');

/// The directory name for assets.
const assetsPath = 'assets';

/// The ID generator.
const shortUuid = ShortUuid();

/// The new icon.
const createIcon = Icon(
  Icons.create_outlined,
  semanticLabel: 'Create',
);

/// The save icon to use.
const saveIcon = Icon(
  Icons.save_outlined,
  semanticLabel: 'Save',
);

/// The icon for deleting things.
const deleteIcon = Icon(
  Icons.delete_outline,
  semanticLabel: 'Delete',
);

/// The type of a callback that is used for validating a delete operation.
typedef CanDelete<T> = String? Function(T value);

/// The URL for the manual.
final manualUrl = Uri.parse(
  'https://chrisnorman7.github.io/worldsmith_studio_manual',
);

/// The date formatter to use.
final dateFormat = DateFormat.yMMMMEEEEd().add_Hms();
