knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE
)

options(
  rlang_trace_top_env = rlang::current_env(),
  rlang_backtrace_on_error = "none"
)

rename <- function(old, new) {
  old_path <- fs::path_ext_set(old, "qmd")
  new_path <- fs::path_ext_set(new, "qmd")
  
  if (file.exists(old_path))
    fs::file_move(old_path, new_path)
  quarto <- readLines("_quarto.yml")
  quarto <- gsub(old_path, new_path, quarto, fixed = TRUE)
  writeLines(quarto, "_quarto.yml")

  old_slug <- paste0("sec-", old)
  new_slug <- paste0("sec-", new)
  
  qmd_paths <- dir(pattern = ".qmd$")
  qmds <- lapply(qmd_paths, readLines)
  qmds <- lapply(qmds, \(lines) gsub(old_slug, new_slug, lines, fixed = TRUE))
  purrr:::map2(qmds, qmd_paths, \(lines, path) writeLines(lines, path))
  
  invisible()
}