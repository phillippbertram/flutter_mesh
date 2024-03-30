import 'package:flutter/material.dart';

class SectionedListView extends StatelessWidget {
  const SectionedListView({
    super.key,
    required this.children,
  });

  final List<Section> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: children.length,
      separatorBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16)
              .copyWith(bottom: 18, top: 8),
          child: const Divider(height: 1),
        );
      },
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    this.header,
    required this.child,
  });

  factory Section.children({
    Widget? header,
    required List<Widget> children,
  }) {
    return Section(
      header: header,
      child: Column(
        children: children,
      ),
    );
  }

  final Widget? header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          DefaultTextStyle(
            style: Theme.of(context).textTheme.titleSmall!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16)
                  .copyWith(bottom: 8),
              child: header,
            ),
          ),
        child,
      ],
    );
  }
}
