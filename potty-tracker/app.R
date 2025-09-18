library(shiny)
library(bslib)
library(shinychat)
library(ellmer)
library(DT)
library(plotly)
library(dplyr)
library(lubridate)
library(reactable)

# Constants ---------------------------------------------------------------
HOURS_FOR_RECENT_DATA <- 24
DAYS_FOR_PROGRESS_CHART <- 7
CHART_HEIGHT <- "300px"
TABLE_HEIGHT <- 400

# Helper functions --------------------------------------------------------
load_or_create_data <- function() {
  if (file.exists("potty_data.rds")) {
    readRDS("potty_data.rds")
  } else {
    # Generate realistic simulated data
    generate_simulated_data()
  }
}

generate_simulated_data <- function() {
  # Generate data for the past 10 days with realistic improvement patterns
  start_date <- Sys.time() - days(10)
  end_date <- Sys.time()

  # Create a sequence of times throughout each day (roughly every 1-3 hours)
  times <- seq(from = start_date, to = end_date, by = "90 min")

  data_list <- list()

  for (i in seq_along(times)) {
    current_time <- times[i]
    day_progress <- as.numeric(difftime(current_time, start_date, units = "days")) / 10

    # Skip some nighttime events (between 10 PM and 6 AM)
    hour <- hour(current_time)
    if (hour >= 22 || hour <= 6) {
      if (runif(1) > 0.3) next  # 70% chance to skip nighttime events
    }

    # Henry's improvement: starts at ~40% success, improves to ~65%
    henry_base_success <- 0.40 + (day_progress * 0.25)
    # Add some daily variation and time-of-day effects
    henry_success_prob <- henry_base_success +
      rnorm(1, 0, 0.1) +  # daily variation
      ifelse(hour >= 8 && hour <= 20, 0.1, -0.1)  # better during day
    henry_success_prob <- pmax(0, pmin(1, henry_success_prob))

    # Penelope's improvement: starts at ~50% success, improves to ~80%
    penelope_base_success <- 0.50 + (day_progress * 0.30)
    penelope_success_prob <- penelope_base_success +
      rnorm(1, 0, 0.08) +  # slightly less variation than Henry
      ifelse(hour >= 8 && hour <= 20, 0.12, -0.08)  # even better during day
    penelope_success_prob <- pmax(0, pmin(1, penelope_success_prob))

    # Generate events for both children
    for (child in c("Henry", "Penelope")) {
      # Determine if this time slot has an event (not every time slot will)
      if (runif(1) > 0.6) next  # 40% chance of event per time slot

      success_prob <- ifelse(child == "Henry", henry_success_prob, penelope_success_prob)

      # Event type probability (more pee than poop)
      event_type <- sample(c("pee", "poop"), 1, prob = c(0.8, 0.2))

      # Location based on success probability
      location <- ifelse(runif(1) < success_prob, "potty", "accident")

      # Generate some realistic notes occasionally
      notes <- NA_character_
      if (runif(1) < 0.15) {  # 15% chance of notes
        note_options <- c(
          "Great job!", "Getting better!", "Asked to go!", "Dry for 2 hours!",
          "Had to remind", "Close call", "Very proud", "Independence improving",
          NA_character_
        )
        notes <- sample(note_options, 1)
      }

      # Add small time variation to avoid exactly simultaneous events
      event_time <- current_time + minutes(round(runif(1, -30, 30)))

      data_list <- append(data_list, list(data.frame(
        timestamp = event_time,
        child = child,
        event_type = event_type,
        location = location,
        notes = notes,
        stringsAsFactors = FALSE
      )))
    }
  }

  # Combine all events and sort by time
  if (length(data_list) > 0) {
    simulated_data <- do.call(rbind, data_list) |>
      arrange(timestamp) |>
      # Remove any events in the future
      filter(timestamp <= Sys.time())

    return(simulated_data)
  } else {
    # Return empty data frame if no events generated
    return(data.frame(
      timestamp = as.POSIXct(character(0)),
      child = character(0),
      event_type = character(0),
      location = character(0),
      notes = character(0),
      stringsAsFactors = FALSE
    ))
  }
}

