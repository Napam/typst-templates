// ── Shared constants ────────────────────────────────────
// Colors
#let meta-color = luma(150)
#let foreground-color = luma(50)
#let link-color = rgb("#2563eb")
#let page-fill = rgb(255, 255, 255)

// Typography
#let body-font = "PT Sans"
#let body-size = 11pt
#let par-leading = 0.7em
#let par-spacing = 1.2em

// Heading sizes
#let title-size = 2em
#let h1-size = 1.3em
#let h2-size = 1.2em
#let h3-size = 1.1em

// Heading spacing (above ≈ 2× below)
#let h1-above = 0.8em
#let h1-below = 0.4em
#let h2-above = 0.6em
#let h2-below = 0.3em
#let h3-above = 0.4em
#let h3-below = 0.2em

// List spacing
#let list-above = 1.0em
#let list-below = 1.0em

// Layout
#let page-margin = 2.5cm

// Figures
#let figure-above = 0.4em
#let figure-below = 0.6em
#let figure-caption-gap = 0.8em
#let caption-size = 0.9em

// ── Header (internal) ───────────────────────────────────
// Renders a visual title block with optional byline.
// Called automatically by template-base when show-header is true.
#let _doc-header(title, author, date) = {
  set align(center + horizon)
  let formatted-date = if date == none { none } else if type(date) == datetime {
    date.display("[month repr:long] [day], [year]")
  } else {
    str(date)
  }

  // Title — semantic H1 with outlined:false so the template's body
  // heading show rules (which add vertical spacing) don't apply.
  {
    set text(size: title-size)
    heading(level: 1, outlined: false, bookmarked: false, title)
  }

  // Byline: author · date
  {
    let author = if author == "" { none } else { author }
    let parts = ()
    if author != none { parts.push(author) }
    if formatted-date != none { parts.push(formatted-date) }

    if parts.len() > 0 {
      v(1em)
      text(size: 1em, fill: meta-color, parts.join([ #sym.dot.c ]))
    }
  }
}

// ── Document template ───────────────────────────────────
#let template-base(
  title: "",
  author: "",
  date: none,
  keywords: (),
  show-title-page: false,
  page-fill: page-fill,
  doc,
) = {
  set document(
    title: title,
    author: author,
    keywords: keywords,
    date: if date != none { date } else { auto },
  )

  set page(
    fill: page-fill,
    paper: "presentation-16-9",
    margin: page-margin,
    numbering: "1",
  )
  // Bundled font: Atkinson Hyperlegible Next (via TYPST_FONT_PATHS)
  set text(
    size: body-size,
    font: body-font,
    lang: "en",
    fill: foreground-color,
  )
  set par(justify: true, leading: par-leading, spacing: par-spacing)

  // Headings (outlined: true excludes the doc-header title)
  show heading.where(level: 1, outlined: true): it => {
    set text(size: h1-size)
    v(h1-above)
    it
    v(h1-below)
  }
  show heading.where(level: 2): it => {
    set text(size: h2-size)
    v(h2-above)
    it
    v(h2-below)
  }
  show heading.where(level: 3): it => {
    set text(size: h3-size)
    v(h3-above)
    it
    v(h3-below)
  }

  // Wrap `it` in a `block(above:, below:)` rather than using
  // `set block(above:, below:)` inside the show body. The `set` form
  // does not reliably attach to the already-constructed list/enum
  // (notably `above:` is ignored for lists/enum placed inside grid
  // cells, where the element's own default spacing leaks through).
  // Wrapping the element makes both spacings honored everywhere.
  show list: it => block(above: list-above, below: list-below, it)
  show enum: it => block(above: list-above, below: list-below, it)

  // Links
  show link: set text(fill: link-color)

  // Figures
  set figure(gap: figure-caption-gap)
  show figure.caption: set text(size: caption-size)
  show figure: fig => {
    v(figure-above)
    fig
    v(figure-below)
  }

  if show-title-page {
    _doc-header(title, author, date)
  }

  doc
}
