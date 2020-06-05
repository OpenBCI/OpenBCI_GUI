import requests
from bs4 import  BeautifulSoup

def main ():
    


    page = requests.get("http://github.com/OpenBCI/OpenBCI_GUI/commit/a64d589b753a6d1e93c6655f85bf9b576ada2d2d")
    soup = BeautifulSoup(page.content, features="html.parser")
    print(soup.find("relative-time")["datetime"])



if __name__ == '__main__':
    main ()