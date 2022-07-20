# Dot prefix {#dots-prefix}



## What's the pattern?

When using `...` to create a data structure, or when passing `...` to a user-supplied function, add a `.` prefix to all named arguments. This reduces (but does not eliminate) the chances of matching an argument at the wrong level. Additionally, you should always provide some mechanism that allows you to escape and use that name if needed.


```r
library(purrr)
```

(Not important if you ignore names: e.g. `cat()`.)

## What are some examples?

Look at the arguments to some functions in purrr:


```r
args(map)
#> function (.x, .f, ...) 
#> NULL
args(reduce)
#> function (.x, .f, ..., .init, .dir = c("forward", "backward")) 
#> NULL
args(detect)
#> function (.x, .f, ..., .dir = c("forward", "backward"), .right = NULL, 
#>     .default = NULL) 
#> NULL
```

Notice that all named arguments start with `.`. This reduces the chance that you will incorrectly match an argument to `map()`, rather than to an argument of `.f`. Obviously it can't eliminate it.

Escape mechanism is the anonymous function. Little easier to access in `purrr::map()` since you can create with `~`, which is much less typing than `function() {}`. For example, imagine you want to...

Example: https://jennybc.github.io/purrr-tutorial/ls02_map-extraction-advanced.html#list_inside_a_data_frame

## Case study: dplyr verbs


```r
args(dplyr::filter)
#> function (.data, ..., .preserve = FALSE) 
#> NULL
args(dplyr::group_by)
#> function (.data, ..., .add = FALSE, .drop = group_by_drop_default(.data)) 
#> NULL
```

Escape hatch is `:=`.

Ooops:


```r
args(dplyr::left_join)
#> function (x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), 
#>     ..., keep = FALSE) 
#> NULL
```

## Other approaches in base R

Base R uses two alternative methods: uppercase and `_` prefix.

The apply family tends to use uppercase function names for the same reason. Unfortunately the functions are a little inconsitent which makes it hard to see this pattern. I think a dot prefix is better because it's easier to type (you don't have to hold down the shift-key with one finger).


```r
args(lapply)
#> function (X, FUN, ...) 
#> NULL
args(sapply)
#> function (X, FUN, ..., simplify = TRUE, USE.NAMES = TRUE) 
#> NULL
args(apply)
#> function (X, MARGIN, FUN, ..., simplify = TRUE) 
#> NULL
args(mapply)
#> function (FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE) 
#> NULL
args(tapply)
#> function (X, INDEX, FUN = NULL, ..., default = NA, simplify = TRUE) 
#> NULL
```

`Reduce()` and friends avoid the problem altogether by not accepting `...`, and requiring that the user creates anonymous functions. But this is verbose, particularly without shortcuts to create functions.

`transform()` goes a step further and uses an non-syntactic variable name.


```r
args(transform)
#> function (`_data`, ...) 
#> NULL
```

Using a non-syntactic variable names means that it must always be surrounded in `` ` ``.  This means that a user is even less likely to use it that with `.`, but it increases friction when writing the function. In my opinion, this trade-off is not worth it.

## What are the exceptions?

*  `tryCatch()`: the names give classes so, as long as you don't create a 
    condition class called `expr` or `finally` (which would be weird!) you
    don't need to worry about matches

*   
