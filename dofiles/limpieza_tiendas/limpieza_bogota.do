*******************************************************************
*VERSION 1
*COMO YA TENEMOS TODOS LOS CSV DE TODAS LAS TIENDAS
*vamos a limpiar la bdd y dejar literalmente las tiendas de la camara de comercio de bogota
*******************************************************************
global dir_BDD_principal "/Users/sophiaaristizabal/Desktop/1 economia/7/econometría avanzada/proyecto_econometria_avanzada"


global dir_BDD_negocios "$dir_BDD_principal/data/negocios"

global dir_BDD_bogota "$dir_BDD_principal/data/negocios/bogota_y_alrededores"

cd "$dir_BDD_negocios"

//para cada dta solo obtener los de bogota 

local archivos "oxxos.csv D1.csv justo_y_bueno.csv tienda_ara.csv"

foreach archivo of local archivos {
    
	display "Importando `archivo'..."
    import delimited "`archivo'", clear
	
	label variable latitud "latitud"
	
	label variable longitud "longitud"
	
	label variable direccion "direccion"
    
    keep if cámaradecomercio=="BOGOTA"
	
	drop cámaradecomercio númerodematrícula 
	
    * Guardar en la carpeta correspondiente quitando .csv
    local nombre_sin_ext = substr("`archivo'", 1, strlen("`archivo'")-4)
	
    cd "$dir_BDD_bogota"
    save "`nombre_sin_ext'", replace
    
    * Volver a la carpeta original
    cd "$dir_BDD_negocios"
}







