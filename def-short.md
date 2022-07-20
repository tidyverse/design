# Keep defaults short and sweet {#def-short}





## What's the pattern?

Default values should be short and sweet. This makes the function specification easier to scan.

## What are some examples?

The following examples, drawn from base R, illustrate some functions that don't follow this pattern:

* `sample.int()` uses a complicated rule to determine whether or not to use
  a faster hash based method that's only applicable in some circumstances:
  `useHash = (!replace && is.null(prob) && size <= n/2 && n > 1e+07))`

* `exists()`, which figures out if a variable exists in a given environment,
  uses a complex default to determine which environment to look in if not
  specifically provided: 
  `envir = (if (missing(frame)) as.environment(where) else sys.frame(frame))`
  (NB: `?exists` cheats and hides the long default in the documentation.)

*  `reshape()` has the longest default argument in the base and stats packages.
   The `split` argument is one of two possible lists depending on the value
   of the `sep` argument:

    
    ```r
    reshape(
      split = if (sep == "") {
        list(regexp = "[A-Za-z][0-9]", include = TRUE)
      } else {
        list(regexp = sep, include = FALSE, fixed = TRUE)
      })
    )
    ```

## Why is it important?

## How do I use it?

There are three approaches:

* Set the default value to `NULL` and calculate the default only when the 
  argument is `NULL`. Providing a default of `NULL` signals that the argument 
  is optional (Chapter \@ref(def-required)) but that the default requires
  some calculation.

* If the calculation is complex, and the user might find it useful in other 
  scenarios, compute it with an exported function that documents exactly
  what happens.

* If `NULL` is meaningful, so you can't use the first approach, use a 
  "sentinel" object instead.

### `NULL` default {#arg-short-null}

The most common approach is to use `NULL` as a sentinel value that indicates that the argument is optional, but non-trivial. This pattern is made substantially more elegant with the infix `%||%` operator. You can either get it by importing it from rlang, or copying and pasting it in to your `utils.R`:


```r
`%||%` <- function(x, y) if (is.null(x)) y else x
```

This allows you to write code like this (extracted from `ggplot2::geom_bar()`). It computes the width by first looking at the data, then in the paramters, finally falling back to computing it from the resolution of the `x` variable:


```r
width <- data$width %||% params$width %||% (resolution(data$x, FALSE) * 0.9)
```

Or this code from the colourbar legend: it finds the horizontal justification by first looking in the guide settings, then in the specific theme setting, then then title element, finally using `0` if  nothing else is set:


```r
title.hjust <- guide$title.hjust %||% 
  theme$legend.title.align %||% 
  title.theme$hjust %||% 
  0
```

As you can see, `%||%` is particularly well suited to arguments where the default value is found through a cascading system of fallbacks.

Don't use `%||%` for more complex examples. For example in `reshape()` I would set `split = NULL` and then write:


```r
if (is.null(split)) {
  if (sep == "") {
    split <- list(regexp = "[A-Za-z][0-9]", include = TRUE)
  } else {
    split <- list(regexp = sep, include = FALSE, fixed = TRUE)
  }
}
```

(I would probably also switch on `is.null(sep)` too, to make it more clear that there is special behaviour.)

### Helper function

For more complicated cases, you'll probably want to pull the code that computes the default out into a separate function, and in many cases you'll want to export (and document) the function.

A good example of this pattern is `readr::show_progress()`: it's used in every `read_` function in readr and it's sufficiently complicated that you don't want to copy and paste it between functions. It's also nice to document it in its own file, rather than cluttering up file reading functions with incidental details.

### Sentinel value {#args-default-sentinel}

Sometimes a default argument has a complex calculation that you don't want to include in arguments list. You'd normally use `NULL` to indicate that it's calculated by default, but `NULL` is a meaningful option. In that case, you can use a __sentinel__ object.


```r
str(ggplot2::waiver())
#>  list()
#>  - attr(*, "class")= chr "waiver"

str(purrr::done())
#> List of 1
#>  $ : symbol 
#>  - attr(*, "class")= chr [1:2] "rlang_box_done" "rlang_box"
#>  - attr(*, "empty")= logi TRUE

str(rlang::zap())
#>  list()
#>  - attr(*, "class")= chr "rlang_zap"
```

Or is this the wrong way around? Should the default always be `NULL` and we have a special value to use when you actually want a `NULL`?

Take `purrr::reduce()`: it has an optional details argument called `init`. When supplied, it serves as the initial value for the computation. But any value (including `NULL`) can a valid value. And using a sentinel value for this one case seemed like overkill.


## How do I remediate existing problems?

If you have a function with a long default, you can use any of the three approaches above to remediate it. As long as you don't accidentally change the default value, this does not affect the function interface. Make sure you have a test for the default operation of the function before embarking on this change.


```r
# BEFORE
sample.int <- function(n, 
                       size = n, 
                       replace = FALSE, 
                       prob = NULL, 
                       useHash = (!replace && is.null(prob) && size <= n/2 && n > 1e+07)
                       ) {
    if (useHash) {
      .Internal(sample2(n, size))
    } else {
      .Internal(sample(n, size, replace, prob))
    }
}

# AFTER
sample.int <- function(n, 
                       size = n, 
                       replace = FALSE, 
                       prob = NULL, 
                       useHash = NULL) {
  useHash <- useHash %||% !replace && is.null(prob) && size <= n/2 && n > 1e+07

  if (useHash) {
    .Internal(sample2(n, size))
  } else {
    .Internal(sample(n, size, replace, prob))
  }
}
```

