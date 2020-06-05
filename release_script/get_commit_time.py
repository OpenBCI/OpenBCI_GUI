import requests
import os
from bs4 import  BeautifulSoup

def main ():
    repo_slug = None
    commit_id = None

    repo_slug = os.getenv("TRAVIS_REPO_SLUG")
    if repo_slug is None:
        repo_slug = os.getenv("APPVEYOR_REPO_NAME")

    commit_id = os.getenv("TRAVIS_COMMIT")
    if commit_id is None:
        commit_id = os.getenv("APPVEYOR_REPO_COMMIT")

    url = "http://github.com/" + repo_slug + "/commit/" + commit_id;

    page = requests.get(url)
    soup = BeautifulSoup(page.content, features="html.parser")

    timestamp = soup.find("relative-time")["datetime"]
    timestamp = timestamp.replace(":", "_")

    print(timestamp)

if __name__ == '__main__':
    main ()