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

#lista de nombres válidos para discriminar
nombres_valido_ara = ["TIENDA ARA","ARA", "TI4ENDA ARA", "TIENDA 0441 ARA"]
nombres_validos_d1 = ["D1", "MINI MERCADO D1", "MINIMERCADO", "TIENDA D1", "TIENDAS D1"]
nombres_validos_justo_y_bueno = ["JUSTO Y BUENO"]
nombres_validos_oxxo = ["OXXO"]
nombre_valido_lista = [nombres_valido_ara, nombres_validos_d1, nombres_validos_justo_y_bueno, nombres_validos_oxxo]

url_establecimiento_lista = [
    "https://ruesfront.rues.org.co/detalle/04/2161982",  # TIENDA ARA
    "https://ruesfront.rues.org.co/detalle/04/2305280",  # D1
    "https://ruesfront.rues.org.co/detalle/04/2608019",  # JUSTO Y BUENO
    "https://ruesfront.rues.org.co/detalle/04/1830322"   # OXXO
]

csv_file_establecimiento_lista = [
    "data/tienda_ara.csv",
    "data/d1.csv",
    "data/justo_y_bueno.csv",
    "data/oxxos.csv"
]


def webScrappingCadenas(url_establecimiento, csv_file_establecimiento,  nombre_valido_lista):
    print("Iniciando web scraping de cadenas...")
    # Configurar Selenium
    options = Options()
    #options.add_argument("--headless")  # si quieres ver el navegador, quita esta línea
    driver = webdriver.Chrome(options=options)

    url = url_establecimiento
    driver.get(url)

    # Esperar a que aparezca la pestaña
    wait = WebDriverWait(driver, 10)
    #hace click en la pestaña "Establecimientos" esto muestra todos los establecimientos abiertos   
    #que tiene la empresa
    tab = wait.until(EC.element_to_be_clickable((By.ID, "detail-tabs-tab-pestana_establecimientos")))
    driver.execute_script("arguments[0].click();", tab)

    time.sleep(3)  # esperar a que cargue el contenido dinámico

    # Extraer el HTML ya con la pestaña abierta
    soup = BeautifulSoup(driver.page_source, "html.parser")
    print(soup.prettify()[:1000])  # muestra un pedacito del HTML cargado

    # Archivo CSV
    csv_file = csv_file_establecimiento

    # Si no existe el archivo, escribir la cabecera una sola vez
    if not os.path.exists(csv_file):
        with open(csv_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([
                "Nombre", "Cámara de Comercio", "Número de Matrícula", "Fecha de Matrícula", 
                "Estado de la matrícula", "Fecha de renovación", "Último año renovado"
            ])

    #Despues de mostrar esa ventana, se debe obtener toda la información de los establecimientos
    while True:
        #obtener el acordeon de los establecimientos
        accordion = wait.until(EC.presence_of_element_located((By.ID, "acordionEstablecimientos")))

        # Encontrar todos los botones de acordeón
        #la idea es iterar sobre cada uno de los botones del acordeon
        buttons = accordion.find_elements(By.CLASS_NAME, "accordion-button")

        # Abrir CSV para guardar los datos
        with open(csv_file, "a", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
                    
            # Recorrer cada botón
            for i, button in enumerate(buttons):
                
                # Scroll hasta el botón y click
                driver.execute_script("arguments[0].scrollIntoView(true);", button)
                driver.execute_script("arguments[0].click();", button)
                time.sleep(1.5)  # esperar que abra el acordeón
                
                panel_id = button.get_attribute("data-bs-target").lstrip("#")
                wait.until(EC.visibility_of_element_located((By.ID, panel_id)))

                # Parsear con BeautifulSoup el HTML ya expandido
                soup = BeautifulSoup(driver.page_source, "html.parser")

                # Encontrar el acordeón correspondiente
                acc = soup.find("div", id=panel_id)
                if not acc:
                    continue
                
                # Verificar si el nombre es válido con base en la lista proporcionada
                #solo es ver si el nombre contiene alguno de los nombres validos
                if not any(valid_name in button.text.strip().upper() for valid_name in nombre_valido_lista):
                    continue  # saltar este establecimiento si no es válido

                #de lo contrario, si es válido, extraer la información
                nombre = button.text.strip()

                datos = {}
                for bloque in acc.select("div.registroapi"):
                    lab = bloque.select_one("p.registroapi__etiqueta")
                    val = bloque.select_one("p.registroapi__valor")
                    if lab and val:
                        datos[lab.get_text(strip=True)] = val.get_text(strip=True)

                camara          = datos.get("Cámara de Comercio", "-")
                matricula       = datos.get("Número de Matrícula", "-")
                fecha_matricula = datos.get("Fecha de Matrícula", "-")
                estado          = datos.get("Estado de la matrícula", "-")
                renovacion      = datos.get("Fecha de renovación", "-")
                ultimo          = datos.get("Último año renovado", "-")

                # Guardar fila en el CSV
                writer.writerow([nombre, camara, matricula, fecha_matricula, estado, renovacion, ultimo])
        # 3. Intentar pasar a la siguiente página
        try:
            next_button = driver.find_element(By.CSS_SELECTOR, "a.page-link i.bi-chevron-right.green-color")
            parent_link = next_button.find_element(By.XPATH, "..")  # subir al <a>
            
            # revisar si está deshabilitado (su <li> tiene class "disabled")
            li_parent = parent_link.find_element(By.XPATH, "..")
            if "disabled" in li_parent.get_attribute("class"):
                break  # ya llegamos al final
            
            driver.execute_script("arguments[0].click();", parent_link)
            time.sleep(1)  # esperar carga
        except:
            break


    driver.quit()


    print("✅ Datos guardados en csv")
    
#hacer triple for para recorrer las listas
for url_establecimiento, csv_file_establecimiento, nombres_validos in zip(url_establecimiento_lista, csv_file_establecimiento_lista, nombre_valido_lista):
    
    webScrappingCadenas(url_establecimiento, csv_file_establecimiento,  nombres_validos)



