# Install and load the RMySQL Package to connect to the database
install.packages("RMySQL")
library(RMySQL)


# connect to the database and name it for use
stmusic <- dbConnect(MySQL(), user='username', password='password', 
                    dbname='stmusic', host='hostAddress')


#run a query through R to pull data housed in MySQL
rs <- dbSendQuery(stmusic, "select * from uniqueTracks limit 100")

# retrive the records pulled through the query
rsdata <-  fetch(rs, n=-1) # The n in the function specifies the number of records to retrieve, 
                           # using n=-1 retrieves all pending records.

#take a look at a sample of the retrieved data
head(rsdata)
