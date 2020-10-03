import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/token.dart';

class UnfmtOptions {
  String baseCommit;
  String workingDirectory;
}

Future<ProcessResult> tryGit(UnfmtOptions options, List<String> args) =>
  Process.run('git', args, workingDirectory: options.workingDirectory);

Future<String> runGit(UnfmtOptions options, List<String> args) async {
  var result = await tryGit(options, args);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    stderr.writeln('Error: git failed with exit code ${result.stderr}.');
    exit(1);
  }
  return result.stdout;
}

Future<bool> checkUncommitedChanges(UnfmtOptions options) async {
  await runGit(options, ['update-index', '--refresh']);
  var result = await tryGit(options, ['diff-index', '--quiet', 'HEAD', '--']);
  return result.exitCode != 0;
}

Future<String> getFileAtCommit(UnfmtOptions options, String commit, String file) {
  return runGit(options, ['show', '$commit:$file']);
}

Future<List<String>> getModifiedFiles(UnfmtOptions options, String commit) async {
  return (await runGit(options, ['diff', '--name-only', commit, 'HEAD'])).split('\n');
}

List<Token> tokenize(String content) {
  var result = parseString(
    content: content,
    throwIfDiagnostics: false,
  );
  var tokens = <Token>[];
  var token = result.unit.beginToken;
  while (!token.isEof) {
    tokens.add(token);
    token = token.next;
  }
  return tokens;
}

String unformat(String input, String base) {
  var inputTokens = tokenize(input);
  var baseTokens = tokenize(base);
}

Future<void> unformatRepo(UnfmtOptions options) async {
  var modifiedFiles = await getModifiedFiles(options, options.baseCommit);

}