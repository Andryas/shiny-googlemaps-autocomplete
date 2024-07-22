library(shiny)
library(shinyjs)

source("googlemap_autocomplete.R")

ui <- fluidPage(
  useShinyjs(),
  includeCSS("www/custom.css"),

  googlemap_autocomplete_ui(
    "test",
    width = "100%", 
    key = Sys.getenv("GCP_TOKEN_MAPS")
  ),
  
  leaflet::leafletOutput(
    "map", 
    width = "auto", 
    height = "auto"
  )
)

server <- function(input, output, session) {
  address <- googlemap_autocomplete_server(
    "teste",
    key = Sys.getenv("GCP_TOKEN_MAPS")
  )

  output$map <- leaflet::renderLeaflet({
    shiny::req(address())

    shinyjs::runjs('$("#map").width(500).height(500);')

    results <- address()[["results"]]

    lng <- results[["geometry"]][["location"]][["lng"]]
    lat <- results[["geometry"]][["location"]][["lat"]]

    leaflet::leaflet() |>
      leaflet::addTiles() |>
      leaflet::setView(
        lng = lng,
        lat = lat,
        zoom = 13
      ) |>
      leaflet::addMarkers(
        lng = lng,
        lat = lat,
        popup = "Well done, noble warrior!"
      )
  })
}

shinyApp(ui, server)
