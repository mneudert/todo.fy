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

R del: ('lists)
R rpush: ('lists, "one")
R rpush: ('lists, "two")
R rpush: ('lists, "three")

R del: ('one)
R rpush: ('one, "i_one_1")

R del: ('two)
R rpush: ('two, "i_two_1")
R rpush: ('two, "i_two_2")

R del: ('three)
R rpush: ('three, "i_three_1")
R rpush: ('three, "i_three_2")
R rpush: ('three, "i_three_3")


# LIST OF TODO LISTS

def list_lists {
  len = R llen: ('lists)

  if: (0 == len) then: {
    """<p>No lists (yet)</p>"""
  } else: {
    lists = R lrange: ('lists, 0, -1)
    lists map: |list_name| {
      """
      <li>
        <a href=\"/list/#{list_name}\">#{list_name}</a>
      </li>
      """
    }
  }
}


# LIST OF LIST ITEMS

def list_items: list_name {
  len = R llen: (list_name)

  if: (0 == len) then: {
    """<p>No items in this list (yet)"""
  } else: {
    """
    <p>Items</p>
    <ul>
      #{list_items_list: list_name}
    </ul>
    """
  }
}

def list_items_list: list_name {
  items = R lrange: (list_name, 0, -1)
  items map: |item_name| {
    """
    <li>
      <a href=\"/list/#{list_name}/item/#{item_name}\">#{item_name}</a>
    </li>
    """
  }
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

get: "/list/:list_name" do: |list_name| {
  layout: """
    <h2>ToDo List: #{list_name}</h2>
    #{list_items: list_name}
  """
}

not_found: {
  layout: """
    <h2>Sorry, this page does not exist :(</h2>
  """
}