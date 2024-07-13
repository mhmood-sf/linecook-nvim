# linecook-nvim

> A plugin to cook your own statusline.

Note that this is not really a statusline plugin, it is more of a library that
makes it easier to style and compose your own statusline. It is more
lower-level than usual statusline plugins, and you will have to implement much
of the functionality yourself. If you need more advanced functionality (refresh
timers, lazy loading, event handling, etc.) then it is recommended to use a
more fully-featured plugin.

## Installation

This plugin requires Neovim version `0.9.5` or above. To install, use your
favorite plugin manager.

## Usage

There are just three main concepts:
- components
- containers
- the rendering function

Components are just functions that return strings that are joined together and
passed on to the `statusline` option. For example, a function that returns the
current mode, or the current filetype, and so on. These are the main building
blocks in this plugin. These functions can also take an input that contains
useful information about the statusline they are associated with.

Containers are *also* functions that return strings, but they also take an
input string. The idea is that containers take whatever value is to be
displayed on the statusline, and add some styling around it. Components can
then apply containers to a value right before returning it in order to apply
styles.

Finally, the rendering function (believe it or not, also a function that
returns a string) runs each component, concatenates its results, and returns
the final statusline string.

This plugin provides extra utilities to make it easier to build each of the
above and combine them together.

## Examples

The following is a very simple component (note we ignore the input for now):
```lua
local function myModeComponent(_stl)
    return string.upper(vim.fn.mode())
end
```

This component will indicate the current mode, in uppercase. Let's add some
styling to it, using `mk_container`:
```lua
local lc = require("linecook")
local myModeContainer = lc.mk_container {
    name = "myModeContainer",
    style = { fg = "black", bg = "white" },
}
```

This container will apply a black-on-white style to its content. To apply it,
we need to modify the component:
```diff
 local function myModeComponent(_stl)
-    return string.upper(vim.fn.mode())
+    return myModeContainer(string.upper(vim.fn.mode()))
 end
```

Let's add a separator to the right side, and some padding to make it look nicer:
```diff
local myModeContainer = linecook.mk_container {
     name = "myModeContainer",
     style = { fg = "black", bg = "white" },
+    left = { pad = 1 },
+    right = {
+        sep = "",
+        pad = 1,
+        style = { fg = "white" }
+    }
 }
```

We'll make another component to show the filetype:
```lua
local function myFtComponent(stl)
    return vim.api.nvim_buf_get_option(stl.bufnr, "filetype")
end
```

Note that this time we do make use of the input parameter. `stl.bufnr` is the
handle for the buffer in the current window associated with the statusline. We
use this to get the filetype.

This time we'll create a container for the component using the helpers provided:
```lua
local lc_containers = require("linecook.containers")

local myFtContainer = lc_containers.plain("myFtContainer", {
    fg = "black", bg = "white"
})
```

The "plain" container does not use any fancy separators, and just colors the
content of the component. Now we update the component:
```diff
local function myFtComponent()
-    return vim.api.nvim_buf_get_option(stl.bufnr, "filetype")
+    return myFtContainer(vim.api.nvim_buf_get_option(stl.bufnr, "filetype"))
end
```

Finally, to render the statusline, we need to first get the renderer function:
```lua

local lc_components = require("linecook.components")

local render = linecook.mk_renderer {
    myModeContainer,
    -- Divides the statusline into left/right parts by inserting a "%="
    -- See `:h statusline`
    lc_components.divider,
    myFtComponent,
}

vim.o.stl = "%!v:lua.require'<this_module>'.render()"

return { render = render }
```

`mk_renderer` takes a list of components and returns a function that will
render the statusline. To use this, we need to set the `statusline` (or `stl`)
option to `%!v:lua.require'<this_module>'.render()`, where `<this_module>` is
the location of the current module. You also need to return the render function
so that it can be accessed in the statusline.
