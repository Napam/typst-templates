// ── Shared constants ────────────────────────────────────
// Colors
#let meta-color = luma(150)
#let foreground-color = luma(50)
#let link-color = rgb("#2563eb")

// Typography
#let body-font = "Atkinson Hyperlegible Next"
#let body-size = 11pt
#let par-leading = 0.7em
#let par-spacing = 1.2em

// Heading sizes
#let h1-size = 1.4em
#let h2-size = 1.2em
#let h3-size = 1.1em

// Heading spacing (above ≈ 2× below)
#let h1-above = 0.8em
#let h1-below = 0.4em
#let h2-above = 0.6em
#let h2-below = 0.3em
#let h3-above = 0.4em
#let h3-below = 0.2em

// Layout
#let page-margin = 2.5cm

// Figures
#let figure-gap = 0.8em
#let caption-size = 0.9em

// ── Header (internal) ───────────────────────────────────
// Renders a visual title block with optional byline.
// Called automatically by template-base when show-header is true.
#let _doc-header(title, author, date) = {
  let formatted-date = if date == none { none } else if type(date) == datetime {
    date.display("[month repr:long] [day], [year]")
  } else {
    str(date)
  }

  // Title — semantic H1 with outlined:false so the template's body
  // heading show rules (which add vertical spacing) don't apply.
  {
    set text(size: h1-size)
    heading(level: 1, outlined: false, bookmarked: false, title)
  }

  // Byline: author · date
  {
    let author = if author == "" { none } else { author }
    let parts = ()
    if author != none { parts.push(author) }
    if formatted-date != none { parts.push(formatted-date) }

    if parts.len() > 0 {
      v(0.2em)
      text(size: 0.85em, fill: meta-color, parts.join([ #sym.dot.c ]))
    }
  }
}

// ── Document template ───────────────────────────────────
#let template-base(title: "", author: "", date: none, keywords: (), show-header: false, doc) = {
  set document(
    title: title,
    author: author,
    keywords: keywords,
    date: if date != none { date } else { auto },
  )

  set page(
    margin: page-margin,
    footer: context {
      let current = counter(page).get().first()
      let total = counter(page).final().first()
      set text(size: 0.85em, fill: meta-color)
      align(center, [#current / #total])
    },
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

  // Links
  show link: set text(fill: link-color)

  // Figures
  set figure(gap: figure-gap)
  show figure.caption: set text(size: caption-size)

  if show-header {
    _doc-header(title, author, date)
  }

  doc
}
