set -e
bundle exec rake db:drop db:create db:schema:load
bundle exec rake import:all
heroku pg:reset --app decidim-gava --confirm decidim-gava
heroku pg:push decidim-gava_development DATABASE_URL
