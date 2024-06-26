local lustache = require("lustache")

local extension = { name = "carpentries", version = "1.0.0" }

-- Add HTML dependencies for the Quarto document
-- This ensures that the necessary resource files are available in the build directory
function add_html_dependencies()
  quarto.log.debug("Adding HTML dependencies for Carpentries styling")
  quarto.doc.add_html_dependency({
    name = extension.name,
    version = extension.version,
    scripts = { "assets/scripts.js" },
    stylesheets = { "assets/styles.css" },
    resources = {
      { name = "favicon-32x32.png", path = "assets/icons/favicon-32x32.png" },
      { name = "favicon-16x16.png", path = "assets/icons/favicon-16x16.png" },
      { name = "site.webmanifest",  path = "assets/site.webmanifest" },
      -- Copy over all assets
      { name = "assets",            path = "assets" }
    }
  })
end

-- Read HTML template file
-- From https://github.com/coatless/quarto-webr/blob/f81f1b51a3c620841602eb0bc429f8f45df3d84a/_extensions/webr/webr.lua
function read_template_file(template)
  local path = quarto.utils.resolve_path("templates/" .. template)
  local file = io.open(path, "r")

  -- Check if null pointer before grabbing content
  if not file then
    error("\nWe were unable to read the template file `" .. template .. "` from the extension directory.\n\n")
    return nil
  end

  -- *a or *all reads the whole file
  local content = file:read "*a"

  file:close()
  return content
end

function render_template(template, context)
  local content = read_template_file(template)
  return lustache:render(content, context)
end

function setCarpentriesStyling(meta)
  local meta_carpentries = meta.carpentries -- loads the carpentries metadata from _quarto.yml

  add_html_dependencies()

  -- Create a table of variables to pass to the templates
  local carpentries_vars = {
    yaml = {}, -- Variables from _quarto.yml metadata
    site = {   -- title and file paths for site component
      title = pandoc.utils.stringify(meta.title),
      root = "site_libs/quarto-contrib/" .. extension.name .. "-" .. extension.version .. "/",
      assets = "_extensions/carpentries/assets/",
    }
  }

  -- Populate the carpentries_vars.yaml table with the metadata, read from _quarto.yml
  for k, v in pairs(meta_carpentries) do
    if type(v) == "table" then
      v = pandoc.utils.stringify(v)
    end
    carpentries_vars.yaml[k] = v
  end

  -- Render HTML templates
  local head = render_template("head.html", carpentries_vars)
  local header = render_template("header.html", carpentries_vars)
  local footer = render_template("footer.html", carpentries_vars)

  -- Include the html templates
  quarto.doc.include_text('in-header', head)
  quarto.doc.include_text('in-header', header)
  quarto.doc.include_text('after-body', footer)
end

return {
  {
    Meta = setCarpentriesStyling
  },
}
