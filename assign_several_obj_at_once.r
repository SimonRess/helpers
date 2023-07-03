#assign content to multiple objects at once
#Sources:
#   - https://stackoverflow.com/questions/7519790/assign-multiple-new-variables-on-lhs-in-a-single-line
#   - assign value from function to parent if binding is locked: https://rdrr.io/r/base/bindenv.html

#1. ####
  `%tin%` <- function(x, y) {
    mapply(assign, as.character(substitute(x)[-1]), y,
      MoreArgs = list(envir = parent.frame()))
    invisible()
  }

    `%tin%` <- function(x, y) {
    print(as.character(substitute(x)[-1]))
    print(y)
    }
    c(a, b) %tin% list(list(1,2,3,4), 2)

`%tin%` <- function(x, y) {
    #lapply(assign, as.character(substitute(x)), y, MoreArgs = list(envir = parent.frame()))
  lapply(c(x,y), \(x,y) c(x,y))
}

  list(a, b) %tin% list(list(1,2,3,4), 2)
  a
  b

#2. Vectorize-assign ####
  #
  assignVec <- Vectorize("assign",c("x","value"))
  #.GlobalEnv is probably not what one wants in general; see below.
  assignVec(x = c('a','b'),value=list(list(1,5),data.frame(1,2,3,4)),envir = .GlobalEnv)
  rm(a,b,c)


#3. lapply-assign
  `%=%` <- function(names, input, env=parent.frame()) {
    names = as.character(substitute(c(a, b, c))[-1])
    invisible(lapply(seq_along(names), function(i) assign(names[i], input[[i]], envir = env)))
  }

  df = data.frame(A = 1:10, B = 11:20, C = 21:30)
  list = list(list(1,2,3), 4, c(6:9))
  vec = c("aa", "bb", "cc")
  rm(a,b,c)

  .GlobalEnv

  xx = new.env()
  xx$z = 1
  ls(xx)

  c(a, b, c) %=% list(a = df, b = list, c = vec) env=xx






