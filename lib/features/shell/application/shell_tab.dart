import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ShellTab { dashboard, timeline, biomarkers, twin }

class ShellTabController extends Notifier<ShellTab> {
  @override
  ShellTab build() => ShellTab.dashboard;

  void select(ShellTab tab) => state = tab;
}

final NotifierProvider<ShellTabController, ShellTab> shellTabProvider =
    NotifierProvider<ShellTabController, ShellTab>(ShellTabController.new);
