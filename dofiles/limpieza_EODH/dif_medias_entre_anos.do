**********************************************************
*VERSION 1
*diferencia de medias estre anos, con el objetivo de saber por cuales caracteristicas se debera controlar en el panel
**********************************************************
ssc install ietoolkit

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

//vamos a hacer drop de variables que exclusivamente tienen unos datasets
drop tipo_propiedad_vivienda_d8 nomina_patron ocupacion1_d2 ocupacion1_d3 ocupacion1_d9 actividad_economica1_d2

//primero comparar con diferencia de medias las entre 2011 y 2019
preserve

drop if a2023==1

drop tipo_propiedad_vivienda_d7 ocupacion1_d22 ocupacion1_d25 ocupacion1_d26 ocupacion1_d27 ocupacion1_d28 ocupacion1_d29 actividad_economica1_d18 actividad_economica1_d19

replace a2019=0 if a2019==.

global evalVars estrato edad limitaciones_fisicas mujer total_personas total_personas_mas_5 ///
    camino_cuadras camino_minutos ///
    nivel_educativo_d* tipo_vivienda_d* tipo_propiedad_vivienda_d* ///
	ocupacion1_d* actividad_economica1_d*
	
cd "$dir_reg_dif_med_results"

iebaltab $evalVars , groupvar(a2019) control(0) savexlsx(difmedias_entre_anos_2019x2011) replace

restore

//segundo comparar con diferencia de medias las entre 2019 y 2023
preserve

drop if a2011==1

drop ocupacion1_d22 


replace a2019=0 if a2019==.

global evalVars estrato edad limitaciones_fisicas mujer total_personas total_personas_mas_5 ///
    nivel_educativo_d* tipo_vivienda_d* ///
	ocupacion1_d* actividad_economica1_d*
	
cd "$dir_reg_dif_med_results"

iebaltab $evalVars , groupvar(a2019) control(0) savexlsx(difmedias_entre_anos_2019x2023) replace

restore 


//tercero comparar con diferencia de medias las entre 2011 y 2023
preserve

drop if a2019==1

drop ocupacion1_d25 ocupacion1_d26 ocupacion1_d27 ocupacion1_d28 ocupacion1_d29 actividad_economica1_d18 actividad_economica1_d19 ocupacion1_d22

replace a2011=0 if a2011==.

global evalVars estrato edad limitaciones_fisicas mujer total_personas total_personas_mas_5 ///
    nivel_educativo_d* tipo_vivienda_d* ///
	ocupacion1_d* actividad_economica1_d*
	
cd "$dir_reg_dif_med_results"

iebaltab $evalVars , groupvar(a2011) control(0) savexlsx(difmedias_entre_anos_2011x2023) replace

restore 
