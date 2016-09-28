install.packages("gtrendsR")
install.packages("XML")
library(gtrendsR)
library(XML)
user <- "losmat4os@gmail.com"
psw <- "vivarbet1"
gconnect(user, psw) 
a<-gtrends("Nintendo",res="7d")

a[7]

a$trend

sum(a$trend$nintendo.)
colname = colnames(a$trend)[2]


a$trend$colname
a$trend[6]
#* @get /score

trends <- lee_trends('Un perro verde')
trends
calcula_scoring(trends)

ticker <- 'Apple Inc.'
ticker <- gsub('\\.', '', ticker)
ticker

pp <- gtrends('E. I. du Pont de Nemours and Company',res="7d", geo= "US")



result = tryCatch({
  pp <- gtrends('E. I. du Pont de Nemours and Company',res="7d", geo= "US")
},error = function(e) {
  print('pepe')
}, finally = {
  cleanup-code
})




