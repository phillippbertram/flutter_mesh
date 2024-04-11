import 'package:flutter/material.dart';
import 'package:flutter_mesh/src/ui/ui.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    this.action,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? image;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(maxWidth: 350),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (image != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: image!,
            ),
          DefaultTextStyle(
            style: textTheme.titleLarge!.copyWith(
              color: theme.appColors.accent.defaultColor,
            ),
            child: title,
          ),
          if (subtitle != null)
            Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: DefaultTextStyle(
                  style: textTheme.bodySmall!,
                  textAlign: TextAlign.center,
                  child: subtitle!,
                )),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: action!,
            ),
        ],
      ),
    );
  }
}
