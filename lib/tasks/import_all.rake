# coding: utf-8
namespace :import do
  task :all => :environment do
    Decidim::Organization.delete_all

    Decidim::Organization.create!(
      name: "participa.gavaciutat.cat",
      host: "decidim-gava.herokuapp.com",
      available_locales: ["ca", "es"],
      default_locale: "ca",
      remote_homepage_image_url: "https://github.com/AjuntamentdeBarcelona/decidim.barcelona/raw/master/app/assets/images/hero-home.jpg",
      remote_logo_url: "https://i.imgur.com/tHG04IS.png",
      twitter_handler: "decidimbcn",
      favicon: File.new(Rails.root.join("app", "assets", "images", "barcelona", "favicon.png")),
      welcome_text: {
        ca: "Decidim la Gavà que volem",
        es: "Decidamos la Gavà que queremos"
      },
      description: {
        ca: "Benvingut/da a la plataforma de participació de Gavà.
Construïm una ciutat més oberta, transparent i col·laborativa.
Entra, participa i decideix",
        es: "Bienvenido/a a la plataforma de participación de Gavà.
Contruyamos una ciudad más abierta, transparente y colaborativa.
Entra, participa y decide."
      }
    )

    puts "Importing pages..."
    Rake::Task["import:pages"].invoke

    puts "Importing users..."
    Rake::Task["import:users"].invoke

    puts "Importing user groups..."
    Rake::Task["import:user_groups"].invoke

    puts "Importing scopes.."
    Rake::Task["import:scopes"].invoke

    puts "Importing processes..."
    Rake::Task["import:processes"].invoke

    puts "Importing categories..."
    Rake::Task["import:categories"].invoke

    puts "Importing proposals..."
    Rake::Task["import:proposals"].invoke

    puts "Importing proposal votes..."
    Rake::Task["import:proposal_votes"].invoke

    puts "Importing results..."
    Rake::Task["import:results"].invoke

    puts "Importing debates..."
    Rake::Task["import:debates"].invoke

    puts "Importing proposals..."
    Rake::Task["import:meetings"].invoke

    puts "Importing comments..."
    Rake::Task["import:comments"].invoke

    # puts "Data importing finished! Let's update attachments now - that could take a while!"

    # puts "Importing attachments..."
    # Rake::Task["import:attachments"].invoke

    # puts "Importing meeting attachments..."
    # Rake::Task["import:meeting_attachments"].invoke
  end
end
