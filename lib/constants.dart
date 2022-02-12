import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:short_uuids/short_uuids.dart';

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
