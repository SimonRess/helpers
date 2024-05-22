user = c("simon", "tim")
    
get_user_size = function(users) {
  sapply(users, \(x) switch(x
                           , john = "L"
                           , simon = "XL"
                           , tim = "XXL"
                           )
         )
}

user_sizes = get_user_size(user)
print(user_sizes)
