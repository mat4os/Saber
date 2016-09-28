# Instalación paquetes
for (package in c('twitteR','devtools','NLP','slam','plyr','RMySQL','syuzhet')) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package,repos='http://cran.us.r-project.org')
    library(package, character.only=T)
  }
}

Sys.setenv(TZ="Europe/Madrid")
install_url("http://cran.r-project.org/src/contrib/Archive/sentiment/sentiment_0.2.tar.gz")
require(sentiment,quietly = T)

# Conexión Twitter
api_key = "UrtPdW27KUz0Gevnyg0mV6a8n"
api_secret = "thw4yjF5vZuMbRFf3NFdKlx4w5iIdi6VrqV8jd7OlF2sksWp0m"
access_token = "768751098328969216-DeEgRbECqPEKC9kLFow2888RBQspPK3"
access_token_secret = "vC0bnWMMNLqRFrdvyN6n1oegWn9U9hqIiFLXF5so4MFkU"
options(httr_oauth_cache=T)
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)


## METODOS INTERNOS
#############################

# Recibe un keyword y un número de tweets a extraer, retorna un dataframe
lee_tweets <- function(ticker, num){

  tweets = searchTwitter(ticker, n=num, lang="en")
  dftweets <- twListToDF(tweets)
  return(dftweets)
}

# Recibe un texto y elimina etiquetas, retweets, etc...
limpia_tweets <- function(textos){
  
  textos <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", textos) #remove retweets 
  textos <- gsub("@\\w+", "", textos) #remove referral
  textos <- gsub("[[:punct:]]", "", textos) #remove punctuation
  textos <- gsub("[[:digit:]]", "", textos) #remove numbers
  textos <- gsub("http\\w+", "", textos) #remove links
  textos <- gsub("[ \t]{2,}", " ", textos) #remove big spaces 
  textos <- gsub("^\\s+|\\s+$", "", textos) #remove trailing and leading spaces #REVIEW http://stackoverflow.com/questions/30763257/remove-trailing-and-leading-spaces-and-extra-internal-whitespace-with-one-gsub-c
  textos <- iconv(textos,"UTF-8","latin1")
  textos <- tolower(textos)
  return(textos)
}


# Recibe un conjunto de textos y devuelve su polaridad (sentiment)
calcula_polaridad <- function(textos){
    
    class_pol = classify_polarity(textos, algorithm="bayes")
    polarity = class_pol[,4] #best fit
    dfpolaridad = data.frame(text=textos, polarity=polarity, stringsAsFactors=FALSE)
    return(dfpolaridad)
}

# Recibe un conjunto de textos y devuelve su polaridad (syuzhet)
calcula_polaridad_syuzhet <- function(textos, met = "bing"){
  
  dfpolaridad <- get_sentiment(textos,method=met)
  return (dfpolaridad)
}
  
# Calcula el total de positivos, negativos y neutros (sentiment)
calcula_totales <- function(dfpolar){
  
  y = count(dfpolar, 'polarity')
  
}

# Calcula el total de positivos, negativos y neutros (syuzhet)
calcula_totales_syuzhet <- function(dfpolar){
  count(sign(dfpolar))
}


# Mayor número de ocurrencias: positivo (1), neutral(0) o negativo (-1) (sentiment)
calcula_scoring <- function (totales){
  
  selection <- totales[which.max(totales$freq),]$polarity
  if ( selection == 'positive') {
    retorno <- 1
  } else if ( selection == 'negative') {
    retorno <- -1
  } else if ( selection == 'neutral') {
    retorno <- 0
  }

}

# Mayor número de ocurrencias: positivo (1), neutral(0) o negativo (-1) (syuzhet)
calcula_scoring_syuzhet <- function (totales){
  
  selection <- totales[which.max(totales$freq),]$x
  if ( selection == 1) {
    retorno <- 1
  } else if ( selection == -1) {
    retorno <- -1
  } else if ( selection == 0) {
    retorno <- 0
  }
  
}

# Guarda en base de datos las búsquedas realizadas
guarda_bbdd <- function (dftotal,ticker, met = 'sentiment'){
  mydb = dbConnect(MySQL(), user='root', password='vivarbet1', dbname='sentiment', host='localhost')
  neg = newdata <- dftotal[ which(dftotal$polarity=='negative') ,2]
  pos = newdata <- dftotal[ which(dftotal$polarity=='positive') ,2]
  neu = newdata <- dftotal[ which(dftotal$polarity=='neutral') ,2]
  n = neg + pos + neu
  perc <- dftotal$freq[dftotal$polarity=='positive']/ sum(dftotal$freq)
  sc <- calcula_scoring(dftotal)
  query = paste0("INSERT INTO score (ticker, n, pos, neg,neu,scoring,perc,met) VALUES (",ticker,",",n,",",pos,",",neg,",",neu,",",sc,",",perc,",'",met,"')")
  print(query)
  rs = dbSendQuery(mydb,query) 
  dbDisconnect(mydb)
  
}


