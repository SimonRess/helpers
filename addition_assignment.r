#addition_assignment
`%+=%` = function(lhs, rhs) {
      assign(as.character(substitute(lhs)), lhs + rhs,
             envir = parent.frame())
    }
    
val = 1
val %+=% 2
val # should be (1 + 2 = ) 3
