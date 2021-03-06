test_that("matches arg", {
  myarg <- "foo"
  expect_identical(arg_match0(myarg, c("bar", "foo")), "foo")
  expect_error(
    arg_match0(myarg, c("bar", "baz")),
    "`myarg` must be one of \"bar\" or \"baz\""
  )
})

test_that("gives an error with more than one arg", {
  myarg <- c("bar", "fun")
  expect_error(
    regexp = "`myarg` must be one of \"bar\" or \"baz\".",
    arg_match0(myarg, c("bar", "baz"))
  )
})

test_that("gives error with different than rearranged arg vs value", {
  f <- function(myarg = c("foo", "bar", "fun")) {
    arg_match0(myarg, c("fun", "bar"))
  }
  expect_error(f(), "`myarg` must be a string or have the same length as `values`.")

  expect_error(
    arg_match0(c("foo", "foo"), c("foo", "bar"), arg_nm = "x"),
    regexp = "must be one of \"foo\" or \"bar\""
  )
})

test_that("gives no error with rearranged arg vs value", {
  expect_identical(arg_match0(rev(letters), letters), "z")

  skip_if_not_installed("withr")

  withr::with_seed(
    20200624L,
    expect_identical(arg_match0(letters, sample(letters)), "a")
  )
})

test_that("uses first value when called with all values", {
  myarg <- c("bar", "baz")
  expect_identical(arg_match0(myarg, c("bar", "baz")), "bar")
})

test_that("informative error message on partial match", {
  expect_error(
    arg_match0("f", c("bar", "foo")),
    "Did you mean \"foo\"?"
  )
})

test_that("`arg_match()` has informative error messages", {
  expect_snapshot({
    (expect_error(arg_match0("continuuos", c("discrete", "continuous"), "my_arg")))
    (expect_error(arg_match0("fou", c("bar", "foo"), "my_arg")))
    (expect_error(arg_match0("fu", c("ba", "fo"), "my_arg")))
    (expect_error(arg_match0("baq", c("foo", "baz", "bas"), "my_arg")))
    (expect_error(arg_match0("", character(), "my_arg")))
    (expect_error(arg_match0("fo", "foo", quote(f()))))
  })
})

test_that("`arg_match()` provides no suggestion when the edit distance is too large", {
  expect_snapshot({
    (expect_error(arg_match0("foobaz", c("fooquxs", "discrete"), "my_arg")))
    (expect_error(arg_match0("a", c("b", "c"), "my_arg")))
  })
})

test_that("`arg_match()` finds a match even with small possible typos", {
  expect_equal(
    arg_match0("bas", c("foo", "baz", "bas")),
    "bas"
  )
})

test_that("`arg_match()` makes case-insensitive match", {
  expect_snapshot({
    (expect_error(arg_match0("a", c("A", "B"), "my_arg"), "Did you mean \"A\"?"))

    # Case-insensitive match is done after case-sensitive
    (expect_error(arg_match0("aa", c("AA", "aA"), "my_arg"), "Did you mean \"aA\"?"))
  })
})

test_that("gets choices from function", {
  fn <- function(myarg = c("bar", "foo")) {
    arg_match(myarg)
  }
  expect_error(fn("f"), "Did you mean \"foo\"?")
  expect_identical(fn(), "bar")
  expect_identical(fn("foo"), "foo")
})

test_that("is_missing() works with symbols", {
  x <- missing_arg()
  expect_true(is_missing(x))
})

test_that("is_missing() works with non-symbols", {
  expect_true(is_missing(missing_arg()))

  l <- list(missing_arg())
  expect_true(is_missing(l[[1]]))
  expect_error(missing(l[[1]]), "invalid use")
})

test_that("maybe_missing() forwards missing value", {
  x <- missing_arg()
  expect_true(is_missing(maybe_missing(x)))
  expect_false(is_missing(maybe_missing(1L)))
})

test_that("is_missing() works with default arguments", {
  expect_true((function(x = 1) is_missing(x))())
  expect_false((function(x = 1) is_missing(x))(1))
})

test_that("is_missing() works with dots", {
  expect_true((function(...) is_missing(..1))())
  expect_false((function(...) is_missing(..1))(1))
})

test_that("arg_require() checks argument is supplied (#1118)", {
  f <- function(x) arg_require(x)
  g <- function(y) f(y)

  expect_error(f(NULL), NA)
  expect_error(g(NULL), NA)

  expect_snapshot({
    (expect_error(f()))
    (expect_error(g()))
  })
})

test_that("arg_match() supports symbols and scalar strings", {
  expect_equal(
    arg_match0(chr_get("foo", 0L), c("bar", "foo"), "my_arg"),
    "foo"
  )
  expect_equal(
    arg_match0(sym("foo"), c("bar", "foo"), "my_arg"),
    "foo"
  )

  expect_snapshot({
    (expect_error(arg_match0(chr_get("fo", 0L), c("bar", "foo"), "my_arg")))
  })
})