# Guarda en base de datos las búsquedas realizadas
guarda_bbdd_syuzhet <- function (dftotal,ticker, met = 'syuzhet'){
  print('df')
  print(dftotal)
  mydb = dbConnect(MySQL(), user='root', password='vivarbet1', dbname='sentiment', host='localhost')
  neg = newdata <- dftotal[ which(dftotal$x==-1) ,2]
  pos = newdata <- dftotal[ which(dftotal$x==1) ,2]
  neu = newdata <- dftotal[ which(dftotal$x==0) ,2]
  n = neg + pos + neu
  print("n")
  perc <- pos / n
  sc <- calcula_scoring_syuzhet(dftotal)
  query = paste0("INSERT INTO score (ticker, n, pos, neg,neu,scoring,perc,met) VALUES (",ticker,",",n,",",pos,",",neg,",",neu,",",sc,",",perc,",'",met,"')")
  print(query)
  rs = dbSendQuery(mydb,query)
  dbDisconnect(mydb)
  
}






## METODOS EXPUESTOS POR API
#############################

# Devuelve el número de positivos, negativos y neutros (sentiment)
#* @get /consulta
consultaTicker <- function (ticker, num = 100){
  tweets <- lee_tweets(ticker,num)
  tweet_limpios <- limpia_tweets(tweets$text)
  polaridad <- calcula_polaridad(tweet_limpios)
  totales <- calcula_totales(polaridad)
#  guarda_bbdd(totales,ticker)
  totales
}


# Devuelve 1, 0 o -1 (sentiment/syuzhet)
#* @get /scoring
scoring <- function (ticker, num = 100, met = 'sentiment'){
  print("patata")
  print(met)
  tweets <- lee_tweets(ticker,num)
  tweet_limpios <- limpia_tweets(tweets$text)
  if (met == 'sentiment'){
    polaridad <- calcula_polaridad(tweet_limpios)
    totales <- calcula_totales(polaridad)
    #guarda_bbdd(totales,ticker,met)
    calcula_scoring(totales)
  }
  else if (met == 'syuzhet'){
    polaridad <- calcula_polaridad_syuzhet(tweet_limpios)
    totales <- calcula_totales_syuzhet(polaridad)
    #guarda_bbdd_syuzhet(totales,ticker,met) #TODO REviSAR
    calcula_scoring_syuzhet(totales)
  }
}
  

#* @get /porcentaje 
porcentaje <- function (ticker, num = 100, met = 'sentiment'){
 
  tweets <- lee_tweets(ticker,num)
  tweet_limpios <- limpia_tweets(tweets$text)
  if (met == 'sentiment'){
    polaridad <- calcula_polaridad(tweet_limpios)
    totales <- calcula_totales(polaridad)
    perc <- totales$freq[totales$polarity=='positive']/ sum(totales$freq)
    perc
   
  }
  
  else if (met == 'syuzhet'){
    polaridad <- calcula_polaridad_syuzhet(tweet_limpios)
    print(polaridad)
    totales <- calcula_totales_syuzhet(polaridad)
    print(totales)
    perc <- totales$freq[totales$x==1]/ sum(totales$freq)
    perc
  }
}

  
# Devuelve polaridad (sentiment)
#* @get /polaridad 
polaridad <- function(textos){
    class_pol = classify_polarity(textos, algorithm="bayes")
    polarity = class_pol[,4] #best fit
    dfpolaridad = data.frame(text=textos, polarity=polarity, stringsAsFactors=FALSE)
    return(dfpolaridad$polarity)
}
    


# Devuelve polaridad completa (sentiment)
#* @get /polaridad_completa 
polaridad_completa <- function(textos){
  class_pol = classify_polarity(textos, algorithm="bayes")
  return(class_pol)
}

# Devuelve emocion (sentiment)
#* @get /emocion_completa 
emocion_completa <- function(textos){
  class_emo = classify_emotion(textos, algorithm="bayes")
  return(class_emo)
}

# Devuelve emocion completa (sentiment)
#* @get /emocion
emocion <- function(textos){
  emo = classify_emotion(textos, algorithm="bayes")
  emocion = emo[,7] #best fit
  dfpolaridad = data.frame(text=textos, emocion=emocion, stringsAsFactors=FALSE)
  return(dfpolaridad$emocion)
}




