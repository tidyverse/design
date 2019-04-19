library(purrr)
library(rlang)

# Should return more complex function object with print method
pkg_funs <- function(pkg) {
  env <- pkg_env(pkg)
  funs <- keep(as.list(env, sorted = TRUE), is_closure)
  
  map2(names(funs), funs, fun_def, pkg = pkg)
}

fun_def <- function(name, fun, pkg = NULL) {
  new_fun_def(
    name = name,
    formals = formals(fun),
    body = body(fun),
    pkg = pkg
  )
}

new_fun_def <- function(name, formals, body, pkg = NULL) {
  structure(
    list(name = name, formals = formals, body = body, pkg = pkg),
    class = "fun_def"
  )
}
format.fun_def <- function(x, ...) {
  if (is.null(x$pkg)) {
    call <- sym(x$name)
  } else {
    call <- call2("::", sym(x$pkg), sym(x$name))  
  }
  
  # Replace missing args with symbol
  formals <- x$formals
  if (!is.null(formals)) {
    is_missing <- map_lgl(formals, is_missing)
    formals[is_missing] <- syms(names(formals)[is_missing])
    names(formals)[is_missing] <- ""
  }
  
  paste0(format(call2(call, !!!formals)), collapse = "\n")
}

print.fun_def <- function(x, ...) {
  cat(format(x, ...), "\n", sep = "")
}

funs_formals_keep <- function(x, .p) {
  keep(x, function(fn) some(fn$formals, .p))
}

funs_body_keep <- function(.x, .p, ...) {
  keep(.x, function(fn) .p(fn$body, ...))
}
has_call <- function(x, name) {
  if (is_call(x, name)) {
    TRUE
  } else if (is_call(x)) {
    some(x[-1], has_call, name = name)
  } else {
    FALSE
  }
}
