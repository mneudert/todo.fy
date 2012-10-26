require: "sinatra"
require: "html"
require: "redis"

R = Redis Client new


# CONFIGURATION

configure: ['production, 'development] with: {
  enable: 'logging
}

cur_path = File absolute_path: "."
pub_path = "#{cur_path}/public"

set: 'port to: 3000
set: 'public_folder to: pub_path


# LISTS

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

def list_create: list_name {
  R rpush: ("lists", list_name)
  redirect: "/list/#{list_name}"
}


# ITEMS

def list_items: list_name {
  key = "list:#{list_name}"
  list_len = R llen: (key)

  (0 == list_len) if_true: {
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
  key = "list:#{list_name}"
  items = R lrange: (key, 0, -1)

  items map: |item_name| {
    """
    <li>
      <a href=\"/list/#{list_name}/item/#{item_name}\">#{item_name}</a>
    </li>
    """
  }
}

def item_create: list_name and: item_name and: item_description {
  list_key = "list:#{list_name}"
  item_key = "list:#{list_name}:item:#{item_name}:data"

  R rpush: (list_key, item_name)
  R hset: (item_key, "description", item_description)

  redirect: "/list/#{list_name}/item/#{item_name}"
}


# ITEM DETAILS

def item_details: list_name and: item_name {
  key = "list:#{list_name}:item:#{item_name}:data"
  has_description = R hexists: (key, "description")

  (0 == has_description) if_true: {
    """<p>Item not found.</p>"""
  } else: {
    item_description = R hget: (key, "description")

    """
    <dl>
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
    <form method=\"POST\">
      Name: <input name=\"item_name\"/><br/>
      Description: <input name=\"item_description\"/><br/>
      <input type=\"submit\" value=\"create item\"/>
    </form>
  """
}

post: "/list/:list_name" do: |list_name| {
  item_name = params["item_name"]
  item_description = params["item_description"]

  item_create: list_name and: item_name and: item_description
}

get: "/" do: {
  layout: """
    <h2>Welcome</h2>
    <p>Lists</p>
    <ul>
      #{list_lists}
    </ul>
    <form method=\"POST\">
      Name: <input name=\"list_name\"/><br/>
      <input type=\"submit\" value=\"create list\"/>
    </form>
  """
}

post: "/" do: {
  list_name = params["list_name"]
  list_create: list_name
}

not_found: {
  layout: """
    <h2>Sorry, this page does not exist :(</h2>
  """
}