format_event_for_display <- function(event_type, location) {
  case_when(
    event_type == "pee" & location == "potty" ~ "💧 Pee ✅",
    event_type == "pee" & location == "accident" ~ "💧 Pee ❌",
    event_type == "poop" & location == "potty" ~ "💩 Poop ✅",
    event_type == "poop" & location == "accident" ~ "💩 Poop ❌",
    .default = paste(event_type, location)
  )
}

format_child_name <- function(child) {
  case_when(
    child == "Henry" ~ "👦 Henry",
    child == "Penelope" ~ "👧 Penelope",
    .default = child
  )
}

get_sanity_emoji <- function(accident_count) {
  case_when(
    accident_count == 0 ~ "😌",
    accident_count <= 2 ~ "😅",
    accident_count <= 4 ~ "😵‍💫",
    .default = "🫠"
  )
}

# Server helper functions -------------------------------------------------
calculate_success_rate <- function(data, child_name, hours_back = HOURS_FOR_RECENT_DATA) {
  if (nrow(data) == 0) return("No data")

  recent_data <- data |>
    filter(
      child == child_name,
      timestamp >= Sys.time() - hours(hours_back)
    )

  if (nrow(recent_data) == 0) return("No recent events")

  success_rate <- recent_data |>
    summarise(rate = mean(location == "potty") * 100) |>
    pull(rate)

  paste0(round(success_rate), "%")
}

calculate_sanity_level <- function(data, hours_back = HOURS_FOR_RECENT_DATA) {
  if (nrow(data) == 0) return("100%")

  recent_data <- data |>
    filter(timestamp >= Sys.time() - hours(hours_back))

  if (nrow(recent_data) == 0) return("100%")

  overall_success <- mean(recent_data$location == "potty")

  # Base sanity from success rate (20-100% range)
  base_sanity <- overall_success * 80 + 20

  # Twin factor - more events = chaos
  twin_factor <- max(0, 100 - nrow(recent_data) * 2)

  # Weighted combination
  final_sanity <- min(100, max(10, base_sanity * 0.7 + twin_factor * 0.3))

  paste0(round(final_sanity), "%")
}

make_prediction <- function(data, child_name) {
  if (nrow(data) == 0) return("No data for predictions yet")

  child_data <- data |>
    filter(child == child_name) |>
    arrange(timestamp)

  if (nrow(child_data) < 3) return("Need more data for predictions")

  # Use recent events for prediction
  recent_events <- child_data |>
    filter(timestamp >= Sys.time() - days(2)) |>
    arrange(timestamp)

  if (nrow(recent_events) < 2) return("Need more recent data")

  # Calculate average interval between events
  time_diffs <- diff(as.numeric(recent_events$timestamp)) / 60  # minutes
  avg_interval <- mean(time_diffs, na.rm = TRUE)

  last_event <- max(recent_events$timestamp)
  next_predicted <- last_event + minutes(round(avg_interval))

  if (next_predicted < Sys.time()) {
    "⚠️ Overdue! Check now!"
  } else {
    time_until <- round(as.numeric(difftime(next_predicted, Sys.time(), units = "mins")))
    paste("In about", time_until, "minutes")
  }
}

create_progress_chart <- function(data) {
  if (nrow(data) == 0) {
    return(plotly_empty() |>
           layout(title = "No data yet - start tracking!"))
  }

  chart_data <- data |>
    filter(timestamp >= Sys.time() - days(DAYS_FOR_PROGRESS_CHART)) |>
    mutate(
      time_block = floor_date(timestamp, "4 hours"),
      success = as.numeric(location == "potty")
    ) |>
    group_by(time_block, child) |>
    summarise(
      success_rate = mean(success) * 100,
      total_events = n(),
      .groups = "drop"
    ) |>
    filter(total_events >= 2)  # Avoid single-event spikes

  if (nrow(chart_data) == 0) {
    return(plotly_empty() |>
           layout(title = "Need more data for trends"))
  }

  plot_ly(
    chart_data,
    x = ~time_block,
    y = ~success_rate,
    color = ~child,
    type = 'scatter',
    mode = 'lines+markers',
    colors = c("Henry" = "#4169E1", "Penelope" = "#FF69B4"),
    text = ~paste("Events:", total_events),
    hovertemplate = "%{fullData.name}<br>%{y:.0f}% success<br>%{text}<extra></extra>"
  ) |>
    layout(
      title = "Success Rate Over Time (4-hour windows)",
      xaxis = list(title = "Time"),
      yaxis = list(title = "Success Rate (%)", range = c(-5, 105)),
      showlegend = TRUE
    )
}

