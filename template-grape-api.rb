@app_name = File.basename(destination_root)
insert_into_file "#{@app_name}.gemspec", '  s.add_dependency "grape", "~> 0.10.1"', after: /add_dependency "rails".*\n/
## TODO: Add more, config for rails, etc.
