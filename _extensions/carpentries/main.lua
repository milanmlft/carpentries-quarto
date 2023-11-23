-- luarocks install lustache
-- https://github.com/Olivine-Labs/lustache
-- Run `eval "$(luarocks path)"` to add luarocks to path for Quarto to find
local lustache = require 'lustache'

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
    local meta_carpentries = meta.carpentries

    -- Create a table of variables to pass to the templates
    local carpentries_vars = {
        yaml = {}, -- Variables from _quarto.yml metadata
        site = {   -- title and file paths for site component
            title = pandoc.utils.stringify(meta.title),
            root = "",
            assets = "_extensions/carpentries/assets/",
        }
    }

    for k, v in pairs(meta_carpentries) do
        if type(v) == "table" then
            v = pandoc.utils.stringify(v)
        end
        carpentries_vars.yaml[k] = v
    end

    -- Add general styling from CSS and JavaScript files
    quarto.doc.add_html_dependency({
        name = "carpentries-style",
        scripts = { "assets/scripts.js" },
        stylesheets = { "assets/styles.css" }
    })

    -- Render HTML templates
    local head = render_template("head.html", carpentries_vars)
    local test = render_template("header.html", carpentries_vars)

    -- Include the html templates
    quarto.doc.include_text('in-header', head)
    quarto.doc.include_text('in-header', test)
end

return {
    {
        Meta = setCarpentriesStyling
    },
}
