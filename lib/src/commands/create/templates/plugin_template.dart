import 'dart:io';

import 'package:ab_cli/src/commands/create/templates/template.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

class PluginTemplate extends Template {
  PluginTemplate()
      : super(
            name: 'plugin',
            gitPath: 'federated_plugin',
            desc: 'Generate a Flutter Federated plugin.');

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    // 执行pub get
    List<FileSystemEntity> dirList = outputDir.listSync(recursive: false);
    for (var element in dirList) {
      await dispatchPubGet(logger, element.path);
    }

    final pjName = p.basename(outputDir.path);
    await dispatchPubGet(logger, '${outputDir.path}/$pjName/example');
    logger.info('Created a Federated Plugin! 🍉');
  }
}
