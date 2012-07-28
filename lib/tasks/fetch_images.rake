require 'open-uri'

namespace :map do

  desc 'fetch the images for the map'
  task :fetch_images => :environment do

    base_url = "http://static.dayzdb.com/tiles"

    zoom_levels = [
      [1, 1],
      [3, 3],
      [7, 6],
      [15, 13],
      [31, 26],
      [63, 53]
    ]

    create_dir('tiles')

    zoom_levels.each_with_index do |z, zoom|

      create_dir("/tiles/#{zoom+1}")

      (0..z[0]).to_a.each do |x|
        (0..z[1]).to_a.each do |y|

          filename = "#{zoom+1}/#{x}_#{y}.png"
          target_file = File.join(Rails.root, '/app/assets/images/tiles', filename)
          source_file = File.join(base_url, filename)

          puts source_file
          open(target_file, 'wb') do |file|
            file << open(source_file).read
          end
          puts "saved file #{source_file}"
        end
      end
    end

    puts "Done."
  end

end

def create_dir(dirname)
  dir = File.join(Rails.root, "/app/assets/images/#{dirname}")
  Dir.mkdir(dir, 0700) unless Dir.exists?(dir)
end
