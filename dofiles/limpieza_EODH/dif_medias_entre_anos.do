**********************************************************
*VERSION 1
*diferencia de medias estre anos, con el objetivo de saber por cuales caracteristicas se debera controlar en el panel
**********************************************************
*ssc install ietoolkit

cd "$dir_BDD_2023"
cd "$dir_BDD_clean"

use "merge_2023.dta", clear

cd "$dir_BDD_2019"
cd "$dir_BDD_clean"

append using merge_2019.dta

drop id_hogar id_persona cod_per cod_hg ocupacion2 ocupacion3 ocupacion4

cd "$dir_BDD_2011"
cd "$dir_BDD_clean"

append using merge_2011.dta

drop actividad_economica2 ocupacion2 id_perso id_hogar

replace tipo_propiedad_vivienda=. if tipo_propiedad_vivienda==8

cd "$dir_BDD_2015"
cd "$dir_BDD_clean"

append using merge_2015.dta

drop actividad_economica1_d89

//vamos a hacer drop de variables que exclusivamente tienen unos datasets
drop tipo_propiedad_vivienda_d8 nomina_patron ocupacion1_d2 ocupacion1_d3 ocupacion1_d9 actividad_economica1_d2

//primero comparar con diferencia de medias las entre 2011 y 2015
preserve

drop if a2023==1 | a2019==1

drop tipo_propiedad_vivienda_d7 ocupacion1_d25 ocupacion1_d26 ocupacion1_d27 ocupacion1_d28 ocupacion1_d29 actividad_economica1_d18 actividad_economica1_d19 ocupacion1_d23 ocupacion1_d10

replace a2015=0 if a2015==.

global evalVars estrato edad limitaciones_fisicas mujer total_personas tipo_propiedad_vivienda ///
     camino_minutos ///
    nivel_educativo_d* tipo_vivienda_d* tipo_propiedad_vivienda_d* ///
	ocupacion1_d* actividad_economica1_d* 
	
cd "$dir_reg_dif_med_results"

iebaltab $evalVars , groupvar(a2015) control(0) savexlsx(difmedias_entre_anos_2015x2011) replace

restore

//segundo comparar con diferencia de medias las entre 2019 y 2023
preserve

drop if a2011==1 | a2015==1


replace a2019=0 if a2019==.

global evalVars estrato edad limitaciones_fisicas mujer total_personas total_personas_mas_5 ///
    nivel_educativo_d* tipo_vivienda_d* ///
	ocupacion1_d* actividad_economica1_d* 
	
cd "$dir_reg_dif_med_results"

iebaltab $evalVars , groupvar(a2019) control(0) savexlsx(difmedias_entre_anos_2019x2023) replace

restore 


//tercero comparar con diferencia de medias las entre 2015 y 2019
preserve

drop if a2023==1 | a2011==1

drop ocupacion1_d25 ocupacion1_d26 ocupacion1_d27 ocupacion1_d28 ocupacion1_d29 actividad_economica1_d18 actividad_economica1_d19 ocupacion1_d23 ocupacion1_d10

replace a2019=0 if a2019==.

global evalVars estrato edad limitaciones_fisicas mujer total_personas ///
    nivel_educativo_d* tipo_vivienda_d* ///
	ocupacion1_d* actividad_economica1_d*
	
cd "$dir_reg_dif_med_results"

iebaltab $evalVars , groupvar(a2019) control(0) savexlsx(difmedias_entre_anos_2015x2019) replace

restore 


***************************************************************
*con esto haremos el collapse segun el ZAT
***************************************************************

//este se guardara en el data de los buffers porque con eso se crea el panel georeferenciado

//en este no vamos a tener en cuenta las siguientes vars  (las otras no las tendremos en cuenta y se desaparecen):
//mean mujer, mean edad, mean educacion, count formal, count informal

//me debe quedar un dato por zat 

**************************************************************************
*2019
**************************************************************************

cd "$dir_BDD_2019"
cd "$dir_BDD_clean"

use "merge_2019.dta", clear

bysort zat_destino: summarize tot

preserve

rename estrato estrato_trabajador

//falta poner minutos caminados y cuadras caminadas

* colapsamos al nivel ZAT destino
//edad nivel_educativo limitaciones_fisicas i.ocupacion1 mujer i.actividad_economica1 camino_cuadras camino_minutos i.tipo_vivienda i.tipo_propiedad_vivienda estrato total_personas total_personas_mas_5


