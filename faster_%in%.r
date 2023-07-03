# Faster Functions
if(!require(fastmatch)) install.packages("fastmatch")
library(fastmatch)
`%fin%` <- function(x, table) {
  #stopifnot(require(fastmatch))
  fmatch(x, table, nomatch = 0L) > 0L
}

#Benchmarking
    # table <- 1L:10000
    # x <- sample(table, 10000, replace=TRUE)
    # system.time(for(i in 1:300) a <- x %in% table)
    # system.time(for(i in 1:300) b <- x %fin% table)
    # system.time(for(i in 1:300) c <- x %ffin% table)

#  if(!require(compiler)) install.packages("compiler")
#  library("compiler")
# `%ffin%` = cmpfun(`%fin%`)
