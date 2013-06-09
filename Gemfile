source 'http://rubygems.org'

gem 'rails', '3.2.11'

gem 'aws-sdk'
gem 'bitly'
gem 'cancan'
gem 'devise', '1.5.3'
gem 'hoptoad_notifier'
gem 'innsights', :github => 'innku/innsights-gem'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'koala'
gem 'metropoli', :github => 'e3matheus/metropoli', :branch => 'feature_country_and_cities_autocomplete'
gem 'nifty-generators'
gem 'paperclip'
gem 'rake'
gem 'RedCloth'
gem 'thin'
gem 'twitter'
gem 'will_paginate'

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'sass-rails',  '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
end

group :production, :staging do
  gem 'newrelic_rpm'
  gem 'pg'
end

group :development, :test, :staging do 
  gem 'factory_girl_rails'
end

group :development, :test do 
  gem 'capybara', '1.1.1'
  gem 'database_cleaner'
  gem 'debugger'
  gem 'konacha'
  gem 'launchy'
  gem 'rspec-rails', '2.8.1'
  gem 'selenium-webdriver'
  gem 'spork'
  gem 'sqlite3'
  gem 'unicorn-formatter'
end

group :test do
  gem 'cucumber-rails'
  gem 'mocha'
end
