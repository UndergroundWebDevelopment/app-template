gem "rom-sql", '~> 0.3.2'
gem "rom-rails", '~> 0.2.1'

gem_group(:development, :test) do
  gem "rspec"
  gem "rspec-rails"
  gem "capybara"
  gem "database_cleaner"
  gem "spring-commands-rspec"
end

gem 'foreman', version: '~> 0.75'
create_file "Procfile" do
  file_lines = []
  file_lines << "db: bin/local_postgres.sh"
  file_lines << "web: bin/rails s"
  file_lines.join("\n")
end

application "require 'rom-rails'"

run 'bundle'

generate "rspec:install"

gsub_file "spec/rails_helper.rb",
  "config.use_transactional_fixtures = true",
  "config.use_transactional_fixtures = false"

insert_into_file "spec/rails_helper.rb",
  after: "config.use_transactional_fixtures = false\n" do
  <<-CONTENT

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  CONTENT
end

after_bundle do

  # Postgres:
  append_to_file ".gitignore", "vendor/postgresql"
  copy_file File.expand_path("../templates/local_postgres.sh", __FILE__), "bin/local_postgres.sh"
  chmod "bin/local_postgres.sh", "+x"

  # Git:
  git :init
  git add: "."
  git commit: "-m 'Core app generated!'"
end
