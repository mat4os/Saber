for (package in c('plumber')) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package,repos='http://cran.us.r-project.org')
    library(package, character.only=T)
  }
}


#install.packages('plumber')
library(plumber)
r <- plumb("api-trends.R")  
r$run(port=80)



