library(purrr)
library(rlang)

# TODO:
# * way to print function with body
# * way to highlight arguments

pkg_funs <- function(pkg) {
  env <- pkg_env(pkg)
  funs <- keep(as.list(env, sorted = TRUE), is_closure)
  
  map2(names(funs), funs, fun_def, pkg = pkg)
}

fun_call <- function(fun, ...) {
  call <- enexpr(fun)
  
  if (is.symbol(call)) {
    name <- as.character(call)
    env_name <- env_name(environment(fun))
    pkg <- if (grepl("namespace:", env_name)) gsub("namespace:", "", env_name) else NULL 
  } else if (is_call(call, "::", n = 2)) {
    name <- as.character(call[[3]])
    pkg <- as.character(call[[2]])
  } else {
    abort("Invalid input")
  }
  
  fun_def(name, fun, pkg = pkg, ...)
}

fun_def <- function(name, fun, pkg = NULL, highlight = NULL) {
  stopifnot(is_string(name))
  stopifnot(is.function(fun))
  
  new_fun_def(
    name = name,
    formals = formals(fun),
    body = body(fun),
    pkg = pkg,
    highlight = highlight
  )
}

new_fun_def <- function(name, formals, body, pkg = NULL, highlight = NULL) {
  structure(
    list(
      name = name, 
      formals = formals, 
      body = body, 
      pkg = pkg,
      highlight = highlight
    ),
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
  
  # Doesn't work because format escapes  
  if (!is.null(x$highlight)) {
    embold <- names(formals) %in% x$highlight
    names(formals)[embold] <- cli::style_bold(names(formals)[embold])
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
