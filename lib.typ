#import "languages/en.typ" as en
#import "languages/id.typ" as id

#let languages = (
  "en": en.lang-config,
  "id": id.lang-config,
)

#let name-it(num, lang: "en", ..options) = {
  // assert types
  assert(
    type(num) == int or (type(num) == str and num.contains(regex("^[--]?\d+$"))),
    message: "Argument must be a number or a valid string of a number"
  )

  assert(
    lang in languages,
    message: "Language '" + lang + "' is not supported. Create a issue or help contribute in `https://github.com/IrregularPersona/name-all-the-numbers`"
  )
  let config = languages.at(lang)

  // negative check
  let num-str = str(num)
  let is-negative = false

  if num-str.len() > 0 {
    let first-char = num-str.clusters().at(0)
    if first-char in ("-", "-") {
      is-negative = true
      num-str = num-str.clusters().slice(1).join()
    }
  }

  if num-str == "0" or int(num-str) == 0 {
    return if is-negative {
      config.format-negative(config.zero-name)
    } else {
      config.zero-name
    }
  }
  
  let remainder = calc.rem(num-str.len(), 3)
  if remainder != 0 {
    num-str = (3 - remainder) * "0" + num-str
  }

  let group-count = int(num-str.len() / 3)
  let parts = ()

  for group-idx in range(group-count) {
    let group-digits = num-str.slice(group-idx * 3, count: 3)
    let scale-idx = group-count - 1 - group-idx

    let group-text = config.convert-group(group-digits, scale-idx, options)

    if group-text != none and group-text.trim() != "" {
      parts.push((
        text: group-text,
        scale: scale-idx,
      ))
    }
  }

  let result = config.join-parts(parts, options)

  if is-negative {
    result = config.format-negative(result)
  }

  return result
}
