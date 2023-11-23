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

local carpentries_vars = {

}

function render_template(template, context)
    local content = read_template_file(template)
    return lustache:render(content, context)
end

function setCarpentriesStyling(meta)
    local meta_carpentries = meta.carpentries

    -- Create a table of variables to pass to the template
    local carpentries_vars = {}
    for k, v in pairs(meta_carpentries) do
        carpentries_vars[k] = pandoc.utils.stringify(v)
    end

    quarto.log.output(carpentries_vars)

    -- Add general styling from CSS and JavaScript files
    quarto.doc.add_html_dependency({
        name = "carpentries-style",
        scripts = { "assets/scripts.js" },
        stylesheets = { "assets/styles.css" }
    })

    -- Render HTML templates
    local head = render_template("head.html", carpentries_vars)
    local test = render_template("test.html", carpentries_vars)

    -- Include the html templates
    quarto.doc.include_text('in-header', head)
    -- quarto.doc.include_file('in-header', 'templates/head.html')
    quarto.doc.include_file('before-body', 'templates/test.html')
end

return {
    {
        Meta = setCarpentriesStyling
    },
}
