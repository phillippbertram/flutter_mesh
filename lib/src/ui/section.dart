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
              .copyWith(bottom: 12, top: 24),
          // child: const Divider(height: 1),
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
    Widget? title,
    required List<Widget> children,
  }) {
    return Section(
      header: title,
      child: Column(
        children: children,
      ),
    );
  }

  final Widget? header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   color: Theme.of(context).colorScheme.surface,
      //   borderRadius: BorderRadius.circular(8),
      // ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
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
      ),
    );
  }
}
