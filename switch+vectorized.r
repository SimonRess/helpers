

#Sources
    # - [base::switch](https://rdrr.io/r/base/switch.html)
    # - [dplyr::case_match](https://dplyr.tidyverse.org/reference/case_match.html)


# switch
    x = cars$speed
    type = "mean"

    switch(type,
        mean = mean(x),
        median = median(x))

    #Doesn't work with vectors
        type = c("mean", "median")
        switch(type,
            mean = mean(x),
            median = median(x))
        #-> Error: EXPR must be a length 1 vector

# dplyr::case_match

    #Works with vectors!
    if(!require(dplyr)) install.packages("dplyr", repos="https://cran.uni-muenster.de/")
    library(dplyr)

    type = c("mean", "median", "test", NA)

    case_match(type,
        "mean" ~ mean(x),
        "median" ~ median(x),
        NA ~ NA,
        .default = mean(x))


    #Works with %in% statements
    y <- c(1, 2, 1, 3, 1, NA, 2, 4)
    case_match(
        y,
        c(1, 3) ~ "odd",
        c(2, 4) ~ "even",
        .default = "missing"
    )

# custom commands

    #I. Vectorize: function wrapper that vectorizes its FUN
        # Data vector:
        test <- c("He is",
                "She has",
                "He has",
                "She is")

        # Vectorized SWITCH:
        foo <- Vectorize(vectorize.args = "a",
                        FUN = function(a) {
                        switch(as.character(a),
                                "He is" = 1,
                                "She is" = 1,
                                "He has" = 2,
                                2)})

        # Result:
        foo(a = test)

    #II. sapply: 
        test_out <- sapply(seq_along(test), 
                            function(x) switch(test[x],
                                                "He is"=1,
                                                "She is"=1,
                                                "He has"=2,
                                                "She has"=2))

    #III. Using a named vector 
        #- [Advanced R - Data structures: Attributes](http://adv-r.had.co.nz/Data-structures.html#attributes)

        # input
        test <-c("He is", "She has", "He has", "She is", "Unknown", "She is")

        # mapping
        map <- c(
        "He is" = 1, 
        "She has" = 2, 
        "He has" = 2, 
        "She is" = 1)

        answer <- map[test]

        # output
        answer

    
    #IV. If-else: Vectorization for two groups
        test <-c("He is", "She has", "He has", "She is", "Unknown", "She is")
        ifelse(test %in% c("He is", "She is"), 1, 2)
