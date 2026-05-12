import 'package:flutter/material.dart';

/// Attached to [ScaffoldWithNavBar] so descendants (e.g. [SectionBanner]) can open [Scaffold.endDrawer].
final GlobalKey<ScaffoldState> dashboardShellScaffoldKey =
    GlobalKey<ScaffoldState>();
