import 'package:flutter/material.dart';

import 'intro_policy.dart';

/// Công tắc "Hiệu ứng mở app" cho màn Cài đặt. Chỉ thêm một dòng, không đổi bố cục khác.
class IntroSettingTile extends StatefulWidget {
  IntroSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    SharedPrefsIntroPolicy? policy,
  }) : policy = policy ?? SharedPrefsIntroPolicy();

  final String title;
  final String? subtitle;
  final SharedPrefsIntroPolicy policy;

  @override
  State<IntroSettingTile> createState() => _IntroSettingTileState();
}

class _IntroSettingTileState extends State<IntroSettingTile> {
  bool _on = true;

  @override
  void initState() {
    super.initState();
    widget.policy.isEnabled().then((v) {
      if (mounted) setState(() => _on = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.title),
      subtitle: widget.subtitle == null ? null : Text(widget.subtitle!),
      value: _on,
      onChanged: (v) {
        setState(() => _on = v);
        widget.policy.setEnabled(v);
      },
    );
  }
}
