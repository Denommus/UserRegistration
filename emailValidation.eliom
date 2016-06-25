let email_regexp = Str.regexp "[a-zA-Z0-9\\.]+@[a-zA-Z0-9]+\\(\\.[a-zA-Z0-9]\\)+"
let email_validation str = Str.string_match email_regexp str 0

[%%client
  let email_regexp = Regexp.regexp "[a-zA-Z0-9\\.]+@[a-zA-Z0-9]+(\\.[a-zA-Z0-9])+"
  let email_validation str = match Regexp.string_match email_regexp str 0 with
    | Some _ -> true
    | None -> false
]