create_recent_events_table <- function(data) {
  if (nrow(data) == 0) {
    return(reactable(
      data.frame(Message = "No events tracked yet!"),
      columns = list(Message = colDef(style = "text-align: center;"))
    ))
  }

  display_data <- data |>
    arrange(desc(timestamp)) |>
    head(20) |>
    mutate(
      Time = format(timestamp, "%m/%d %H:%M"),
      Child = format_child_name(child),
      Event = format_event_for_display(event_type, location),
      Notes = if_else(is.na(notes) | notes == "", "—", notes)
    ) |>
    select(Time, Child, Event, Notes)

  reactable(
    display_data,
    columns = list(
      Time = colDef(width = 100),
      Child = colDef(width = 100),
      Event = colDef(width = 120),
      Notes = colDef(minWidth = 150, style = "font-style: italic;")
    ),
    highlight = TRUE,
    height = TABLE_HEIGHT
  )
}

# Initialize chat ---------------------------------------------------------
jamie_chat <- chat_anthropic(
  model = "claude-4-sonnet-20250514",
  system_prompt = "You are Jamie Glowacki, the author of 'Oh Crap! Potty Training'.
  You are helping parents potty train their boy-girl twins, Henry and Penelope.
  Be encouraging, practical, and use your signature no-nonsense but supportive tone.
  Give specific advice based on the Oh Crap method. Keep responses concise but helpful.
  Respond in 1 to 2 sentences at most.
  Remember these are twins so there may be comparison issues, different readiness levels, etc."
)

# UI ----------------------------------------------------------------------
ui <- page_sidebar(
  title = div(
    style = "display: flex; align-items: center; gap: 10px;",
    "🚽",
    span("Twin Potty Training Command Center", style = "font-family: 'Fredoka One', cursive;")
  ),
  theme = bs_theme(brand = "_brand.yml"),

  sidebar = sidebar(
    width = 400,
    h4("👩‍⚕️ Ask Jamie", style = "color: #9370DB;"),
    p("Need potty training advice? Jamie Glowacki is here to help!",
      style = "font-style: italic; color: #666;"),
    chat_ui("jamie_chat"),
    hr(),
    h4("📊 Quick Add Event"),
    fluidRow(
      column(6, selectInput("child", "Child:",
                           choices = list("Henry 👦" = "Henry", "Penelope 👧" = "Penelope"))),
      column(6, selectInput("event_type", "Event:",
                           choices = list("Pee 💧" = "pee", "Poop 💩" = "poop")))
    ),
    fluidRow(
      column(6, selectInput("location", "Where:",
                           choices = list("Potty! 🎉" = "potty", "Accident 😅" = "accident"))),
      column(6, br(), actionButton("add_event", "Add Event",
                                  class = "btn-warning", style = "width: 100%;"))
    ),
    textAreaInput("notes", "Notes:", placeholder = "Any notes about this event...", rows = 3),
    hr(),
    div(
      style = "text-align: center;",
      actionButton("regenerate_data", "🎲 Generate New Sample Data",
                   class = "btn-outline-secondary btn-sm",
                   style = "font-size: 0.8em;"),
      br(),
      p("For testing/demo purposes", style = "font-size: 0.7em; color: #666; margin-top: 5px;")
    )
  ),

  # Key metrics row
  layout_columns(
    col_widths = c(4, 4, 4),
    value_box(
      title = "Henry's Success Rate",
      value = textOutput("henry_success_rate"),
      showcase = "👦",
      theme = "info",
      p("Last 24 hours", style = "font-size: 0.8em; margin: 0;")
    ),
    value_box(
      title = "Penelope's Success Rate",
      value = textOutput("penelope_success_rate"),
      showcase = "👧",
      theme = "primary",
      p("Last 24 hours", style = "font-size: 0.8em; margin: 0;")
    ),
    value_box(
      title = "Parental Sanity Level",
      value = textOutput("sanity_level"),
      showcase = textOutput("sanity_emoji"),
      theme = "success",
      p("Based on recent success rates", style = "font-size: 0.8em; margin: 0;")
    )
  ),

  # Charts row
  layout_columns(
    col_widths = c(8, 4),
    card(
      card_header(
        "📈 Progress Over Time",
        class = "d-flex justify-content-between align-items-center"
      ),
      plotlyOutput("progress_chart", height = CHART_HEIGHT)
    ),
    card(
      card_header("🔮 Next Event Predictions"),
      div(
        style = "padding: 20px;",
        h5("Henry 👦", style = "color: #4169E1;"),
        p(textOutput("henry_prediction"), style = "margin-bottom: 20px;"),
        h5("Penelope 👧", style = "color: #FF69B4;"),
        p(textOutput("penelope_prediction"))
      )
    )
  ),

  # Events table row
  card(
    card_header("📋 Recent Events"),
    reactableOutput("recent_events"),
    full_screen = TRUE
  )
)

