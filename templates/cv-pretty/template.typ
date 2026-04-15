// =============================================================================
// Designed (human-friendly) CV layout — multi-column grids, profile image,
// inline SVG icons, styled skill tag boxes. Optimized for visual appeal.
//
// Font: PT Sans (bundled in ./fonts via TYPST_FONT_PATHS)
// Icons: ./icons/*.svg (phone, email, location, github, linkedin, website, calendar)
// =============================================================================


#let body-size = 10pt
#let label-size = 11pt
#let tag-size = 9pt
#let text-color = luma(40)
#let meta-color = luma(100)
#let tag-fill = luma(240)
#let entry-columns = (3fr, 9fr)
#let entry-gutter = 1.5em
#let entry-spacing = 1.85em

#let tag(name) = box(
  fill: tag-fill,
  inset: (x: 4pt, y: 3pt),
  outset: (y: 1.5pt),
  radius: 2pt,
  text(size: tag-size, name),
)

#let skill-tags(items) = {
  set par(leading: 0.55em)
  items.map(item => tag(item)).join(h(3pt))
}

#let skill-category(
  name: "",
  skills: (),
) = {
  block(below: 1.5em, breakable: false, grid(
    columns: (1fr, 3fr),
    column-gutter: 1.5em,
    {
      set par(justify: false)
      text(size: body-size, weight: "bold", name)
    },
    skill-tags(skills),
  ))
}

// ---- Icons ----

#let icon-height = 12pt

#let icon(name, height: icon-height, shift: none, fill: none) = {
  let s = if shift != none { shift } else { (height - 0.7em) / 2 }
  // Hack to change the fill color of an SVG icon: read the file as text, replace the currentColor
  let img = if fill != none {
    let svg = read("icons/" + name + ".svg")
    let svg = svg.replace("currentColor", fill.to-hex())
    image(bytes(svg), format: "svg")
  } else {
    image("icons/" + name + ".svg")
  }
  box(
    baseline: s,
    height: height,
    img,
  )
  h(3pt)
}

// Shared base for education and work experience entries.
// 2-column grid: metadata left, bold title + description right.
// Mirrors the selected-project-entry pattern so work-experience and education
// entries share the same visual rhythm.
#let _entry(
  title: "",
  organization: "",
  dates: "",
  location: "",
  description: [],
) = {
  block(below: entry-spacing, breakable: true, grid(
    columns: entry-columns,
    gutter: entry-gutter,
    {
      set par(justify: false)
      stack(
        spacing: 6.0pt,
        text(size: label-size, weight: "semibold", organization),
        v(0.75em),
        text(size: body-size, fill: meta-color, dates),
        if location != "" {
          text(size: body-size, fill: meta-color, {
            icon("location", height: 9pt, fill: meta-color)
            location
          })
        },
      )
    },
    {
      text(size: label-size, weight: "bold", title)
      v(0pt)
      text(size: body-size, description)
    },
  ))
}

#let education-entry(
  degree: "",
  institution: "",
  dates: "",
  location: "",
  description: [],
) = _entry(
  title: degree,
  organization: institution,
  dates: dates,
  location: location,
  description: description,
)

#let work-experience-entry(
  title: "",
  company: "",
  dates: "",
  location: "",
  description: [],
) = _entry(
  title: title,
  organization: company,
  dates: dates,
  location: location,
  description: description,
)

// Selected-project entries reuse _entry, appending skill tags to the description.
#let selected-project-entry(
  name: "",
  place: "",
  dates: "",
  description: [],
  skills: (),
  skills-label: "Technologies",
) = {
  let desc = {
    description
    if skills.len() > 0 {
      v(4pt)
      text(weight: "semibold", fill: meta-color, skills-label + ": ")
      skill-tags(skills)
    }
  }
  _entry(
    title: name,
    organization: place,
    dates: dates,
    location: "",
    description: desc,
  )
}

#let reference-entry(
  name: "",
  phone: "",
  email: "",
  description: [],
  phone-label: "Phone",
  email-label: "Email",
) = {
  block(below: entry-spacing, breakable: false, grid(
    columns: entry-columns,
    gutter: entry-gutter,
    {
      set par(justify: false)
      stack(
        spacing: 6.0pt,
        text(size: label-size, weight: "semibold", name),
        if phone != "" {
          text(size: body-size, fill: meta-color, {
            icon("phone", height: 9pt, fill: meta-color)
            phone
          })
        },
        if email != "" {
          text(size: body-size, fill: meta-color, {
            icon("email", height: 9pt, fill: meta-color)
            email
          })
        },
      )
    },
    text(size: body-size, description),
  ))
}

// 2-column grid (7fr, 4fr): name heading, subtitle, contacts with icons,
// summary heading + intro on left; profile image on right.
#let header(
  name: "",
  subtitle: [],
  contacts: (),
  introduction: [],
  summary-heading: "",
  profile-image: none,
) = {
  let left-content = [
    #heading(depth: 1, name)
    #v(-0.75em)
    #text(weight: "medium", size: 12pt, subtitle)

    #(
      contacts
        .map(c => box[
          #icon(c.icon-name)#if "url" in c {
            link(c.url, c.display)
          } else {
            c.display
          }
        ])
        .join(h(12pt))
    )

    = #summary-heading

    #introduction
  ]

  if profile-image != none {
    grid(
      left-content,
      layout(size => box(
        width: 100%,
        height: size.width * (5 / 4),
        clip: true,
        image(profile-image, width: 100%, height: 100%, fit: "cover"),
      )),
      columns: (7fr, 4fr),
      column-gutter: 2em,
    )
  } else {
    left-content
  }
}

#let cv(
  name: "",
  lang: "en",
  keywords: (),
) = body => {
  set document(
    title: "CV - " + name,
    author: name,
    keywords: keywords,
  )
  set page(
    margin: 2cm,
    footer: context {
      let current = counter(page).get().first()
      let total = counter(page).final().first()
      set text(size: body-size, fill: meta-color)
      align(center, [#current / #total])
    },
  )
  // Bundled font: PT Sans (via TYPST_FONT_PATHS)
  set text(size: label-size, font: "PT Sans", lang: lang, fill: text-color)
  set par(justify: true)

  // Add breathing room before each section heading (level 1).
  show heading.where(level: 1): it => {
    v(0.3em)
    it
    v(0.6em)
  }

  body
}
