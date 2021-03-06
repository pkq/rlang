test_that("error_cnd() checks its fields", {
  expect_no_error(error_cnd(trace = NULL))
  expect_error(error_cnd(trace = env()), "`trace` must be NULL or an rlang backtrace")
  expect_no_error(error_cnd(parent = NULL))
  expect_error(error_cnd(parent = env()), "`parent` must be NULL or a condition object")
})

test_that("can use conditionMessage() method in subclasses of rlang errors", {
  skip_if_stale_backtrace()

  run_error_script <- function(envvars = chr()) {
    run_script(
      test_path("fixtures", "error-backtrace-conditionMessage.R"),
      envvars = envvars
    )
  }
  non_interactive <- run_error_script()
  interactive <- run_error_script(envvars = "rlang_interactive=true")

  expect_snapshot({
    cat_line(interactive)
    cat_line(non_interactive)
  })
})

test_that("rlang_error.print() calls conditionMessage() method", {
  local_bindings(.env = global_env(),
    conditionMessage.foobar = function(c) c$foobar_msg
  )
  local_options(
    rlang_trace_format_srcrefs = FALSE,
    rlang_trace_top_env = current_env()
  )

  f <- function() g()
  g <- function() h()
  h <- function() abort("", "foobar", foobar_msg = "Low-level message")

  # Handled error
  err <- catch_error(f())
  expect_snapshot(print(err))
})

test_that("error is printed with parent backtrace", {
  # Test low-level error can use conditionMessage()
  local_bindings(.env = global_env(),
    conditionMessage.foobar = function(c) c$foobar_msg
  )

  f <- function() g()
  g <- function() h()
  h <- function() abort("", "foobar", foobar_msg = "Low-level message")

  a <- function() b()
  b <- function() c()
  c <- function() {
    tryCatch(
      f(),
      error = function(err) {
        abort("High-level message", parent = err)
      }
    )
  }

  local_options(
    rlang_trace_format_srcrefs = FALSE,
    rlang_trace_top_env = current_env(),
    rlang_backtrace_on_error = "none"
  )

  err <- catch_error(a())

  err_force <- with_options(
    catch_error(a()),
    `rlang::::force_unhandled_error` = TRUE,
    `rlang:::error_pipe` = tempfile()
  )

  expect_snapshot({
    print(err)
    print(err_force)
  })
  expect_snapshot({
    print(err, simplify = "none")
  })
  expect_snapshot_trace(err)
})

test_that("summary.rlang_error() prints full backtrace", {
  local_options(
    rlang_trace_top_env = current_env(),
    rlang_trace_format_srcrefs = FALSE
  )

  f <- function() tryCatch(g())
  g <- function() h()
  h <- function() abort("The low-level error message", foo = "foo")

  handler <- function(c) {
    abort("The high-level error message", parent = c)
  }

  a <- function() tryCatch(b())
  b <- function() c()
  c <- function() tryCatch(f(), error = handler)

  err <- catch_error(a())
  expect_snapshot(summary(err))
})

test_that("can take the str() of an rlang error (#615)", {
  err <- catch_error(abort("foo"))
  expect_output(expect_no_error(str(err)))
})

test_that("don't print message or backtrace fields if empty", {
  err <- error_cnd("foo", message = "")
  expect_snapshot(print(err))
})

test_that("base parent errors are printed with rlang method", {
  base_err <- simpleError("foo")
  rlang_err <- error_cnd("bar", message = "", parent = base_err)
  expect_snapshot(print(rlang_err))
})
