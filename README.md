# Timelapse bubble map of protests in Europe based on ACLED data

Many users on social media have asked me how to make an animated bubble map. In this repo I provide <150 lines of R code and Armed Conflict Location & Event Data Project (ACLED) data to show you how to create a timelapse map of European protests between April 2020 and April 2021.

The data on protests originate from ACLED www.acleddata.com. I downloaded the dataset in csv format from https://developer.acleddata.com/ using my user credentials and assigned API key. If you are already registered at ACLED's website, I suggest either downloading the dataset from the website using your own API key or trying out Chris Dworschak's R library acled.api. Unfortunately, my user rights do not allow for using this package so I downloaded the dataset from the ACLED website.

The shapefile of Europe comes from ehttp://tapiquen-sig.jimdofree.com. Carlos Efraín Porto Tapiquén. Geografía, SIG y Cartografía Digital. Valencia, Spain, 2020.
