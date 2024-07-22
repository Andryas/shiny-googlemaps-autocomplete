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

    leaflet::leaflet() |>
      leaflet::addTiles() |>
      leaflet::setView(
        lng = address()[["results"]][["geometry"]][["location"]][["lng"]],
        lat = address()[["results"]][["geometry"]][["location"]][["lat"]],
        zoom = 13
      ) |>
      leaflet::addMarkers(
        lng = address()[["results"]][["geometry"]][["location"]][["lng"]],
        lat = address()[["results"]][["geometry"]][["location"]][["lat"]],
        popup = "Well done, noble warrior!"
      )
  })
}

shinyApp(ui, server)
