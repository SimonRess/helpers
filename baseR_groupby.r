# In base you can use ave() to get max per group and compare this with pt and get a logical vector to subset the data.frame.

group[group$pt == ave(group$pt, group$Subject, FUN=max),]
#  Subject pt Event
#3       1  5     2
#7       2 17     2
#9       3  5     2

# Or using in addition with().
group[with(group, pt == ave(pt, Subject, FUN=max)),]
