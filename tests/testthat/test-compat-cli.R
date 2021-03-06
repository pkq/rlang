skip_if_not_installed("cli")

cli::test_that_cli(configs = c("plain", "ansi"), "can style strings with cli", {
  expect_snapshot({
    style_emph("foo")
    style_strong("foo")
    style_code("foo")
    style_q("foo")
    style_pkg("foo")
    style_fn("foo")
    style_arg("foo")
    style_kbd("foo")
    style_key("foo")
    style_file("foo")
    style_path("foo")
    style_email("foo")
    style_url("foo")
    style_var("foo")
    style_envvar("foo")
    style_field("foo")
    style_cls("foo")
    style_cls(c("foo", "bar"))
  })
})

cli::test_that_cli(configs = "plain", "styled strings may contain `{` syntax", {
  expect_equal(style_emph("{foo {}"), "_{foo {}_")
})
