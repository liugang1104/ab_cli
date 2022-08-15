import 'dart:io';

import 'package:ab_cli/src/commands/create/templates/template.dart';
import 'package:mason/mason.dart';

class ModuleTemplate extends Template {
  ModuleTemplate()
      : super(
            name: 'module',
            gitPath: 'whalefin_module',
            desc: 'Generate a WhaleFin Module.');

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    await dispatchPubGet(logger, outputDir.path);
    logger.info('Created a WhaleFin Module! 🍉');
  }
}
