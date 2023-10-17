import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/utils.dart';
import 'package:html/dom.dart' as dom;

/// Handles rendering of text nodes and <br> tags.
class TextBuiltIn extends HtmlExtension {
  const TextBuiltIn();

  @override
  bool matches(ExtensionContext context) {
    return supportedTags.contains(context.elementName) ||
        context.node is dom.Text;
  }

  @override
  Set<String> get supportedTags => {
        "br",
      };

  @override
  StyledElement prepare(
      ExtensionContext context, List<StyledElement> children) {
    if (context.elementName == "br") {
      return LinebreakContentElement(
        style: Style(whiteSpace: WhiteSpace.pre),
        node: context.node,
      );
    }

    if (context.node is dom.Text) {
      return TextContentElement(
        text: context.node.text,
        style: Style(),
        element: context.node.parent,
        node: context.node,
      );
    }

    return EmptyContentElement(node: context.node);
  }

  static final _whitespacesRegex = RegExp(r'[^\s]*\s*');

  @override
  InlineSpan build(ExtensionContext context) {
    if (context.styledElement is LinebreakContentElement) {
      return TextSpan(
        text: '\n',
        style: context.styledElement!.style.generateTextStyle(),
      );
    }

    final element = context.styledElement! as TextContentElement;
    final text = element.text!.transformed(element.style.textTransform);

    if (context.parser.onTapNode == null) {
      return TextSpan(
        style: element.style.generateTextStyle(),
        text: text,
      );
    }

    final words = _whitespacesRegex.allMatches(text!).map((e) => e[0]);
    final wordsTrimmed = words.map((e) => e!.trim()).toList();

    return TextSpan(
      style: element.style.generateTextStyle(),
      children: words.mapIndexed((index, word) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            context.parser.onTapNode?.call(
              context.node,
              index,
              wordsTrimmed,
            );
          };

        return TextSpan(
          text: word,
          recognizer: recognizer,
        );
      }).toList(),
    );
  }
}