collapse (mean) mujer nivel_educativo estrato_trabajador limitaciones_fisicas total_personas ///
tipo_vivienda_d2 tipo_vivienda_d3 tipo_vivienda_d4 tipo_vivienda_d5 ///
nivel_educativo_d2 nivel_educativo_d3 nivel_educativo_d4 nivel_educativo_d5 nivel_educativo_d7 nivel_educativo_d8 nivel_educativo_d9 nivel_educativo_d11 ///
ocupacion1_d1 ocupacion1_d4 ocupacion1_d5 ocupacion1_d6 ocupacion1_d7 ocupacion1_d8 ocupacion1_d13 ocupacion1_d18 ocupacion1_d19 ocupacion1_d20 ocupacion1_d24 ///
actividad_economica1_d1 actividad_economica1_d3 actividad_economica1_d4 actividad_economica1_d5 actividad_economica1_d7 actividad_economica1_d8 actividad_economica1_d9 actividad_economica1_d10 actividad_economica1_d11 actividad_economica1_d12 actividad_economica1_d13 actividad_economica1_d14 actividad_economica1_d15 actividad_economica1_d16 actividad_economica1_d17 ///
(sum) formal_no_indep vendedor_informal independiente_total independiente_trabajando independiente_buscando buscar_trabajo con_trabajo tot desempleado, by(zat_destino)

//dividir (sum) nomina_patron (sum) independiente por cantTrabajadores DE ESA ZAT
//dividir buscar_trabajo por cantTotal DE ESA ZAT

gen prop_formal_no_indep       = formal_no_indep / tot

gen prop_independiente_total = independiente_total / tot

gen prop_independiente_trabajando = independiente_trabajando / tot

gen prop_independiente_buscando = independiente_buscando / tot

gen prop_buscar      = buscar_trabajo / tot

gen prop_desempleado      = desempleado / tot


label variable mujer               "Promedio de mujeres (dummy) por ZAT"
label variable nivel_educativo     "Educación promedio por ZAT" //toca cambiar
label variable estrato_trabajador  "Estrato socioeconómico promedio por ZAT"
label variable limitaciones_fisicas "Promedio de limitaciones físicas (dummy) por ZAT" 

label variable formal_no_indep       "Total trabajadores de nomina y patrones por ZAT"
label variable independiente_total       "Total trabajadores independientes por ZAT"
label variable independiente_trabajando       "Total trabajadores independientes que fueron a trabajar por ZAT"
label variable independiente_buscando      "Total trabajadores independientes que fueron a buscar trabajo por ZAT"
label variable buscar_trabajo      "Total personas buscando trabajo por ZAT"

label variable prop_formal_no_indep         "Proporción de nomina y patrones sobre total población en dicho ZAT"
label variable prop_independiente_total  "independientes/tot_ZAT"
label variable prop_independiente_trabajando  "independientes a trabajar/total_ZAT"
label variable prop_independiente_buscando  "independientes buscando/total_ZAT"
label variable prop_buscar         "buscando/total_ZAT"
label variable prop_desempleado         "desempleado/tot_ZAT"
 
cd "$dir_BDD_buffers"

save collapsed_2019.dta, replace

restore 

**************************************************************************
*2011
**************************************************************************

cd "$dir_BDD_2011"
cd "$dir_BDD_clean"

use "merge_2011.dta", clear

bysort zat_destino: summarize tot

preserve

rename estrato estrato_trabajador

* colapsamos al nivel ZAT destino

//falta poner minutos caminados y cuadras caminadas

collapse (mean) mujer nivel_educativo estrato_trabajador limitaciones_fisicas total_personas ///
tipo_vivienda_d2 tipo_vivienda_d3 tipo_vivienda_d4 tipo_vivienda_d5 ///
nivel_educativo_d2 nivel_educativo_d3 nivel_educativo_d4 nivel_educativo_d5 nivel_educativo_d7 nivel_educativo_d8 nivel_educativo_d9 nivel_educativo_d11 ///
ocupacion1_d1 ocupacion1_d4 ocupacion1_d5 ocupacion1_d6 ocupacion1_d7 ocupacion1_d8 ocupacion1_d13 ocupacion1_d18 ocupacion1_d19 ocupacion1_d20 ocupacion1_d24 ///
actividad_economica1_d1 actividad_economica1_d3 actividad_economica1_d4 actividad_economica1_d5 actividad_economica1_d7 actividad_economica1_d8 actividad_economica1_d9 actividad_economica1_d10 actividad_economica1_d11 actividad_economica1_d12 actividad_economica1_d13 actividad_economica1_d14 actividad_economica1_d15 actividad_economica1_d16 actividad_economica1_d17 ///
(sum) nomina_patron independiente_total independiente_trabajando independiente_buscando buscar_trabajo con_trabajo tot desempleado, by(zat_destino)
		 
