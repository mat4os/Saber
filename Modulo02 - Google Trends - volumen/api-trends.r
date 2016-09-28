for (package in c('gtrendsR','XML','RMySQL')) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package,repos='http://cran.us.r-project.org')
    library(package, character.only=T)
  }
}


user <- "losmat4os@gmail.com"
psw <- "vivarbet1"
gconnect(user, psw) 

lee_trends <- function(ticker){
  ret<-gtrends(ticker,res="7d", geo= "US")
}


calcula_scoring <- function(trends){
  sum(trends$trend[2])
  
}


guarda_bbdd <- function (trends,ticker){
   mydb = dbConnect(MySQL(), user='root', password='vivarbet1', dbname='trends', host='localhost')
   score = calcula_scoring(trends)
   query = paste0("INSERT INTO volume (ticker, score) VALUES (",ticker,",",score,")")
   rs = dbSendQuery(mydb,query) 
 }




#* @get /trends
consultaTicket <- function (ticker){

  trends <- lee_trends(ticker)
  trends$trend
}


# #* @get /score
# calculaScore <- function (ticker){
#   ticker <- gsub('\\.', ' ', ticker)
#   print(ticker)
#   trends <- lee_trends(ticker)
#   #guarda_bbdd(trends,ticker)
#   calcula_scoring(trends)
# }


#* @get /score
calculaScore <- function (ticker){
result = tryCatch({
  ticker <- gsub('\\.', ' ', ticker)
  ticker <- gsub('&', ' ' , ticker)
  print(ticker)
  trends <- lee_trends(ticker)
#  guarda_bbdd(trends,ticker)
  return(calcula_scoring(trends))
},error = function(e) {
  return (0)
})
}


#* @get /relacionadas
relacionadas <- function(ticker){
  trends <- lee_trends(ticker)
  trends[8]
}
