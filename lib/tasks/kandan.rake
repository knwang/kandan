namespace :kandan do
  desc "Bootstrap an initial install of Kandan. Not strictly necessary, but faster."
  task :bootstrap => :environment do

    # Initialize default settings
    Setting.my_settings

    user = User.first

    if user.nil?
      puts "Creating default user..."
      user = User.new
      user.email      = "admin@gotealeaf.com"
      user.username  = "admin"
      user.first_name = "Tealeaf"
      user.last_name  = "Admin"
      user.is_admin = true
      user.save!
    else
      # Doing some cleanup if this is an upgrade instead of a new DB
      
      # Users that were already in the database with no registration status will be added as active
      User.where("registration_status IS NULL").each do |user|
        user.activate!
      end

      # If there is no admin we will try to find a user with username admin and make it an admin. Otherwise we will
      # alert the user
      if User.where(:is_admin => true).count == 0
        admin = User.where(:username => "admin").first

        if admin
          admin.is_admin = true
          admin.save!
        else
          puts "\e[31mIt looks like there are no admins in your database. Run rake kandan:add_admin_user\e[0m"
        end
      end

    end

    channel = Channel.first

    if channel.nil?
      puts "Creating default channel..."
      channel = Channel.create! name: 'Lobby', user: user
    end
  end

  desc "Creates the default hubot account."
  task :boot_hubot => :environment do
    user = User.find_by_email("hubot@kandanapp.com")

    if user.nil?
      puts "Creating hubot user..."

      password = ""
      128.times { password << (('a'..'z').to_a + ('A'..'Z').to_a + ['!','@','#','$','%','^','&','*','(',')'].to_a).sample }

      hubot = User.new
      hubot.email      = "hubot@kandanapp.com"
      hubot.username   = "hubot"
      hubot.first_name = "Hubot"
      hubot.last_name  = "vonGithubben"
      hubot.password   = password            if hubot.respond_to?("password=".to_sym)
      hubot.password_confirmation = password if hubot.respond_to?("password_confirmation=".to_sym)
      hubot.save!
    end
  end

  desc "Output the hubot access key"
  task :hubot_access_key => :environment do
    if authentication_token = User.find_by_email("hubot@kandanapp.com").try(:authentication_token)
      puts "Your hubot access key is #{ authentication_token }"
    else
      puts "There's not hubot account. Run rake kandan:boot_hubot to create a bot account."
    end
  end

  desc "Adds an admin based on a username if there are no admins in kandan"
  task :add_admin_user => :environment do 
    if User.count == 0
      puts "\e[31mThere are no users on your kandan DB. Try running rake kandan:bootstrap first\e[0m"
    elsif User.where(:is_admin => true).count != 0
      puts "\e[32mLooks like you already have an admin. Nothing to do here.\e[0m"
    else
      username = ""
      exit_word = "EXIT"
      done = false

      while not done 
        puts "Enter the email address of your admin user or type '#{exit_word}' to cancel this script"
        answer = (STDIN.gets).delete("\n")

        if answer == exit_word
          puts "Ok. We forgive you. Carry on....."
          done = true
        elsif user = User.where(:username => answer).first
          user.is_admin = true
          user.save!

          puts "Done. #{user.full_name_or_username} is now admin!"

          done = true
        else
          puts "User not found. Let's try that again."
        end
      
      end
    
    end
  end
end
