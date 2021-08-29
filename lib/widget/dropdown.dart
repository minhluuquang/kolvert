import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kolvert/hook/useSuperTextEditingController.dart';
import 'package:kolvert/widget/text_field.dart';
import 'package:super_editor/super_editor.dart';

class ItemData<T> {
  final T? value;
  final String label;

  const ItemData({required this.value, required this.label});
}

class DDown<T> extends HookWidget {
  const DDown(this.data,
      {Key? key, this.selectedValue, required this.label, required this.onTab})
      : super(key: key);

  final T? selectedValue;
  final List<ItemData<T>> data;
  final String label;
  final Function(ItemData<T> v) onTab;

  @override
  Widget build(BuildContext context) {
    final _focusNode = useFocusNode();
    final _selectedValue = useState(selectedValue);
    final _textController = useSuperTextEditingController(
      text: data
          .firstWhere(
            (element) => element.value == selectedValue,
            orElse: () => ItemData(value: null, label: ''),
          )
          .label,
    );
    final _suggestText = useState('');

    OverlayEntry _createOverlayEntry() {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      var size = renderBox.size;
      var offset = renderBox.localToGlobal(Offset.zero);

      return OverlayEntry(
        builder: (context) {
          return Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 5.0,
            width: size.width,
            child: Material(
              elevation: 4.0,
              child: Popup<T>(
                selectedValue: _selectedValue,
                textController: _textController,
                focusNode: _focusNode,
                data: data,
                onTab: onTab,
              ),
            ),
          );
        },
      );
    }

    useEffect(() {
      late OverlayEntry _overlayEntry;

      _focusNode.addListener(() {
        if (_focusNode.hasFocus) {
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context)?.insert(_overlayEntry);
        } else {
          _overlayEntry.remove();
          _textController.text = AttributedText(
              text: data
                  .firstWhere(
                    (element) => element.value == _selectedValue.value,
                    orElse: () => ItemData(value: null, label: ''),
                  )
                  .label);
        }
      });

      _textController.addListener(() {
        _suggestText.value = _textController.text.text;
      });
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          label,
          style: TextStyle(
            color: Color.fromRGBO(169, 169, 169, 1),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        SizedBox(height: 8),
        EditTextField(
          focusNode: _focusNode,
          controller: _textController,
        ),
      ],
    );
  }
}

class Popup<T> extends StatefulWidget {
  const Popup({
    Key? key,
    required ValueNotifier selectedValue,
    required AttributedTextEditingController textController,
    required FocusNode focusNode,
    required this.data,
    required this.onTab,
  })  : _selectedValue = selectedValue,
        _textController = textController,
        _focusNode = focusNode,
        super(key: key);

  final List<ItemData<T>> data;
  final ValueNotifier _selectedValue;
  final AttributedTextEditingController _textController;
  final FocusNode _focusNode;
  final Function(ItemData<T> v) onTab;

  @override
  _PopupState createState() => _PopupState<T>();
}

class _PopupState<T> extends State<Popup<T>> {
  String _suggestText = '';

  void onListener() {
    setState(() {
      _suggestText = widget._textController.text.text;
    });
  }

  @override
  void initState() {
    super.initState();
    widget._textController.addListener(onListener);
  }

  @override
  void dispose() {
    widget._textController.removeListener(onListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestList = widget.data.where((element) =>
        element.label.toLowerCase().contains(_suggestText.toLowerCase()));

    return Container(
      constraints: BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(62, 62, 62, 1)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          ...suggestList
              .map((e) => DropDownItem<T>(
                    selectedValue: widget._selectedValue.value,
                    data: e,
                    onTab: (v) {
                      widget._selectedValue.value = v.value;
                      widget._textController.text =
                          AttributedText(text: v.label);
                      widget._focusNode.unfocus();
                      widget.onTab(v);
                    },
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class DropDownItem<T> extends HookWidget {
  DropDownItem({
    Key? key,
    this.selectedValue,
    required this.data,
    required this.onTab,
  }) : super(key: key);

  final Color _selectedColor = Color.fromRGBO(139, 142, 221, 0.5);
  final T? selectedValue;
  final ItemData<T> data;
  final Function(ItemData<T> v) onTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        hoverColor: _selectedColor,
        onTap: () {
          onTab(data);
        },
        child: Ink(
          color: selectedValue == data.value
              ? Color.fromRGBO(139, 142, 221, 1)
              : Color.fromRGBO(47, 47, 47, 1),
          child: Text(
            data.label,
            style: TextStyle(
              color: selectedValue == data.value
                  ? Colors.white
                  : Color.fromRGBO(169, 169, 169, 1),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
