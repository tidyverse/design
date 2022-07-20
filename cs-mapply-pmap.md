# Case study: `mapply()` vs `pmap()` {#cs-mapply-pmap}





```r
library(purrr)
```

It's useful to compare `mapply()` to `purrr::pmap()`. They both are an attempt to solve a similar problem, extending `lapply()`/`map()` to handle iterating over any number of arguments. 


```r
args(mapply)
#> function (FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE) 
#> NULL
args(pmap)
#> function (.l, .f, ...) 
#> NULL
```


```r
x <- c("apple", "banana", "cherry")
pattern <- c("p", "n", "h")
replacement <- c("x", "f", "q")

mapply(gsub, pattern, replacement, x)
#>        p        n        h 
#>  "axxle" "bafafa" "cqerry"

mapply(gsub, pattern, replacement, x)
#>        p        n        h 
#>  "axxle" "bafafa" "cqerry"
purrr::pmap_chr(list(pattern, replacement, x), gsub)
#> [1] "axxle"  "bafafa" "cqerry"
```

Here we'll ignore `simplify = TRUE` which makes `mapply()` type-unstable by default. I'll also ignore `USE.NAMES = TRUE` which isn't just about using names, but about using character vector input as names for output. I think it's reused from `lapply()` without too much thought as it's only the names of the first argument that matter.


```r
mapply(toupper, letters[1:3])
#>   a   b   c 
#> "A" "B" "C"
mapply(toupper, letters[1:3], USE.NAMES = FALSE)
#> [1] "A" "B" "C"
mapply(toupper, setNames(letters[1:3], c("X", "Y", "Z")))
#>   X   Y   Z 
#> "A" "B" "C"

pmap_chr(list(letters[1:3]), toupper)
#> [1] "A" "B" "C"
```

`mapply()` takes the function to apply as the first argument, followed by an arbitrary number of arguments to pass to the function. This makes it different to the other `apply()` functions (including `lapply()`, `sapply()` and `tapply()`), which take the data as the first argument. `mapply()` could take `...` as the first arguments, but that would force `FUN` to always be named, which would also make it inconsistent with the other `apply()` functions. 

`pmap()` avoids this problem by taking a list of vectors, rather than individual vectors in `...`. This allows `pmap()` to use `...` for another purpose, instead of the `MoreArg` argument (a list), `pmap()` passes `...` on to `.f`.


```r
mapply(gsub, pattern, replacement, x, fixed = TRUE)
#>        p        n        h 
#>  "axxle" "bafafa" "cqerry"
purrr::pmap_chr(list(pattern, replacement, x), gsub, fixed = TRUE)
#> [1] "axxle"  "bafafa" "cqerry"
```

There's a subtle difference here that doesn't matter in most cases - in the `mapply()` `fixed` is recycled to the same length as `pattern` whereas it is not `pmap()`. TODO: figure out example where that's more clear.

(Also note that `pmap()` uses the `.` prefix to avoid the problem described in Chapter \@ref(dots-prefix).)
