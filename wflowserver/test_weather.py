import pandas as pd
from datetime import date, timedelta
import requests
import time

# Define the latitude and longitude
latitude = 44.64783
longitude = 10.92539

# Initialize an empty DataFrame
columns = ["Date", "Time", "Temperature_2m",
           "RelativeHumidity_2m", "Windspeed_10m", "Rain"]
weather_df = pd.DataFrame(columns=columns)

# Define the start and end dates
start_date = date(2023, 9, 1)
end_date = date.today()

# Define the API base URL
base_url = "https://api.open-meteo.com/v1/forecast"

# Define the delay in seconds (e.g., 2 seconds)
request_delay = 2

# Rainy weather codes
rainy_weather_codes = {21, 22, 23}  # Add more codes as needed

# Loop through each day and make API requests
current_date = start_date
while current_date <= end_date:
    current_date_str = current_date.strftime("%Y-%m-%d")

    # Make the API request
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "date": current_date_str,
        "current": "temperature_2m,relativehumidity_2m,windspeed_10m,weathercode",
        "hourly": "temperature_2m,relativehumidity_2m,windspeed_10m"
    }

    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()  # Check for HTTP request errors

        data = response.json()

        # Extract current weather data
        current_data = data.get("current", {})
        weather_code = current_data.get("weathercode", None)

        # Extract hourly data
        hourly_data = data.get("hourly", {})

        if hourly_data:
            times = hourly_data.get("time", [])
            temperatures = hourly_data.get("temperature_2m", [])
            relative_humidity = hourly_data.get("relativehumidity_2m", [])
            windspeed = hourly_data.get("windspeed_10m", [])

            print(weather_code)

            # Check if it's raining based on weather code
            is_raining = weather_code in rainy_weather_codes

            # Create a temporary DataFrame for the day's data
            day_df = pd.DataFrame({
                "Date": current_date_str,
                "Time": times,
                "Temperature_2m": temperatures,
                "RelativeHumidity_2m": relative_humidity,
                "Windspeed_10m": windspeed,
                "Rain": is_raining
            })

            # Concatenate the temporary DataFrame with the main DataFrame
            weather_df = pd.concat([weather_df, day_df], ignore_index=True)

    except requests.exceptions.RequestException as e:
        print("Request error:", e)

    # Move to the next day
    current_date += timedelta(days=1)

    # Introduce a time delay before the next request
    time.sleep(request_delay)

# Display the resulting DataFrame
print(weather_df)

# You can save the DataFrame to a CSV file if needed
weather_df.to_csv("weather_data.csv", index=False)
