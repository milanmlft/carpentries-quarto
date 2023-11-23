function setCarpentriesStyling(meta)
    -- Add general styling from CSS and JavaScript files
    quarto.doc.add_html_dependency({
        name = "carpentries-style",
        scripts = { "assets/scripts.js" },
        stylesheets = { "assets/styles.css" }
    })

    -- Include the html templates
    quarto.doc.include_file('in-header', 'templates/head.html')

end

return {
    {
        Meta = setCarpentriesStyling
    },
}
