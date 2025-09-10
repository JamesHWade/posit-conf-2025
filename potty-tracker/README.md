# 🚽 Twin Potty Training Command Center

A fun and functional Shiny app to help track potty training progress for twins Henry and Penelope, following the "Oh Crap! Potty Training" method by Jamie Glowacki.

## Features

- **Jamie Chat**: AI-powered advice from Jamie Glowacki herself
- **Twin Tracking**: Separate tracking for Henry and Penelope
- **Success Metrics**: Real-time success rates and parental sanity levels
- **Progress Visualization**: Charts showing improvement over time
- **Event Predictions**: Simple predictions for next potty breaks
- **Quick Event Logging**: Easy buttons to log successes and accidents

## Setup

1. Make sure you have the required packages:
```r
install.packages(c("shiny", "bslib", "DT", "plotly", "dplyr", "lubridate", "reactable"))

# For the AI chat feature:
if (system.file(package="pak")=="") install.packages("pak")
pak::pak(c("posit-dev/shinychat", "tidyverse/ellmer"))
```

2. Set up your API key in a `.env` file:
```
ANTHROPIC_API_KEY=your_key_here
```

3. Run the app:
```r
shiny::runApp()
```

## A True "Disposable App"

This app is designed for the potty training phase - once Henry and Penelope are fully trained, you can happily delete it! It's a perfect example of a specialized tool built quickly to solve a specific, time-limited problem.

## Data Storage

The app automatically saves tracking data to `potty_data.rds` in the app directory. This allows you to maintain your tracking history between sessions.

---

*Built with love (and desperation) for the potty training journey! 🎯*
