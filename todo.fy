require: "sinatra"
require: "html"
require: "redis"

R = Redis Client new


# CONFIGURATION

configure: ['production, 'development] with: {
  enable: 'logging
}

cur_path = File absolute_path: "."
pub_path = cur_path ++ "/public"

set: 'port to: 3000
set: 'public_folder to: pub_path


# DEMO DATA

R del: ('lists_list)
R rpush: ('lists_list, "one")
R rpush: ('lists_list, "two")
R rpush: ('lists_list, "three")


# LIST OF TODO LISTS
def list_lists {
  lists = R lrange: ('lists_list, 0, -1)
  lists map: |entry| { list_lists_entry: entry }
}

def list_lists_entry: name {
  """
  <li>
    <a href=\"/list/#{name}\">#{name}</a>
  </li>
  """
}


# LAYOUT

def layout: body {
  """
  <html>
    <head>
      <title>ToDo.fy</title>
    </head>
    <body>
      <h1>ToDo.fy</h1>
      #{body}
    </body>
  </html>
  """
}


# ROUTING

get: "/" do: {
  layout: """
    <h2>Welcome</h2>
    <p>Lists</p>
    <ul>
      #{list_lists}
    </ul>
  """
}

not_found: {
  layout: """
    <h2>Sorry, this page does not exist :(</h2>
  """
}