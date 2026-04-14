#import "template.typ": template-base

#show: template-base.with(
  title: "Template Style Guide",
  author: "Jane Doe",
  date: datetime.today(),
  keywords: ("typst", "template", "example"),
  show-header: true,
)

== Introduction

This document demonstrates the styling capabilities provided by the document template. It covers headings, inline
formatting, lists, blockquotes, code, tables, and figures. #lorem(20)

== Inline Formatting

The template uses *Atkinson Hyperlegible Next* for body text at 11pt with justified paragraphs. You can use *bold text*
for emphasis, _italic text_ for titles or asides, and `inline code` for technical references like `template-base()`.
Combine them freely: *_bold italic_* works too.

#lorem(30)

== Lists

=== Bullet List

Key features of this template:

- Clean, readable typography with a humanist sans-serif font
- Justified paragraph alignment for a polished look
- Automatic page numbering in the footer (_current / total_)
- Generous 2.5cm margins on all sides

=== Numbered List

Steps to use this template:

+ Import `template.typ` into your document
+ Call `template-base` with `title`, `author`, and `keywords`
+ Write your content using standard Typst markup
+ Compile with `typst compile example.typ`

== Blockquote

Use a blockquote to highlight a key passage or citation:

#quote(block: true, attribution: [Alan Perlis])[
  A language that doesn't affect the way you think about programming is not worth knowing.
]

#lorem(15)

== Code Block

Below is a snippet showing how this template is initialised:

```typst
#import "template.typ": template-base

#show: template-base.with(
  title: "My Document",
  author: "Your Name",
  date: datetime.today(),
  keywords: ("typst", "example"),
  show-header: true,
)

= First Heading
#lorem(40)
```

== Table

A comparison of page layout parameters:

#figure(
  table(
    columns: 3,
    align: (left, center, center),
    table.header[*Parameter*][*Value*][*Unit*],
    [Page margin], [2.5], [cm],
    [Body font size], [11], [pt],
    [Language], [en], [--],
    [Justification], [true], [--],
  ),
  caption: [Template page layout defaults.],
)

== Figure Placeholder

#figure(
  rect(width: 60%, height: 4cm, stroke: 0.5pt + luma(180))[
    #align(center + horizon, text(fill: luma(150))[_Image placeholder_])
  ],
  caption: [An example figure slot for diagrams or images.],
)

= Conclusion

#lorem(25)

This example covers headings at three levels, inline styles (*bold*, _italic_, `code`), ordered and unordered lists, a
blockquote, a code block, a table, and a figure placeholder --- all rendered with the template's default styling.
