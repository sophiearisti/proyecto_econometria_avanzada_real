# proyecto_econometria_avanzada
Research proyect: DIF IN DIF, TWFE, CS, Events study, RCTs, microeconometrics, informality, economic activity, OXXO.

libraries that sould be installed: 
pip3 install beautifulsoup4

pip3 install requests

pip3 install lxml

pip3 install selenium

pip3 install ohsome

pip3 install matplotlib

pip3 install unidecode

pip3 install overpy

To use this proyect remember to activate a python envirtonment. This is the command line that should be used in the terminal: source venv/bin/activate 

The proyect has subforlders, one for a specific responsibility.

ws_OxxoD1Ara contains all the python code used to webscrap the RUES web page, and the code for finding each store location with GM API. REMEMBER to update Selenium.
1. Run wsStores.py to do the stores ws and save them in csvs
2. Run assingLocalization.py to add to each store its precise localization (lat, long)

dofiles contains all the dofiles used to process the raw data, and do the general and specific econometric analysis. Additionally, it contains python code to process maps and geodata. And there are some Rcodes just to crete prettier graphs

DATA contains all the raw and processed data. Here I also store all the graphs created for the research.

doc contains literally all the things needed to run Latex locally. And here is located my written work.