# Server ------------------------------------------------------------------
server <- function(input, output, session) {
  # Reactive data
  potty_data <- reactiveVal(load_or_create_data())

  # Jamie chat integration
  observeEvent(input$jamie_chat_user_input, {
    current_data <- potty_data()

    if (nrow(current_data) > 0) {
      recent_summary <- current_data |>
        filter(timestamp >= Sys.time() - days(3)) |>
        count(child, location, .drop = FALSE)

      context_prompt <- paste(
        input$jamie_chat_user_input,
        "\n\nCurrent situation with the twins:",
        paste(capture.output(print(recent_summary)), collapse = "\n")
      )
    } else {
      context_prompt <- input$jamie_chat_user_input
    }

    stream <- jamie_chat$stream_async(context_prompt)
    chat_append("jamie_chat", stream)
  })

  # Add new event
  observeEvent(input$add_event, {
    new_event <- data.frame(
      timestamp = Sys.time(),
      child = input$child,
      event_type = input$event_type,
      location = input$location,
      notes = if_else(input$notes == "", NA_character_, input$notes),
      stringsAsFactors = FALSE
    )

    updated_data <- bind_rows(potty_data(), new_event)
    potty_data(updated_data)

    # Save data
    saveRDS(updated_data, "potty_data.rds")

    # Clear notes field
    updateTextAreaInput(session, "notes", value = "")

    # Show notification
    showNotification(
      paste("Added", input$event_type, "event for", input$child, "!"),
      type = if (input$location == "potty") "default" else "warning"
    )
  })

  # Regenerate simulated data
  observeEvent(input$regenerate_data, {
    new_data <- generate_simulated_data()
    potty_data(new_data)

    # Save new data
    saveRDS(new_data, "potty_data.rds")

    showNotification(
      "Generated new sample data with realistic improvement patterns!",
      type = "message"
    )
  })

  # Success rate outputs
  output$henry_success_rate <- renderText({
    calculate_success_rate(potty_data(), "Henry")
  })

  output$penelope_success_rate <- renderText({
    calculate_success_rate(potty_data(), "Penelope")
  })

  # Parental sanity
  output$sanity_level <- renderText({
    calculate_sanity_level(potty_data())
  })

  output$sanity_emoji <- renderText({
    current_data <- potty_data()
    if (nrow(current_data) == 0) return("😌")

    recent_accidents <- current_data |>
      filter(timestamp >= Sys.time() - hours(6)) |>
      filter(location == "accident") |>
      nrow()

    get_sanity_emoji(recent_accidents)
  })

  # Progress chart
  output$progress_chart <- renderPlotly({
    create_progress_chart(potty_data())
  })

  # Predictions
  output$henry_prediction <- renderText({
    make_prediction(potty_data(), "Henry")
  })

  output$penelope_prediction <- renderText({
    make_prediction(potty_data(), "Penelope")
  })

  # Recent events table
  output$recent_events <- renderReactable({
    create_recent_events_table(potty_data())
  })
}

# Launch app --------------------------------------------------------------
shinyApp(ui, server)
