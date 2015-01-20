gem 'foreman', version: '~> 0.75'
gem 'bootstrap-sass', '~> 3.3.1'
gem 'autoprefixer-rails'
gem 'devise', "~> 3.4.1"
gem 'pundit', "~> 0.3.0"
gem 'use_case', "~> 1.0.2"
gem 'reform', "~> 1.2.5"
gem 'virtus', "~> 1.0.4"
gem 'haml-rails', "~> 0.7.0"
gem 'bootstrap-sass-extras', "~> 0.0.6"

uncomment_lines 'Gemfile', /gem 'bcrypt'/

gem_group(:development, :test) do
  gem "mail_safe"
  gem "rspec"
  gem "rspec-rails"
  gem "capybara"
  gem "database_cleaner"
  gem "spring-commands-rspec"
end

create_file "Procfile" do
  file_lines = []
  file_lines << "db: bin/local_postgres.sh"
  file_lines << "web: bin/rails s"
  file_lines.join("\n")
end

after_bundle do
  # Bootstrap
  remove_file "app/assets/stylesheets/application.css"
  create_file "app/assets/stylesheets/application.css.scss", <<-CONENT
  @import "bootstrap-sprockets";
  @import "bootstrap";

  body {
    margin-top: 50px;
  }
  CONENT
  insert_into_file "app/assets/javascripts/application.js",
    before: "//= require_tree .\n" do 
    "//= require bootstrap-sprockets\n"
  end

  generate "bootstrap:install"
  remove_file "app/views/layouts/application.html.erb"
  generate "bootstrap:layout application fluid"

  # Static page controller & default route:
  generate "controller static_page home"
  route "root 'static_page#home'"

  # Rspec
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

  # Devise
  generate "devise:install"
  generate "devise User"

  # Pundit
  generate "pundit:install"

  # Ignore rails doc files, Vim/Emacs swap files, .DS_Store, and more
  # ===================================================
  run "cat << EOF >> .gitignore
/.bundle
/db/*.sqlite3
/db/*.sqlite3-journal
/log/*.log
/tmp
database.yml
doc/
*.swp
*~
.project
.idea
.secret
.DS_Store
EOF"

  # Postgres:
  append_to_file ".gitignore", "vendor/postgresql"
  copy_file File.expand_path("../templates/local_postgres.sh", __FILE__), "bin/local_postgres.sh"
  chmod "bin/local_postgres.sh", "+x"

  # Migrations:
  with_db do
    ['development', 'test'].each do |env|
      rake "db:create", env: env

      # Only bother running migrations if we've setup any:
      if Dir.exist? "db/migrate"
        rake "db:migrate", env: env
      end
    end
  end

  # Git:
  git :init
  git add: "."
  git commit: "-m 'Core app generated!'"
end

def with_db(options = {})
  options[:sleep] ||= 3
  db_pid = fork do
    exec "foreman start db"
  end

  sleep options[:sleep]
  begin
    yield
  ensure
    Process.kill("TERM", db_pid)
  end
end

