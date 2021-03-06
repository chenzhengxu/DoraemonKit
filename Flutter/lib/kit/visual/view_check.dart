import 'dart:convert';
import 'dart:math';

import 'package:dokit/dokit.dart';
import 'package:dokit/kit/visual/visual.dart';
import 'package:dokit/ui/dokit_app.dart';
import 'package:dokit/ui/dokit_btn.dart';
import 'package:dokit/widget/dash_decoration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ViewCheckerKit extends VisualKit {
  ViewCheckerKit._privateConstructor() {
    final ViewCheckerWidget widget = ViewCheckerWidget();

    focusEntry = OverlayEntry(builder: (BuildContext context) {
      return widget;
    });

    rectEntry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        left: area.left,
        top: area.top,
        child: RectWidget(),
      );
    });
    infoEntry = OverlayEntry(builder: (BuildContext context) {
      return InfoWidget();
    });
    hasShow = false;
  }

  bool hasShow;
  OverlayEntry focusEntry;
  OverlayEntry rectEntry;
  OverlayEntry infoEntry;

  Rect area = const Rect.fromLTWH(0, 0, 0, 0);
  String info = '移动屏幕中心焦点聚焦控件，查看控件信息';

  static final ViewCheckerKit _instance = ViewCheckerKit._privateConstructor();

  static ViewCheckerKit get instance => _instance;

  static void show(BuildContext context, OverlayEntry entrance) {
    _instance._show(context, entrance);
  }

  void _show(BuildContext context, OverlayEntry entrance) {
    if (hasShow) {
      return;
    }
    hasShow = true;
    doKitOverlayKey.currentState.insert(focusEntry, below: entrance);
    doKitOverlayKey.currentState.insert(infoEntry, below: focusEntry);
    doKitOverlayKey.currentState.insert(rectEntry, below: infoEntry);
  }

  static bool hide(BuildContext context) {
    return _instance._hide(context);
  }

  bool _hide(BuildContext context) {
    if (!hasShow) {
      return false;
    }
    hasShow = false;
    focusEntry.remove();
    rectEntry.remove();
    infoEntry.remove();
    area = const Rect.fromLTWH(0, 0, 0, 0);
    info = '移动屏幕中心焦点聚焦控件，查看控件信息';
    return true;
  }

  @override
  String getIcon() {
    return 'images/dk_view_check.png';
  }

  @override
  String getKitName() {
    return VisualKitName.KIT_VIEW_CHECK;
  }

  @override
  void tabAction() {
    final DoKitBtnState state = DoKitBtn.doKitBtnKey.currentState;
    state.closeDebugPage();
    show(DoKitBtn.doKitBtnKey.currentContext, state.owner);
  }
}

class RectWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RectWidgetState();
  }
}

class _RectWidgetState extends State<RectWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: ViewCheckerKit._instance.area.width,
        height: ViewCheckerKit._instance.area.height,
        decoration: const DashedDecoration(
            dashedColor: Color(0xffCC3000),
            color: Color(0x183ca0e6),
            borderRadius: BorderRadius.all(Radius.circular(1))));
  }
}

class InfoWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _InfoWidgetState();
  }
}

class _InfoWidgetState extends State<InfoWidget> {
  double top;

  @override
  Widget build(BuildContext context) {
    top ??= MediaQuery.of(context).size.height - 250;
    return Positioned(
        left: 20,
        top: top,
        child: Draggable<dynamic>(
            child: getInfoView(),
            feedback: getInfoView(),
            childWhenDragging: Container(),
            onDragEnd: (DraggableDetails detail) {
              final Offset offset = detail.offset;
              setState(() {
                top = offset.dy;
                if (top < 0) {
                  top = 0;
                }
              });
            },
            onDraggableCanceled: (Velocity velocity, Offset offset) {}));
  }

