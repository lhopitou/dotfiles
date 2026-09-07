; extends

(jsx_element
  open_tag: (jsx_opening_element)
  _+ @jsx_element.inner
  close_tag: (jsx_closing_element)) @jsx_element.outer
