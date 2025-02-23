import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:slidy/src/command/generate_command.dart';
import 'package:slidy/src/templates/templates.dart' as templates;
import 'package:slidy/src/utils/file_utils.dart';
import 'package:slidy/src/utils/output_utils.dart' as output;
import 'package:slidy/src/utils/utils.dart';

import 'package:slidy/src/modules/install.dart';

start(hasForce, completeStart) async {
  var dir = Directory("lib");
  if (dir.listSync().isNotEmpty) {
    if (hasForce) {
      output.msg("Removing lib folder");
      await dir.delete(recursive: true);
    } else {
      output.error("The lib folder must be empty");
      exit(1);
    }
  }

  var dirTest = Directory("test");
  if (dirTest.listSync().isNotEmpty) {
    if (hasForce) {
      output.msg("Removing test folder");
      await dirTest.delete(recursive: true);
    } else {
      output.error("The test folder must be empty");
      exit(1);
    }
  }

  output.msg("Starting a new project");

  var command =
      CommandRunner("slidy", "CLI package manager and template for Flutter.");
  command.addCommand(GenerateCommand());
  String package = await getNamePackage();

  createStaticFile(
      libPath('app_module.dart'), templates.startAppModule(package));

  //createStaticFile(libPath('app_bloc.dart'), templates.startAppBloc());

  if (completeStart) {
    createStaticFile(
        '${dir.path}/main.dart', templates.startMainComplete(package));

    createStaticFile(
        libPath('app_widget.dart'), templates.startAppWidgetComplete(package));

    createStaticFile(libPath('routes.dart'), templates.startRoutes(package));

    createStaticFile(
        libPath('shared/styles/theme_style.dart'), templates.startThemeStyle());

    createStaticFile(
        libPath('shared/locale/locales.dart'), templates.startLocales(package));

    createStaticFile(libPath('shared/locale/pt-BR_locale.dart'),
        templates.startPtBrLocale());

    createStaticFile(libPath('shared/locale/en-US_locale.dart'),
        templates.startEnUSLocale());

    await command.run(['generate', 'module', 'pages/login', '-c']);
    await command.run(['generate', 'module', 'pages/home', '-c']);

    await install(["flutter_localizations: sdk: flutter"], false,
        haveTwoLines: true);
  } else {
    createStaticFile('${dir.path}/main.dart', templates.startMain(package));

    createStaticFile(
        libPath('app_widget.dart'), templates.startAppWidget(package));

    await command.run(['generate', 'module', 'pages/home', '-c']);
  }

  await command.run(['generate', 'bloc', 'app']);

  await install(["bloc_pattern", "rxdart", "dio"], false);
  await install(["mockito"], true);

  output.msg("Project started! enjoy!");
}
