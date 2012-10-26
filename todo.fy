require: "sinatra"
require: "html"


# CONFIGURATION

configure: ['production, 'development] with: {
  enable: 'logging
}

cur_path = File absolute_path: "."
pub_path = cur_path ++ "/../public"

set: 'port to: 3000
set: 'public_folder to: pub_path

# LAYOUT

def with_layout: body {
  HTML new: @{
    html: @{
      head: @{
        title: "ToDo.fy"
      }
      body: |h| {
        h h1: "ToDo.fy"
        body call: [h]
      }
    }
  } to_s
}


# ROUTING

get: "/" do: {
  with_layout: @{
    h2: "Welcome"
  }
}

not_found: {
  with_layout: @{
    h2: "Sorry, this page does not exist :("
  }
}