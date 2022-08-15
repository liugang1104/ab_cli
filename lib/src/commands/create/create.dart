import 'dart:io';

import 'package:ab_cli/src/commands/create/templates/module_template.dart';
import 'package:ab_cli/src/commands/create/templates/plugin_template.dart';
import 'package:ab_cli/src/commands/create/templates/template.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

final RegExp _identifierRegExp = RegExp('[a-z_][a-z0-9_]*');

final _templates = [
  PluginTemplate(),
  ModuleTemplate(),
];

final _defaultTemplate = ModuleTemplate();

class CreateCommand extends Command<int> {
  final Logger _logger;

  CreateCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser
      ..addOption('project-name',
          help: 'The project name for this new project. ')
      ..addOption(
        'template',
        abbr: 't',
        help: 'The template used to generate this new project.',
        defaultsTo: _defaultTemplate.name,
        allowed: _templates.map((e) => e.name),
        allowedHelp: _templates.fold<Map<String, String>>(
          {},
          (previousValue, element) => {
            ...previousValue,
            element.name: element.desc,
          },
        ),
      );
  }

  @override
  String get description =>
      'Create a new federated plugin in the specified direction.';

  @override
  String get name => 'create';

  @override
  String get invocation => 'ab_cli create <output directory>';

  ArgResults get _argResults => argResults!;

  @override
  Future<int> run() async {
    final outputDirectory = _outputDirectory;
    final projectName = _projectName;
    final template = _template;
    final generateProgress = _logger.progress('Creating project $projectName');

    final brick = Brick.git(
      GitPath('https://github.com/liugang1104/code_bricks.git',
          path: template.gitPath),
    );
    final generator = await MasonGenerator.fromBrick(brick);
    final target = DirectoryGeneratorTarget(outputDirectory);
    final files = await generator.generate(target,
        vars: {'project': projectName}, logger: _logger);
    generateProgress.complete('Generated ${files.length} file(s)');
    await template.onGenerateComplete(_logger, outputDirectory);
    return ExitCode.success.code;
  }

  Template get _template {
    final templateName = _argResults['template'] as String?;
    return _templates.firstWhere((element) => element.name == templateName,
        orElse: () => _defaultTemplate);
  }

  String get _projectName {
    final pluginName = _argResults['project-name'] as String? ??
        path.basename(path.normalize(_outputDirectory.absolute.path));
    _validateProjectName(pluginName);
    return pluginName;
  }

  void _validateProjectName(String name) {
    final isValidProjectName = _isValidPackageName(name);
    if (!isValidProjectName) {
      usageException(
        '"$name" is not a valid package name.\n\n'
        'See https://dart.dev/tools/pub/pubspec#name for more information.',
      );
    }
  }

  bool _isValidPackageName(String name) {
    final match = _identifierRegExp.matchAsPrefix(name);
    return match != null && match.end == name.length;
  }

  Directory get _outputDirectory {
    final rest = _argResults.rest;
    _validateOutputDirectoryArg(rest);
    return Directory(rest.first);
  }

  void _validateOutputDirectoryArg(List<String> args) {
    if (args.isEmpty) {
      usageException('No option specified for the output directory.');
    }

    if (args.length > 1) {
      usageException('Multiple output directories specified.');
    }
  }
}
