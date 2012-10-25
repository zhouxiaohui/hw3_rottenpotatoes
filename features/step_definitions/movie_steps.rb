# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  Movie.delete_all
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    m = Movie.new
    m.title = movie['title']
    m.rating = movie['rating']
    m.release_date = movie['release_date']
    m.save!
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  ie1 = page.body.index e1
  ie2 = page.body.index e2
  if ie1.nil? or ie2.nil? or ie1 > ie2
    raise 'Wrong order of movie listing'
  end
end

# Make sure we can see all the movies

Then /I should see all of the movies/ do
  # Count all table rows
  if page.body.scan("<tr>").length != Movie.count()+1
    raise 'Wrong number of movies'
  end
end

# Make sure we can see all the movies of the specified ratings

Then /I should see all movies of the ratings: (.*)$/ do |rating_list|
  rating_list.split(',').each do |rating|
    Movie.find_all_by_rating(rating.strip).each do |movie|
      if not page.body =~ /#{movie.title}/
        raise "Expecting but found no movie title: #{movie.title}"
      end
    end
  end
end

# Make sure we cannot see any movies of the specified ratings

Then /I should not see any movies of the ratings: (.*)$/ do |rating_list|
  rating_list.split(',').each do |rating|
    Movie.find_all_by_rating(rating.strip).each do |movie|
      if page.body =~ /#{movie.title}/
        raise "Not expecting but found movie title: #{movie.title}"
      end
    end
  end
end

#
# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

Given /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  rating_list.split(',').each do |rating|
    step %{I #{uncheck}check "ratings_#{rating.strip}"}
  end
end

