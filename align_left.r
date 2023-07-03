require(dplyr)
align_left <- function(d, varname) {
  num = sum(startsWith(names(d), varname)) 
  
  while(any(is.na(d[, paste0(varname,1)]) & rowSums(is.na(d))<num )){ 
    for(i in 1:(num-1)) {
      var1 = paste0(varname, i)
      var2 = paste0(varname, i+1)
      d = d %>% 
        mutate(!!var1 := ifelse(is.na(get(var1)), get(var2), get(var1)),
               !!var2 := ifelse(get(var1)!=get(var2), get(var2), NA))
    }
  }
  
  return(d)
}
