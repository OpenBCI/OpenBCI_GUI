import requests
import matplotlib.pyplot as plt
from datetime import datetime

# Define the GitHub API URL for the OpenBCI releases
api_url = "https://api.github.com/repos/OpenBCI/OpenBCI_GUI/releases"

# Send a GET request to the API
response = requests.get(api_url)

# Check if the request was successful
if response.status_code != 200:
    print(f"Failed to fetch data. Status code: {response.status_code}")
    exit()

# Parse the JSON data
data = response.json()

# Initialize dictionaries to store download counts for each platform
download_count_mac = {}
download_count_linux = {}
download_count_windows = {}

# Extract download counts over time for each platform
for release in data:
    assets = release.get("assets", [])
    release_date = datetime.strptime(release["published_at"], "%Y-%m-%dT%H:%M:%SZ").date()
    
    for asset in assets:
        if "mac" in asset["name"].lower():
            download_count_mac[release_date] = download_count_mac.get(release_date, 0) + asset["download_count"]
        elif "linux" in asset["name"].lower():
            download_count_linux[release_date] = download_count_linux.get(release_date, 0) + asset["download_count"]
        elif "win" in asset["name"].lower():
            download_count_windows[release_date] = download_count_windows.get(release_date, 0) + asset["download_count"]

# Extract dates and download counts for each platform
dates_mac, counts_mac = zip(*sorted(download_count_mac.items()))
dates_linux, counts_linux = zip(*sorted(download_count_linux.items()))
dates_windows, counts_windows = zip(*sorted(download_count_windows.items()))

# Create the download count graphs
plt.figure(figsize=(12, 6))
plt.plot(dates_mac, counts_mac, label="Mac", marker='o')
plt.plot(dates_linux, counts_linux, label="Linux", marker='o')
plt.plot(dates_windows, counts_windows, label="Windows", marker='o')

plt.title("Download Count Over Time for OpenBCI GUI")
plt.xlabel("Release Date")
plt.ylabel("Download Count")
plt.grid(True)
plt.legend()

# Rotate x-axis labels for better readability
plt.xticks(rotation=45)

# Show the graph
plt.tight_layout()
plt.show()
