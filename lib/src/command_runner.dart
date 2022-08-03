import 'package:ab_cli/src/commands/create.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';

class ABCommandRunner extends CommandRunner<int> {
  final Logger _logger;

  ABCommandRunner({
    Logger? logger,
  })  : _logger = logger ?? Logger(),
        super('ab_cli', 'A Flutter Plugin Command Line Interface') {
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the current version.',
    );
    addCommand(CreateCommand(logger: _logger));
  }

  @override
  Future<int> run(Iterable<String> args) async {
    final argResults = parse(args);
    return await runCommand(argResults) ?? ExitCode.success.code;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    int? exitCode = ExitCode.unavailable.code;
    if (topLevelResults['version'] == true) {
      _logger.info(packageVersion);
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }
    return exitCode;
  }
}
