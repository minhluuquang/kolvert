import 'package:clipboard/clipboard.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:super_editor/super_editor.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'hook/useSuperTextEditingController.dart';
import 'widget/widget.dart';

late Map<String, Location> locations;

void main() async {
  initializeTimeZones();
  locations = timeZoneDatabase.locations;
  final first = locations.entries.first.value;
  final utcLoc =
      Location("UTC", first.transitionAt, first.transitionZone, first.zones);
  locations.addAll({"UTC": utcLoc});

  WidgetsFlutterBinding.ensureInitialized();
  await DesktopWindow.setMinWindowSize(Size(1000, 800));
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kolvert',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(41, 41, 41, 1),
        primaryColor: Color.fromRGBO(139, 142, 221, 1),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Color.fromRGBO(139, 142, 221, 1),
            ),
      ),
      home: Unfocuser(child: Shell()),
    );
  }
}

class Shell extends HookWidget {
  const Shell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _width = useState(280.0);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Sidebar(width: _width),
                Expanded(
                  child: ContentArea(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContentArea extends StatelessWidget {
  const ContentArea({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimeConverter();
  }
}

class TimeConverter extends HookWidget {
  TimeConverter({
    Key? key,
  }) : super(key: key);

  final location = locations["UTC"]!;

  @override
  Widget build(BuildContext context) {
    final time = useState(TZDateTime.now(location));
    final _epochController = useSuperTextEditingController();
    final _iso8601Controller = useSuperTextEditingController();

    useEffect(() {
      _epochController.addListener(() {
        if (_epochController.text.text != time.value.toString()) {
          time.value = TZDateTime.fromMillisecondsSinceEpoch(
              location, int.parse(_epochController.text.text) * 1000);
        }
      });

      _iso8601Controller.addListener(() {
        if (_iso8601Controller.text.text != time.value.toString()) {
          time.value = TZDateTime.parse(location, _iso8601Controller.text.text);
        }
      });
    }, []);

    useEffect(() {
      if (_epochController.text.text != time.value.toString()) {
        final seconds = time.value.millisecondsSinceEpoch ~/ 1000;
        _epochController.text = AttributedText(text: seconds.toString());
      }

      if (_iso8601Controller.text.text != time.value.toString()) {
        _iso8601Controller.text =
            AttributedText(text: time.value.toIso8601String());
      }
    }, [time.value]);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         onPrimary: Colors.white,
          //         textStyle: TextStyle(
          //           color: Colors.black,
          //           fontSize: 12,
          //         ),
          //       ),
          //       child: const Text('Date'),
          //       onPressed: () {
          //         showDatePicker(
          //             context: context,
          //             initialDate: time.value,
          //             firstDate: DateTime(0),
          //             lastDate: DateTime(10000));
          //       },
          //     ),
          //     SizedBox(width: 12),
          //     ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         onPrimary: Colors.white,
          //         textStyle: TextStyle(
          //           color: Colors.black,
          //           fontSize: 12,
          //         ),
          //       ),
          //       child: const Text('Time'),
          //       onPressed: () {
          //         showTimePicker(
          //             initialEntryMode: TimePickerEntryMode.input,
          //             context: context,
          //             initialTime: TimeOfDay.fromDateTime(time.value));
          //       },
          //     ),
          //   ],
          // ),
          CopyTextField(controller: _epochController, label: "Unix timestamp"),
          Row(
            children: [
              CopyTextField(controller: _iso8601Controller, label: "ISO 8601"),
              SizedBox(width: 12),
              Container(
                width: 200,
                child: DDown<Location>(
                  locations.entries
                      .map((e) => ItemData(value: e.value, label: e.value.name))
                      .toList(),
                  label: "Timezone",
                  selectedValue: locations["UTC"],
                  onTab: (v) {
                    if (v.value != null) {
                      time.value = TZDateTime.from(time.value, v.value!);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CopyTextField extends StatelessWidget {
  const CopyTextField({
    Key? key,
    required AttributedTextEditingController controller,
    required this.label,
  })  : controller = controller,
        super(key: key);

  final AttributedTextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
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
          Row(
            children: [
              Container(
                width: 220,
                child: EditTextField(controller: controller),
              ),
              SizedBox(width: 4),
              ActionIcon(
                icon: Icon(
                  Icons.copy,
                  size: 12,
                  color: Colors.white,
                ),
                onClick: () {
                  FlutterClipboard.copy(controller.text.text);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({
    Key? key,
    required ValueNotifier<double> width,
  })  : _width = width,
        super(key: key);

  final ValueNotifier<double> _width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width.value,
      constraints: BoxConstraints(
        minWidth: 280,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(62, 62, 62, 1)),
        color: Color.fromRGBO(44, 44, 44, 1),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: Colors.white, size: 16),
                      SizedBox(width: 12),
                      Text(
                        "Unix Timestamp",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                _width.value = _width.value + details.delta.dx;
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: Container(
                  width: 5,
                ),
              ),
            ),
            top: 0,
            bottom: 0,
            right: 0,
          )
        ],
      ),
    );
  }
}

class Unfocuser extends StatefulWidget {
  final Widget? child;
  final double minScrollDistance;

  const Unfocuser({
    Key? key,
    this.child,
    this.minScrollDistance = 10.0,
  }) : super(key: key);

  @override
  _UnfocuserState createState() => _UnfocuserState();
}

class _UnfocuserState extends State<Unfocuser> {
  RenderBox? _lastRenderBox;
  Offset? _touchStartPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        _touchStartPosition = e.position;
      },
      onPointerUp: (e) {
        var touchStopPosition = e.position;
        if (widget.minScrollDistance > 0.0 && _touchStartPosition != null) {
          var difference = _touchStartPosition! - touchStopPosition;
          _touchStartPosition = null;
          if (difference.distance > widget.minScrollDistance) {
            return;
          }
        }

        var rb = context.findRenderObject() as RenderBox;
        var result = BoxHitTestResult();
        rb.hitTest(result, position: touchStopPosition);

        if (result.path.any(
            (entry) => entry.target.runtimeType == IgnoreUnfocuserRenderBox)) {
          return;
        }
        var isEditable = result.path.any((entry) =>
            entry.target.runtimeType == RenderEditable ||
            entry.target.runtimeType == RenderParagraph ||
            entry.target.runtimeType == ForceUnfocuserRenderBox);

        var currentFocus = FocusScope.of(context);
        if (!isEditable) {
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
            _lastRenderBox = null;
          }
        } else {
          for (var entry in result.path) {
            var isEditable = entry.target.runtimeType == RenderEditable ||
                entry.target.runtimeType == RenderParagraph ||
                entry.target.runtimeType == ForceUnfocuserRenderBox;

            if (isEditable) {
              var renderBox = (entry.target as RenderBox);
              if (_lastRenderBox != renderBox) {
                _lastRenderBox = renderBox;
                setState(() {});
              }
            }
          }
        }
      },
      child: widget.child,
    );
  }
}

class IgnoreUnfocuser extends SingleChildRenderObjectWidget {
  final Widget child;

  IgnoreUnfocuser({required this.child}) : super(child: child);

  @override
  IgnoreUnfocuserRenderBox createRenderObject(BuildContext context) {
    return IgnoreUnfocuserRenderBox();
  }
}

class ForceUnfocuser extends SingleChildRenderObjectWidget {
  final Widget child;

  ForceUnfocuser({required this.child}) : super(child: child);

  @override
  ForceUnfocuserRenderBox createRenderObject(BuildContext context) {
    return ForceUnfocuserRenderBox();
  }
}

class IgnoreUnfocuserRenderBox extends RenderPointerListener {}

class ForceUnfocuserRenderBox extends RenderPointerListener {}
