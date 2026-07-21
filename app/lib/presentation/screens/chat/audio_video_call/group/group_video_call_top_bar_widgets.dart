part of '../group_video_call_screen.dart';

class _MeasuredTopBar extends StatelessWidget {
  const _MeasuredTopBar({
    required this.onHeightChanged,
    required this.contactId,
    required this.onMinimize,
    required this.onSwitchCamera,
    required this.showSwitchCamera,
  });

  final ValueChanged<double> onHeightChanged;
  final String contactId;
  final VoidCallback onMinimize;
  final VoidCallback onSwitchCamera;
  final bool showSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return _MeasuredWidgetSize(
      onHeightChanged: onHeightChanged,
      child: SafeArea(
        bottom: false,
        child: _GroupVideoTopBar(
          contactId: contactId,
          onMinimize: onMinimize,
          onSwitchCamera: onSwitchCamera,
          showSwitchCamera: showSwitchCamera,
        ),
      ),
    );
  }
}

/// Reports its child's rendered height whenever it changes during layout.
class _MeasuredWidgetSize extends SingleChildRenderObjectWidget {
  const _MeasuredWidgetSize({
    required this.onHeightChanged,
    required Widget super.child,
  });

  final ValueChanged<double> onHeightChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasuredHeight(onHeightChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasuredHeight renderObject,
  ) {
    renderObject.onHeightChanged = onHeightChanged;
  }
}

class _RenderMeasuredHeight extends RenderProxyBox {
  _RenderMeasuredHeight(this.onHeightChanged);

  ValueChanged<double> onHeightChanged;
  double? _lastHeight;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _lastHeight) return;

    _lastHeight = height;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onHeightChanged(height);
    });
  }
}
