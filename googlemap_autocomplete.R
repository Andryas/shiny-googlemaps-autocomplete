googlemap_autocomplete_ui <- function(
  id, label = "Type an address", width = NULL, 
  placeholder = NULL, key = NULL, ...) {
  if (is.null(key)) key <- Sys.getenv("GCP_TOKEN_MAPS")

  ns <- NS(id)
  button <- ns("button")
  jsValue <- ns("jsValue")
  jsValueAddressNumber <- ns("jsValueAddressNumber")
  jsValuePretty <- ns("jsValuePretty")
  jsValueCoords <- ns("jsValueCoords")

  script <- stringr::str_c("
    <script>
        function initAutocomplete() {

        var autocomplete =   new google.maps.places.Autocomplete(document.getElementById('${button}'),{types: ['geocode']});
        autocomplete.setFields(['address_components', 'formatted_address',  'geometry', 'icon', 'name']);
        autocomplete.addListener('place_changed', function() {
        var place = autocomplete.getPlace();
        if (!place.geometry) {
            return;
        }

        var addressPretty = place.formatted_address;
        var address = '';
        if (place.address_components) {
        address = [
        (place.address_components[0] && place.address_components[0].short_name || ''),
        (place.address_components[1] && place.address_components[1].short_name || ''),
        (place.address_components[2] && place.address_components[2].short_name || ''),
        (place.address_components[3] && place.address_components[3].short_name || ''),
        (place.address_components[4] && place.address_components[4].short_name || ''),
        (place.address_components[5] && place.address_components[5].short_name || ''),
        (place.address_components[6] && place.address_components[6].short_name || ''),
        (place.address_components[7] && place.address_components[7].short_name || '')
        ].join(' ');
        }
        var address_number =''
        address_number = [(place.address_components[0] && place.address_components[0].short_name || '')]
        var coords = place.geometry.location;
        //console.log(address);
        Shiny.onInputChange('${jsValue}', address);
        Shiny.onInputChange('${jsValueAddressNumber}', address_number);
        Shiny.onInputChange('${jsValuePretty}', addressPretty);
        Shiny.onInputChange('${jsValueCoords}', coords);});}
    </script>
    <script src='https://maps.googleapis.com/maps/api/js?key=${key}&libraries=places&callback=initAutocomplete' async defer></script>"
  )
  script <- stringr::str_interp(script)
  script <- stringr::str_replace_all(script, "\\s+", "")

  shiny::tagList(
    htmltools::div(
      id = stringr::str_c(button, "-layout"),
      shiny::textInput(
        inputId = button,
        label = label, 
        width = width, 
        placeholder = placeholder
      ),
      htmltools::HTML(script),
      ...
    )
  )
}

googlemap_autocomplete_server <- function(id, key = NULL) {
  if (is.null(key)) key <- Sys.getenv("GCP_TOKEN_MAPS")

  shiny::moduleServer(
    id,
    function(input, output, session) {
      my_address <- shiny::reactive({
        if (!is.null(input$jsValueAddressNumber)) {
          if (length(grep(
              pattern = input$jsValueAddressNumber, 
              x = input$jsValuePretty
            )) == 0) {
            final_address <- c(
              input$jsValueAddressNumber, 
              input$jsValuePretty
            )
          } else {
            final_address <- input$jsValuePretty
          }
          return(final_address)
        }
      })

      address <- reactive({
        shiny::req(my_address())
        result <- googleway::google_geocode(
          address = my_address(), 
          key = key
        )
        return(result)
      })

      address
    }
  )
}
