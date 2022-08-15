import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

abstract class Template {
  Template({
    required this.name,
    required this.gitPath,
    required this.desc,
  });

  // 模板名称
  final String name;

  // 模板git路径
  final String gitPath;

  // 描述
  final String desc;

  Future<void> onGenerateComplete(Logger logger, Directory outputDir);

  // 执行pun get
  Future<void> dispatchPubGet(Logger logger, String workingPath) async {
    final installProgress = logger
        .progress('Running "flutter pug get" in ${p.basename(workingPath)}...');
    await Process.run('flutter', ['pub', 'get'], workingDirectory: workingPath);
    installProgress.complete();
  }
}
