import 'package:flutter/material.dart';
import 'package:kolvert/main.dart';
import 'package:super_editor/super_editor.dart';

class EditTextField extends StatelessWidget {
  const EditTextField({
    Key? key,
    FocusNode? focusNode,
    AttributedTextEditingController? controller,
  })  : _controller = controller,
        _focusNode = focusNode,
        super(key: key);

  final AttributedTextEditingController? _controller;
  final FocusNode? _focusNode;

  @override
  Widget build(BuildContext context) {
    return ForceUnfocuser(
      child: SuperTextField(
        focusNode: _focusNode,
        textController: _controller,
        textCaretFactory:
            TextCaretFactory(color: Color.fromRGBO(169, 169, 169, 1)),
        decorationBuilder: (context, child) {
          return MouseRegion(
            cursor: SystemMouseCursors.text,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(62, 62, 62, 1)),
                color: Color.fromRGBO(47, 47, 47, 1),
              ),
              child: child,
            ),
          );
        },
        textStyleBuilder: (attributions) {
          return TextStyle(
            color: Color.fromRGBO(169, 169, 169, 1),
            fontSize: 13,
            height: 1.4,
          );
        },
      ),
    );
  }
}
