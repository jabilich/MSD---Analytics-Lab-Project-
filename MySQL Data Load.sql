use stmusic;

#==============================================================================================================================
#			Patrice's Data Load
#==============================================================================================================================

-- create table artistLocation
create table artistLocation (
artistID varchar(50),
latitude decimal(35,10),
longitude decimal(35,10),
trackID varchar(100),
artistName varchar(100)); 

-- load subset_artist_location.txt - artistLocation
LOAD DATA LOCAL INFILE '/Users/pstockover/Desktop/dataproject/MillionSongSubset/AdditionalFiles/subset_artist_location.txt'
INTO TABLE artistLocation FIELDS TERMINATED BY '<SEP>'; 

-- create table tracksPerYear
create table tracksPerYear(
year int,
trackID varchar(50),
artistName varchar(100),
songName varchar(250));

-- load subset_tracks_per_year.txt - tracksPerYear
LOAD DATA LOCAL INFILE '/Users/pstockover/Desktop/dataproject/MillionSongSubset/AdditionalFiles/subset_tracks_per_year.txt'
INTO TABLE tracksPerYear FIELDS TERMINATED BY '<SEP>'; 

-- create table firstSongArtist
create table firstSongArtist (
select artistName, songName, trackID, min(year) as Year
from tracksPerYear
group by artistName
order by Year);


#==============================================================================================================================
#			Jake's Data Load
#==============================================================================================================================


#Create uniqueTracks Table
create table if not exists  uniqueTracks (
	trackID varchar(50),
	songID varchar(50),
    artistName varchar(350),
    songName varchar(200)#,
    #primary key (trackID)
);
#load the uniqueTracks tab delimited datafile 
load data local infile 'C:\\Users/JacobBilich/Documents/MillionSongSubset/AdditionalFiles/subset_unique_tracks.txt' 	
    into table uniqueTracks
    character set latin1
    fields terminated by '<SEP>' OPTIONALLY enclosed by '"' 	
    #lines terminated by '\r\n'
    #ignore 1 lines
    ;


#select * from uniquetracks;


#Create uniqueArtists Table
create table if not exists  uniqueArtists (
	artistID varchar(50),
	artistMBID varchar(150),
    trackID varchar(200),
    artistName varchar(200)#,
    #primary key (trackID)
);
#load the uniqueArtists tab delimited datafile 
load data local infile 'C:\\Users/JacobBilich/Documents/MillionSongSubset/AdditionalFiles/subset_unique_artists.txt' 	
    into table uniqueArtists
    character set latin1
    fields terminated by '<SEP>' OPTIONALLY enclosed by '"' 	
    #lines terminated by '\r\n'
    #ignore 1 lines
    ;



#Create trackGenre Table
create table if not exists  trackGenre (
	trackID varchar(50),
	genre varchar(50)
);

#load data into the trackGenre table    
LOAD DATA LOCAL INFILE 'C:\\Users/JacobBilich/Documents/MillionSongSubset/genre.csv'
INTO TABLE trackGenre FIELDS TERMINATED BY ',' #nes terminated by '\r\n'
    ignore 1 lines; 
