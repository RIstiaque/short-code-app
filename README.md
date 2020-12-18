# Intial Setup

    docker-compose build
    docker-compose up mariadb
    docker-compose run short-app rails db:migrate
    docker-compose -f docker-compose-test.yml build

# To run migrations

    docker-compose run short-app rails db:migrate
    docker-compose -f docker-compose-test.yml run short-app-rspec rails db:test:prepare

# To run the specs

    docker-compose -f docker-compose-test.yml run short-app-rspec

# Run the web server

    docker-compose up

# Adding a URL

    curl -X POST -d "full_url=https://google.com" http://localhost:3000/short_urls.json

# Getting the top 100

    curl localhost:3000

# Checking your short URL redirect

    curl -I localhost:3000/abc

# Algorithm governing ShortCode

The goal of a shortcode is to generate the smallest possible shortcode by using the current number of records in the database. In mariadb, every record has an (integer) identifier that automatically increments each newly created record, so by using a ShortUrl's current ID we can map it to a unique key.

We can convert the entry ID (hereby known as id) into a unique character key of known length by recursively dividing the value of the id by the length of the key. We would construct the shortcode by using the CHARACTER's array with the remainder as the index, and then let the id be equal to the quotient. This process ends when the id reaches 0.

Using recursion we can see faster results than its iterative counterpart up until the number of urls in the database nears 1 billion.

<Strong>Please Note:</Strong>
When testing on paper, I found that the shortest possible code for a record of 1 should be the first entry of the character key which is 0, because these ID's do not start at 0 (for mariadb). Therefore, in order to pass all the original tests, I took out initially subtracting one to the ID. I believe that the correct way to write this would be to first subtract one from the ID to start with, and then do the process explained above - but the tests did not agree.
