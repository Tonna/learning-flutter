import 'dart:ui' as ui show Paragraph;

class TextRun {
  TextRun(this.start, this.end, this.paragraph);

  int start;
  int end;

  ui.Paragraph paragraph;
}