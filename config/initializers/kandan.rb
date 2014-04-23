Dir["#{Rails.root}/lib/broadcasters/**/*.rb"].each do |file|
  require file
end
