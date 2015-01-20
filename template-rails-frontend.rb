@app_name = File.basename(destination_root)
insert_into_file "#{@app_name}.gemspec", '  s.add_dependency "simple_form", "~> 3.0.0"', after: /add_dependency "rails".*\n/