//dividir (sum) nomina_patron (sum) independiente por cantTrabajadores DE ESA ZAT
//dividir buscar_trabajo por cantTotal DE ESA ZAT

gen prop_nomina_patron       = nomina_patron / tot

gen prop_independiente_total = independiente_total / tot

gen prop_independiente_trabajando = independiente_trabajando / tot

gen prop_independiente_buscando = independiente_buscando / tot

gen prop_buscar      = buscar_trabajo / tot

gen prop_desempleado      = desempleado / tot


label variable mujer               "Promedio de mujeres (dummy) por ZAT"
label variable nivel_educativo     "Educación promedio por ZAT" //toca cambiar
label variable estrato_trabajador  "Estrato socioeconómico promedio por ZAT"
label variable limitaciones_fisicas "Promedio de limitaciones físicas (dummy) por ZAT" 

label variable nomina_patron       "Total trabajadores de nomina y patrones por ZAT"
label variable independiente_total       "Total trabajadores independientes por ZAT"
label variable independiente_trabajando       "Total trabajadores independientes que fueron a trabajar por ZAT"
label variable independiente_buscando      "Total trabajadores independientes que fueron a buscar trabajo por ZAT"
label variable buscar_trabajo      "Total personas buscando trabajo por ZAT"

label variable prop_nomina_patron         "Proporción de nomina y patrones sobre total población en dicho ZAT"
label variable prop_independiente_total  "independientes/tot_ZAT"
label variable prop_independiente_trabajando  "independientes a trabajar/total_ZAT"
label variable prop_independiente_buscando  "independientes buscando/total_ZAT"
label variable prop_buscar         "buscando/total_ZAT"
label variable prop_desempleado         "desempleado/tot_ZAT"

cd "$dir_BDD_buffers"

save collapsed_2011.dta, replace

restore 

**************************************************************************
*2023
**************************************************************************

cd "$dir_BDD_2023"
cd "$dir_BDD_clean"

use "merge_2023.dta", clear

bysort zat_destino: summarize tot

preserve

rename estrato estrato_trabajador

* colapsamos al nivel ZAT destino
collapse (mean) mujer nivel_educativo estrato_trabajador limitaciones_fisicas   total_personas ///
tipo_vivienda_d2 tipo_vivienda_d3 tipo_vivienda_d4 tipo_vivienda_d5 ///
nivel_educativo_d2 nivel_educativo_d3 nivel_educativo_d4 nivel_educativo_d5 nivel_educativo_d7 nivel_educativo_d8 nivel_educativo_d9 nivel_educativo_d11 ///
ocupacion1_d1 ocupacion1_d4 ocupacion1_d5 ocupacion1_d6 ocupacion1_d7 ocupacion1_d8 ocupacion1_d13 ocupacion1_d18 ocupacion1_d19 ocupacion1_d20 ocupacion1_d24 ///
actividad_economica1_d1 actividad_economica1_d3 actividad_economica1_d4 actividad_economica1_d5 actividad_economica1_d7 actividad_economica1_d8 actividad_economica1_d9 actividad_economica1_d10 actividad_economica1_d11 actividad_economica1_d12 actividad_economica1_d13 actividad_economica1_d14 actividad_economica1_d15 actividad_economica1_d16 actividad_economica1_d17 ///
(sum) formal_no_indep vendedor_informal independiente_total independiente_trabajando independiente_buscando buscar_trabajo con_trabajo tot desempleado, by(zat_des)

gen prop_formal_no_indep       = formal_no_indep / tot

gen prop_independiente_total = independiente_total / tot

gen prop_independiente_trabajando = independiente_trabajando / tot

gen prop_independiente_buscando = independiente_buscando / tot

gen prop_buscar      = buscar_trabajo / tot

gen prop_desempleado      = desempleado / tot


