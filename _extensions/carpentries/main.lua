return {
    {
        Meta = function(meta)
            quarto.doc.add_html_dependency({
                name = "carpentries-lesson",
                scripts = {"assets/scripts.js"},
                stylesheets = {"assets/styles.css"}
            })
        end
    }, {
        -- Header = function(el)
        --     quarto.log.output("=== Handling Header ===")
        --     quarto.log.output(el)
        -- end
    }
}