  Widget getInfoView() {
    final Size size = MediaQuery.of(context).size;
    return Container(
        width: size.width - 40,
        padding: const EdgeInsets.only(left: 10, right: 16, top: 9, bottom: 24),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffeeeeee), width: 0.5),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            color: Colors.white),
        alignment: Alignment.centerLeft,
        child: Column(
          children: <Widget>[
            Container(
                alignment: Alignment.centerRight,
                width: size.width - 40,
                child: GestureDetector(
                  child: Image.asset('images/dokit_ic_close.png',
                      package: DoKit.PACKAGE_NAME, height: 22, width: 22),
                  onTap: () {
                    ViewCheckerKit.hide(context);
                  },
                )),
            Text(ViewCheckerKit._instance.info,
                style: const TextStyle(
                    color: Color(0xff333333),
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                    fontSize: 12))
          ],
        ));
  }
}

// ignore: must_be_immutable
class ViewCheckerWidget extends StatefulWidget {
  OverlayEntry owner;
  OverlayEntry debugPage;
  bool showDebugPage = false;

  @override
  _ViewCheckerWidgetState createState() => _ViewCheckerWidgetState();
}

class _ViewCheckerWidgetState extends State<ViewCheckerWidget> {
  final double diameter = 40;
  Offset offsetA; //按钮的初始位置

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    if (offsetA == null) {
      final double x = (width - diameter) / 2;
      final double y = (height - diameter) / 2;
      offsetA = Offset(x, y);
    }
    return Positioned(
        left: offsetA.dx,
        top: offsetA.dy,
        child: Draggable<dynamic>(
            child: FocusWidget(diameter),
            feedback: FocusWidget(diameter),
            childWhenDragging: Container(),
            onDragEnd: (DraggableDetails detail) {
              final Offset offset = detail.offset;
              setState(() {
                double x = offset.dx;
                double y = offset.dy;
                if (x < 0) {
                  x = 0;
                }
                if (x > width - diameter) {
                  x = width - diameter;
                }
                if (y < 0) {
                  y = 0;
                }
                if (y > height - diameter) {
                  y = height - diameter;
                }
                offsetA = Offset(x, y);
                findFocusView();
              });
            },
            onDraggableCanceled: (Velocity velocity, Offset offset) {}));
  }

  // 找到当前聚焦控件的方式：
  // 1.从根节点开始向下遍历，找到当前处于顶部的控件，记录这个控件的路由信息，作为当前页面路由
  // 2.遍历过程中，记录所有和焦点悬浮窗有交集控件。
  // 3.遍历上面记录的控件，获取控件所在路由信息和当前页面路由一致的控件，再计算(焦点悬浮窗和在控件重叠区)/(组件面积)，占比更高者作为当前聚焦组件
  // 4.debug模式下，将聚焦控件设置为选中控件，可以获取到源码信息
  void findFocusView() {
    final RenderObjectElement element = resolveTree();
    if (element != null) {
      final Offset offset =
          (element.renderObject as RenderBox).localToGlobal(Offset.zero);
      ViewCheckerKit._instance.area = Rect.fromLTWH(
          offset.dx, offset.dy, element.size.width, element.size.height);
      ViewCheckerKit._instance.info = toInfoString(element);
    } else {
      ViewCheckerKit._instance.area = const Rect.fromLTWH(0, 0, 0, 0);
    }
  }

  String toInfoString(RenderObjectElement element) {
    String fileLocation;
    int line;
    int column;
    if (kDebugMode) {
      WidgetInspectorService.instance.selection.current = element.renderObject;
      final String nodeDesc =
          WidgetInspectorService.instance.getSelectedSummaryWidget(null, null);
      if (nodeDesc != null) {
        final Map<String, dynamic> map =
            json.decode(nodeDesc) as Map<String, dynamic>;
        if (map != null) {
          final Map<String, dynamic> location =
              map['creationLocation'] as Map<String, dynamic>;
          if (location != null) {
            fileLocation = location['file'] as String;
            line = location['line'] as int;
            column = location['column'] as int;
          }
        }
      }
    }

    final Offset offset =
        (element.renderObject as RenderBox).localToGlobal(Offset.zero);
    String info = '控件名称: ${element.widget.toString()}\n'
        '控件位置: 左${offset.dx} 上${offset.dy} 宽${element.size.width} 高${element.size.height}';
    if (fileLocation != null) {
      info += '\n源码位置: $fileLocation' '【行 $line 列 $column】';
    }
    return info;
  }

  RenderObjectElement resolveTree() {
    Element currentPage;
    final List<RenderObjectElement> inBounds = <RenderObjectElement>[];
    final Rect focus =
        Rect.fromLTWH(offsetA.dx, offsetA.dy, diameter, diameter);
    // 记录根路由，用以过滤overlay
    final ModalRoute<dynamic> rootRoute =
        ModalRoute.of<dynamic>(DoKitApp.appKey.currentContext);

    void filter(Element element) {
      // 兼容IOS，IOS的MaterialApp会在Navigator后再插入一个PositionedDirectional控件，用以处理右滑关闭手势，遍历的时候跳过该控件
      // ignore:
      if (element.widget is! PositionedDirectional) {
        if (element is RenderObjectElement &&
            element.renderObject is RenderBox) {
          final ModalRoute<dynamic> route = ModalRoute.of<dynamic>(element);
          // overlay不包含route信息，通过ModalRoute.of会获取到当前所在materialapp在其父节点内的route,此处对overlay做过滤。只能过滤掉直接添加在根MaterialApp的overlay,
          // 并且该overlay的子widget不能包含materialApp或navigator
          if (route != null && route != rootRoute) {
            currentPage = element;
            final RenderBox renderBox = element.renderObject as RenderBox;
            if (renderBox.hasSize && renderBox.attached) {
              final Offset offset = renderBox.localToGlobal(Offset.zero);
              if (isOverlap(
                  focus,
                  Rect.fromLTWH(offset.dx, offset.dy, element.size.width,
                      element.size.height))) {
                inBounds.add(element);
              }
            }
          }
        }
        element.visitChildren(filter);
      }
    }

    DoKitApp.appKey.currentContext.visitChildElements(filter);
    RenderObjectElement topElement;
    final ModalRoute<dynamic> route =
        currentPage != null ? ModalRoute.of<dynamic>(currentPage) : null;
    for (final RenderObjectElement element in inBounds) {
      if ((route == null || ModalRoute.of(element) == route) &&
          checkSelected(topElement, element)) {
        topElement = element;
      }
    }
    return topElement;
  }

  bool checkSelected(RenderObjectElement last, RenderObjectElement current) {
    if (last == null) {
      return true;
    } else {
      return getOverlayPercent(current) > getOverlayPercent(last) &&
          current.depth >= last.depth;
    }
  }

  double getOverlayPercent(RenderObjectElement element) {
    final double size = element.size.width * element.size.height;
    final Offset offset =
        (element.renderObject as RenderBox).localToGlobal(Offset.zero);
    final Rect rect = Rect.fromLTWH(
        offset.dx, offset.dy, element.size.width, element.size.height);
    final double xc1 = max(rect.left, offsetA.dx);
    final double yc1 = max(rect.top, offsetA.dy);
    final double xc2 = min(rect.right, offsetA.dx + diameter);
    final double yc2 = min(rect.bottom, offsetA.dy + diameter);
    return ((xc2 - xc1) * (yc2 - yc1)) / size;
  }

  bool isOverlap(Rect rc1, Rect rc2) {
    return rc1.left + rc1.width > rc2.left &&
        rc2.left + rc2.width > rc1.left &&
        rc1.top + rc1.height > rc2.top &&
        rc2.top + rc2.height > rc1.top;
  }
}

class FocusWidget extends StatelessWidget {
  const FocusWidget(this.diameter, {Key key}) : super(key: key);

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xff337CC4), width: 1),
        color: const Color(0x00000000),
      ),
      alignment: Alignment.center,
      child: Container(
        width: diameter * 1 / 3,
        height: diameter * 1 / 3,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x30CC3A4B),
        ),
        alignment: Alignment.center,
        child: Container(
          width: diameter * 1 / 6,
          height: diameter * 1 / 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffCC3A4B),
          ),
        ),
      ),
    );
  }
}
