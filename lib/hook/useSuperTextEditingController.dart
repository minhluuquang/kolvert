import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:super_editor/super_editor.dart';

const useSuperTextEditingController = _SuperTextEditingControllerHookCreator();

class _SuperTextEditingControllerHookCreator {
  const _SuperTextEditingControllerHookCreator();

  AttributedTextEditingController call({String? text, List<Object?>? keys}) {
    return use(_SuperTextEditingControllerHook(text, keys));
  }
}

class _SuperTextEditingControllerHook
    extends Hook<AttributedTextEditingController> {
  const _SuperTextEditingControllerHook(
    this.initialText, [
    List<Object?>? keys,
  ]) : super(keys: keys);

  final String? initialText;

  @override
  _SuperTextEditingControllerHookState createState() {
    return _SuperTextEditingControllerHookState();
  }
}

class _SuperTextEditingControllerHookState extends HookState<
    AttributedTextEditingController, _SuperTextEditingControllerHook> {
  late final _controller = AttributedTextEditingController(
      text: AttributedText(text: hook.initialText ?? ''));

  @override
  AttributedTextEditingController build(BuildContext context) => _controller;

  @override
  void dispose() => _controller.dispose();

  @override
  String get debugLabel => 'useTextEditingController';
}
