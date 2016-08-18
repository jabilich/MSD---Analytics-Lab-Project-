#created nested lists of folder structure within /users/alangao/documents/millionsongsubset/data
library(rhdf5)
library(RMySQL)
library(shiny)
library(leaflet)
setwd('/users/alangao/documents/millionsongsubset/data')
loadfiles = function()
{
	folderlevel = list("A", "B")
	names(folderlevel) = LETTERS[1:2]
	folderlevel[[1]] = sapply(LETTERS, list)
	folderlevel[[2]] = sapply(LETTERS[1:9], list)
	folderlevel[[1]] = lapply(folderlevel[[1]], function(x){x = sapply(LETTERS, list)})
	folderlevel[[2]][1:8] = lapply(folderlevel[[2]][1:8], function(x){x = sapply(LETTERS, list)})
	folderlevel[[2]][9] = lapply(folderlevel[[2]][9], function(x){x = sapply(LETTERS[1:10], list)})
	listext = sapply(sub('\\.', '/', sub('\\.', '/', names(unlist(folderlevel)))), list)
	h5files = lapply(listext, function(x){dir(path = paste(getwd(), x, sep = "/"), pattern = ".h5")})
	return(h5files)
}
h5files = loadfiles()
h5lookup = function(trackID, attribute = NULL, subatt = NULL)
{
	h5vector = unlist(h5files)
	trackfile = paste(trackID, '.h5', sep = "")
	filepath = paste(getwd(), substr(names(h5vector[which(h5vector == trackfile)])[1], start = 1, stop = 5), trackfile, sep = "/")
	if(is.null(attribute))
	{
		return(h5dump(filepath))
		return(eval(parse(text = paste('list(',trackID, '= h5dump(filepath))'))))
	}else
	{
		if(is.null(subatt))
		{
			return(eval(parse(text = paste('list(',trackID, '= h5read(filepath, name = attribute))'))))
		}else
		{
			return(eval(parse(text = paste('list(', trackID, ' = h5read(filepath, name = attribute)$', subatt, ')', sep = ""))))
		}
	}
}

attlookup = function(att)
{
	function(trackid) h5lookup(trackid, att)
}

subatt = function(subatt)
{
	function(x) return(eval(parse(text = paste('x', subatt, sep = "$"))))
}

songmeta = function(sm)
{
	return(list(Artist = sm$songs$artist_name, Song = sm$songs$title, Location = sm$songs$artist_location))
}

mdlookup = attlookup('metadata')
anlookup = attlookup('analysis')
mblookup = attlookup('musicbrainz')
terms = subatt('artist_terms')
termfreq = subatt('artist_terms_freq')
termweight = subatt('artist_terms_weight')

extrackid = sub('.h5', '', h5files[[1]][1])
attributes = lapply(h5lookup(extrackid), names)

stmusic = dbConnect(MySQL(), user = 'alga9327', password = 'alga9327', dbname = 'stmusic', host = 'bustartarus.ad.colorado.edu')
locations <- dbGetQuery(stmusic, 'SELECT latitude, longitude, count(*) FROM artistlocation GROUP BY latitude, longitude')
artistlocation <- dbGetQuery(stmusic, 'SELECT * FROM artistlocation')
tracksperyear <- dbGetQuery(stmusic, 'SELECT * FROM tracksperyear')
firstsongs <- dbGetQuery(stmusic, 'SELECT * FROM firstsongartist')

firstsonglocations = merge(artistlocation, firstsongs, by = 'trackID')

# sapply(unname(sub('.h5', '', unlist(h5files))), function(x){return(lapply(mdlookup(x), terms)[[1]][which.max(unlist(lapply(mdlookup(x), termfreq)))])}) -> trackgenres
# data.frame(names(trackgenres)[which(lapply(trackgenres, length) != 0)], unlist(trackgenres)) -> genredf
# colnames(genredf) = c('trackID', 'genre')
# rownames(genredf) = NULL
# write.table(genredf, file = "genre.csv", sep = ",", quote = F, col.names = T, row.names = F)
genredf = read.csv('genre.csv')
pal = colorFactor(palette = rainbow(354), domain = sort(unlist(unique(genredf[,2]))))

mastertable = dbGetQuery(stmusic, 'SELECT year, latitude, longitude, genre, count(*) as numtracks FROM artistlocation JOIN tracksperyear ON artistlocation.trackID = tracksperyear.trackID JOIN trackgenre ON artistlocation.trackID = trackgenre.trackID GROUP BY year, genre')

circle = function(gr)
{
	dat = subset(mastertable, genre == gr)
	if(nrow(dat) != 0)
	{
		paste("addCircles(lng = ", dat$longitude,", lat = ", dat$latitude, ", group = c('", dat$genre, "', '", dat$year,"'), radius = 20000*", dat$numtracks, ", color = pal('", dat$genre,"'), popup = '", dat$genre,"')", sep = "")
	}
}

results = sapply(unique(genredf[,2]), circle)
circleadds = paste(unlist(results), collapse = " %>% ")
bygenre = eval(parse(text = paste('leaflet() %>% addTiles() %>% ', paste(unlist(results), collapse = " %>% "), '%>% addLayersControl(baseGroups = sort(unlist(unique(genredf[,2]))))')))
allgenre = eval(parse(text = paste('leaflet() %>% addTiles() %>% ', paste(unlist(results), collapse = " %>% "), '%>% addLayersControl(overlayGroups = sort(unlist(unique(genredf[,2]))))')))