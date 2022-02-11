import 'dart:convert';

import 'package:short_uuids/short_uuids.dart';

/// The app name.
const appName = 'Worldsmith Studio';

/// The JSON encoder to use.
const indentedJsonEncoder = JsonEncoder.withIndent('  ');

/// The directory name for assets.
const assetsPath = 'assets';

/// The ID generator.
const shortUuid = ShortUuid();
