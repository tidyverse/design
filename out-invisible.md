# Side-effect functions should return invisibly {#out-invisible}



## What's the pattern?

If a function is called primarily for its side-effects, it should invisibly return a useful output. If there's no obvious output, return the first argument. This makes it possible to use the function with in a pipeline.

## What are some examples?



* `print(x)` invisibly returns the printed object.

* `x <- y` invisible returns `y`. This is what makes it possible to chain
  together multiple assignments `x <- y <- z <- 1`

* `readr::write_csv()` invisibly returns the data frame that was saved.

* `purrr::walk()` invisibly returns the vector iterated over.

* `fs:file_copy(from, to)` returns `to`

* `options()` and `par()` invisibly return the previous value so you can 
  reset with `on.exit()`.

## Why is it important?

Invisibly returning the first argument allows to call the function mid-pipe for its side-effects while allow the primary data to continue flowing through the pipe. This is useful for generating intermediate diagnostics, or for saving multiple output formats.


```r
library(dplyr, warn.conflicts = FALSE)
library(tibble)

mtcars %>%
  as_tibble() %>% 
  filter(cyl == 6) %>% 
  print() %>% 
  group_by(vs) %>% 
  summarise(mpg = mean(mpg))
#> # A tibble: 7 × 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#> 2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#> 3  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#> 4  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#> 5  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#> 6  17.8     6  168.   123  3.92  3.44  18.9     1     0     4     4
#> 7  19.7     6  145    175  3.62  2.77  15.5     0     1     5     6
#> # A tibble: 2 × 2
#>      vs   mpg
#>   <dbl> <dbl>
#> 1     0  20.6
#> 2     1  19.1
```


```r
library(readr)

mtcars %>% 
  write_csv("mtcars.csv") %>% 
  write_tsv("mtcars.tsv")

unlink(c("mtcars.csv", "mtcars.tsv"))
```


```r
library(fs)

paths <- file_temp() %>%
  dir_create() %>%
  path(letters[1:5]) %>%
  file_create()
paths
#> /tmp/RtmpUceado/file32bd7128070f/a /tmp/RtmpUceado/file32bd7128070f/b 
#> /tmp/RtmpUceado/file32bd7128070f/c /tmp/RtmpUceado/file32bd7128070f/d 
#> /tmp/RtmpUceado/file32bd7128070f/e
```

Functions that modify some global state, like `options()` or `par()`, should return the _previous_ value of the variables. This, in combination with Section \@ref(args-compound), makes it possible to easily reset the effect of the change:


```r
x <- runif(1)
old <- options(digits = 3)
x
#> [1] 0.251

options(old)
x
#> [1] 0.2508593
```