label variable mujer               "Promedio de mujeres (dummy) por ZAT"
label variable nivel_educativo     "Educación promedio por ZAT" //toca cambiar
label variable estrato_trabajador  "Estrato socioeconómico promedio por ZAT"
label variable limitaciones_fisicas "Promedio de limitaciones físicas (dummy) por ZAT" 

label variable formal_no_indep       "Total trabajadores de nomina y patrones por ZAT"
label variable independiente_total       "Total trabajadores independientes por ZAT"
label variable independiente_trabajando       "Total trabajadores independientes que fueron a trabajar por ZAT"
label variable independiente_buscando      "Total trabajadores independientes que fueron a buscar trabajo por ZAT"
label variable buscar_trabajo      "Total personas buscando trabajo por ZAT"

label variable prop_formal_no_indep         "Proporción de nomina y patrones sobre total población en dicho ZAT"
label variable prop_independiente_total  "independientes/tot_ZAT"
label variable prop_independiente_trabajando  "independientes a trabajar/total_ZAT"
label variable prop_independiente_buscando  "independientes buscando/total_ZAT"
label variable prop_buscar         "buscando/total_ZAT"
label variable prop_desempleado         "desempleado/tot_ZAT"

cd "$dir_BDD_buffers"

save collapsed_2023.dta, replace

restore 



cd "$dir_BDD_2015"
cd "$dir_BDD_clean"

use "merge_2015.dta", clear

bysort zat_destino: summarize tot

preserve

rename estrato estrato_trabajador

* colapsamos al nivel ZAT destino
collapse (mean) mujer nivel_educativo estrato_trabajador limitaciones_fisicas   total_personas ///
tipo_vivienda_d2 tipo_vivienda_d3 tipo_vivienda_d4 tipo_vivienda_d5 ///
nivel_educativo_d2 nivel_educativo_d3 nivel_educativo_d4 nivel_educativo_d5 nivel_educativo_d7 nivel_educativo_d8 nivel_educativo_d9 nivel_educativo_d11 ///
ocupacion1_d1 ocupacion1_d4 ocupacion1_d5 ocupacion1_d6 ocupacion1_d7 ocupacion1_d8 ocupacion1_d13 ocupacion1_d18 ocupacion1_d19 ocupacion1_d20 ocupacion1_d24 ///
actividad_economica1_d1 actividad_economica1_d3 actividad_economica1_d4 actividad_economica1_d5 actividad_economica1_d7 actividad_economica1_d8 actividad_economica1_d9 actividad_economica1_d10 actividad_economica1_d11 actividad_economica1_d12 actividad_economica1_d13 actividad_economica1_d14 actividad_economica1_d15 actividad_economica1_d16 actividad_economica1_d17 ///
(sum) formal_no_indep independiente_total independiente_trabajando independiente_buscando buscar_trabajo con_trabajo tot desempleado, by(zat_des)

gen prop_formal_no_indep       = formal_no_indep / tot

gen prop_independiente_total = independiente_total / tot

gen prop_independiente_trabajando = independiente_trabajando / tot

gen prop_independiente_buscando = independiente_buscando / tot

gen prop_buscar      = buscar_trabajo / tot

gen prop_desempleado      = desempleado / tot


label variable mujer               "Promedio de mujeres (dummy) por ZAT"
label variable nivel_educativo     "Educación promedio por ZAT" //toca cambiar
label variable estrato_trabajador  "Estrato socioeconómico promedio por ZAT"
label variable limitaciones_fisicas "Promedio de limitaciones físicas (dummy) por ZAT" 

label variable formal_no_indep       "Total trabajadores de nomina y patrones por ZAT"
label variable independiente_total       "Total trabajadores independientes por ZAT"
label variable independiente_trabajando       "Total trabajadores independientes que fueron a trabajar por ZAT"
label variable independiente_buscando      "Total trabajadores independientes que fueron a buscar trabajo por ZAT"
label variable buscar_trabajo      "Total personas buscando trabajo por ZAT"

label variable prop_formal_no_indep         "Proporción de nomina y patrones sobre total población en dicho ZAT"
label variable prop_independiente_total  "independientes/tot_ZAT"
label variable prop_independiente_trabajando  "independientes a trabajar/total_ZAT"
label variable prop_independiente_buscando  "independientes buscando/total_ZAT"
label variable prop_buscar         "buscando/total_ZAT"
label variable prop_desempleado         "desempleado/tot_ZAT"

cd "$dir_BDD_buffers"

save collapsed_2015.dta, replace

restore









