require 'open-uri'
require 'json'

loop do
  # Fetch upcoming launches
  data = JSON.parse(URI.open('https://api.spacexdata.com/v4/launches/upcoming').read)

  # Map to our attributes
  launches = data.map do |l|
    {
      id: l['id'],
      name: l['name'],
      time: l['date_utc'],
      youtube_id: l['links']['youtube_id'],
      wikipedia: l['links']['wikipedia'],
      patch: l['links']['patch']['large'],
    }
  end

  # Insert or update in the database
  res = Launch.upsert_all(launches)
  puts "Updated: #{res.length}"

rescue => ex
  $stderr.puts ex

ensure
  sleep 3600
end
