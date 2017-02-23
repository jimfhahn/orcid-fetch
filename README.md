
# orcid-fetch

Simple Ruby script to fetch publication data from ORCID, flatten it, and write the results to a csv file.

# how to use it

- Clone this repo.

- Run `bundle install`

- Edit the `orcids.txt` file, entering the ORCIDs you want to download data for.

- Run `bundle exec ./orcid-fetch.rb` 

- The results will be in `publications.csv`

- Note that data downloaded from the API will be cached in the `data/`
  directory for subsequent executions of the program; if you want to
  clear out this data, simply delete the files in the directory.
