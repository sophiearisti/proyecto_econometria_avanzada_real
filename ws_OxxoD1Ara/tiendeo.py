#aqui el proposito es comparar los csvs obtenidos con los datos de la direccion de tiendeo
#si no aparece una direccion de tiendeo en bogota, se debe marcar la fila como no encontrada
#si la direccion puesta no coincide con la de tiendeo , toca evaluar y poner que no coincide
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
import csv
import time
import os

from trio import sleep

url_tiendeo_lista = [
    "https://www.tiendeo.com.co/Tiendas/bogota/ara",  # TIENDA ARA
    "https://www.tiendeo.com.co/bogota/tiendas-d1",  # D1
    "https://www.tiendeo.com.co/bogota/oxxo"   # OXXO
]

csv_lista = [
    "../data/negocios/tienda_ara.csv",  # TIENDA ARA
    "../data/negocios/D1.csv",  # D1
    "../data/negocios/oxxos.csv"   # OXXO
]

def webScrappingCadenas(url_establecimiento, csv_file_establecimiento):

    print("Iniciando web scraping de tiendeo...")
        # Configurar Selenium
    options = Options()

    #options.add_argument("--headless")  # si quieres ver el navegador, quita esta línea
    driver = webdriver.Chrome(options=options)

    url = url_establecimiento
    driver.get(url)
    
    # Esperar a que aparezca la pestaña
    wait = WebDriverWait(driver, 10)
    
    time.sleep(3)  # esperar a que cargue el contenido dinámico
    
    driver.quit()
    
    
for url_establecimiento, csv_file_establecimiento in zip(url_tiendeo_lista, csv_lista):
    
    webScrappingCadenas(url_establecimiento, csv_file_establecimiento)
