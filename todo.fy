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

R del: ("lists")
R rpush: ("lists", "one")
R rpush: ("lists", "two")
R rpush: ("lists", "three")

R del: ("list:one")
R rpush: ("list:one", "i_one_1")

R del: ("list:two")
R rpush: ("list:two", "i_two_1")
R rpush: ("list:two", "i_two_2")

R del: ("list:three")
R rpush: ("list:three", "i_three_1")
R rpush: ("list:three", "i_three_2")
R rpush: ("list:three", "i_three_3")

R hset: ("list:one:item:i_one_1:data", "title", "item one 1")
R hset: ("list:one:item:i_one_1:data", "description", "description one 1")


# LIST OF LISTS

def list_lists {
  key = "lists"
  len = R llen: (key)

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
  key = "list:" ++ list_name
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
  key = "list:" ++ list_name
  items = R lrange: (key, 0, -1)

  items map: |item_name| {
    """
    <li>
      <a href=\"/list/#{list_name}/item/#{item_name}\">#{item_name}</a>
    </li>
    """
  }
}


# ITEM DETAILS

def item_details: list_name and: item_name {
  key = "list:" ++ list_name ++ ":item:" ++ item_name ++ ":data"
  has_title = R hexists: (key, "title")
  has_description = R hexists: (key, "description")

  (0 == has_title) if_true: {
    """<p>Item not found.</p>"""
  } else: {
    item_title = R hget: (key, "title")
    item_description = R hget: (key, "description")

    """
    <dl>
      <dt>Title</dt>
      <dd>#{item_title}</dd>
      <dt>Description</dt>
      <dd>#{item_description}</dd>
    </dl>
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

get: "/list/:list_name/item/:item_name" do: |list_name item_name| {
  layout: """
    <h2>#{list_name}: #{item_name}</h2>
    #{item_details: list_name and: item_name}
  """
}

get: "/list/:list_name" do: |list_name| {
  layout: """
    <h2>ToDo List: #{list_name}</h2>
    #{list_items: list_name}
  """
}

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