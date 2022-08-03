import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;

final RegExp _identifierRegExp = RegExp('[a-z_][a-z0-9_]*');

class CreateCommand extends Command<int> {
  final Logger _logger;

  CreateCommand({
    Logger? logger,
  }) : _logger = logger ?? Logger() {
    argParser
      ..addOption('plugin-name', help: 'The plugin name for this new plugi.');
  }

  @override
  String get description =>
      'Create a new federated plugin in the specified direction.';

  @override
  String get name => 'create';

  ArgResults get _argResults => argResults!;

  @override
  Future<int> run() async {
    final generateProgress = _logger.progress('Creating project $_pluginName');

    final brick = Brick.git(
      const GitPath(
        'https://github.com/liugang1104/plugin_template.git',
      ),
    );
    final generator = await MasonGenerator.fromBrick(brick);
    final target = DirectoryGeneratorTarget(Directory(path.current));
    final files = await generator.generate(target,
        vars: {'project': _pluginName}, logger: _logger);
    generateProgress.complete('Generated ${files.length} file(s)');

    _logger.info(
        'Running "flutter pug get" in ${_pluginName}_platform_interface...');
    Process.runSync('flutter', ['pub', 'get'],
        workingDirectory:
            '${path.current}/$_pluginName/${_pluginName}_platform_interface');

    _logger.info('Running "flutter pug get" in $_pluginName...');
    Process.runSync('flutter', ['pub', 'get'],
        workingDirectory: '${path.current}/$_pluginName/$_pluginName');

    _logger.info('Running "flutter pug get" in example...');
    Process.runSync('flutter', ['pub', 'get'],
        workingDirectory: '${path.current}/$_pluginName/$_pluginName/example');

    _logger.info('All done!');

    return ExitCode.success.code;
  }

  String get _pluginName {
    final pluginName = _argResults['plugin-name'] as String? ??
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
