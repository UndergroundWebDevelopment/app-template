To use this template, call `rails new` and use the --template option. We recommend 
also using the -T option to disable TestUnit, as the template will install and
configure RSpec. We also recommend --database=postgres, the template will
configure a foreman script to make runing a local, development only postgress
DB easy.

`rails new --database=postgres --template TEMPLATE_PATH -T APP_PATH`

TEMPLATE_PATH ought to point towards the template.rb file.
APP_PATH should be desired location of the generated app.
