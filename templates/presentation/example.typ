#import "template.typ": template-base

#show: template-base.with(
  title: "Template Style Guide",
  author: "Natsuki Subaru",
  date: datetime.today(),
  keywords: ("typst", "template", "example"),
  show-title-page: true,
)

#pagebreak()

= Testing page 1

- What does it really mean to test a page?
- What does it really mean to write Typst?

#grid(
  columns: (1fr, 1fr, 2fr),
  gutter: 2em
)[
  == Grid column 1
  Here is some column content!
  1. Enumerated point 1
  2. Enumerated point 2
  3. Enumerated point 3
][
  == Grid column 2
  Here is some more column content!
  - Point 1
  - Point 2
  - Point 3
][
  == Grid column 3
  Here is some more column content! This column is really long!
  - Point 1
  - Point 2
  - Point 3
]

#pagebreak()

= Testing page 2

- Why is page?
