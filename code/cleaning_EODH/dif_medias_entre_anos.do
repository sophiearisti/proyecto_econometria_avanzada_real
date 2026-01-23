**********************************************************
*VERSION 3
*difference in means across years, with the objective of identifying
*which characteristics should be controlled for in the panel
**********************************************************
*ssc install ietoolkit

cd "$dir_BDD_2023"
cd "$dir_BDD_clean"

use "merge_2023.dta", clear

cd "$dir_BDD_2019"
cd "$dir_BDD_clean"

append using merge_2019.dta

drop id_hogar id_persona ocupacion2 ocupacion3 ocupacion4

cd "$dir_BDD_2011"
cd "$dir_BDD_clean"

append using merge_2011.dta

drop actividad_economica2 ocupacion2 id_persona id_hogar

replace tipo_propiedad_vivienda=. if tipo_propiedad_vivienda==8

cd "$dir_BDD_2015"
cd "$dir_BDD_clean"

append using merge_2015.dta

drop actividad_economica1_d89

//we drop variables that exist exclusively in some datasets
drop tipo_propiedad_vivienda_d8 nomina_patron ocupacion1_d2 ocupacion1_d3 ocupacion1_d9 actividad_economica1_d2

//first, compare differences in means between 2011 and 2015
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

//second, compare differences in means between 2019 and 2023
preserve

drop if a2011==1 | a2015==1

replace a2019=0 if a2019==.

global evalVars estrato edad limitaciones_fisicas mujer total_personas total_personas_mas_5 ///
    nivel_educativo_d* tipo_vivienda_d* ///
	ocupacion1_d* actividad_economica1_d* 
	
cd "$dir_reg_dif_med_results"

iebaltab $evalVars , groupvar(a2019) control(0) savexlsx(difmedias_entre_anos_2019x2023) replace

restore 

//third, compare differences in means between 2015 and 2019
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
* with this we will collapse at the ZAT level
***************************************************************

// this will be saved in the buffers data because it is used to create the georeferenced panel

// in this one we will NOT take into account the following variables
// (the others will also not be taken into account and will disappear):
// mean mujer, mean edad, mean educacion, count formal, count informal

// I should end up with one observation per ZAT

**************************************************************************
* 2019
**************************************************************************

cd "$dir_BDD_2019"
cd "$dir_BDD_clean"

use "merge_2019.dta", clear

bysort zat_destino: summarize tot

preserve

rename estrato estrato_trabajador

// still missing walking minutes and walking blocks

* collapse to destination ZAT level
// edad nivel_educativo limitaciones_fisicas i.ocupacion1 mujer i.actividad_economica1 camino_cuadras camino_minutos i.tipo_vivienda i.tipo_propiedad_vivienda estrato total_personas total_personas_mas_5

collapse (mean) mujer ingreso nivel_educativo estrato_trabajador limitaciones_fisicas total_personas ///
tipo_vivienda_d2 tipo_vivienda_d3 tipo_vivienda_d4 tipo_vivienda_d5 ///
nivel_educativo_d2 nivel_educativo_d3 nivel_educativo_d4 nivel_educativo_d5 nivel_educativo_d7 nivel_educativo_d8 nivel_educativo_d9 nivel_educativo_d11 ///
ocupacion1_d1 ocupacion1_d4 ocupacion1_d5 ocupacion1_d6 ocupacion1_d7 ocupacion1_d8 ocupacion1_d13 ocupacion1_d18 ocupacion1_d19 ocupacion1_d20 ocupacion1_d24 ///
actividad_economica1_d1 actividad_economica1_d3 actividad_economica1_d4 actividad_economica1_d5 actividad_economica1_d7 actividad_economica1_d8 actividad_economica1_d9 actividad_economica1_d10 actividad_economica1_d11 actividad_economica1_d12 actividad_economica1_d13 actividad_economica1_d14 actividad_economica1_d15 actividad_economica1_d16 actividad_economica1_d17 ///
(sum) formal_no_indep vendedor_informal independiente_total independiente_trabajando independiente_buscando buscar_trabajo con_trabajo tot desempleado, by(zat_destino)

// divide payroll workers and independents by number of workers IN THAT ZAT
// divide job searchers by total population IN THAT ZAT

gen prop_formal_no_indep       = formal_no_indep / tot
gen prop_independiente_total  = independiente_total / tot
gen prop_independiente_trabajando = independiente_trabajando / tot
gen prop_independiente_buscando   = independiente_buscando / tot
gen prop_buscar               = buscar_trabajo / tot
gen prop_desempleado          = desempleado / tot

label variable mujer                "Average women (dummy) per ZAT"
label variable nivel_educativo      "Average education per ZAT" // needs revision
label variable estrato_trabajador   "Average socioeconomic stratum per ZAT"
label variable limitaciones_fisicas "Average physical limitations (dummy) per ZAT"

label variable formal_no_indep           "Total payroll workers and employers per ZAT"
label variable independiente_total      "Total independent workers per ZAT"
label variable independiente_trabajando "Independent workers who went to work per ZAT"
label variable independiente_buscando   "Independent workers who searched for work per ZAT"
label variable buscar_trabajo            "Total people searching for work per ZAT"

label variable prop_formal_no_indep        "Payroll and employers / total ZAT"
label variable prop_independiente_total   "Independents / total ZAT"
label variable prop_independiente_trabajando "Independents working / total ZAT"
label variable prop_independiente_buscando   "Independents searching / total ZAT"
label variable prop_buscar                "Searching / total ZAT"
label variable prop_desempleado           "Unemployed / total ZAT"

cd "$dir_BDD_collapsed"
save collapsed_2019.dta, replace

restore

**************************************************************************
* 2011
**************************************************************************

cd "$dir_BDD_2011"
cd "$dir_BDD_clean"

use "merge_2011.dta", clear

bysort zat_destino: summarize tot

preserve

rename estrato estrato_trabajador

* collapse to destination ZAT level

// still missing walking minutes and walking blocks

collapse (mean) mujer ingreso nivel_educativo estrato_trabajador limitaciones_fisicas total_personas ///
tipo_vivienda_d2 tipo_vivienda_d3 tipo_vivienda_d4 tipo_vivienda_d5 ///
nivel_educativo_d2 nivel_educativo_d3 nivel_educativo_d4 nivel_educativo_d5 nivel_educativo_d7 nivel_educativo_d8 nivel_educativo_d9 nivel_educativo_d11 ///
ocupacion1_d1 ocupacion1_d4 ocupacion1_d5 ocupacion1_d6 ocupacion1_d7 ocupacion1_d8 ocupacion1_d13 ocupacion1_d18 ocupacion1_d19 ocupacion1_d20 ocupacion1_d24 ///
actividad_economica1_d1 actividad_economica1_d3 actividad_economica1_d4 actividad_economica1_d5 actividad_economica1_d7 actividad_economica1_d8 actividad_economica1_d9 actividad_economica1_d10 actividad_economica1_d11 actividad_economica1_d12 actividad_economica1_d13 actividad_economica1_d14 actividad_economica1_d15 actividad_economica1_d16 actividad_economica1_d17 ///
(sum) nomina_patron independiente_total independiente_trabajando independiente_buscando buscar_trabajo con_trabajo tot desempleado, by(zat_destino)

// divide payroll workers and independents by number of workers IN THAT ZAT
// divide job searchers by total population IN THAT ZAT

gen prop_nomina_patron              = nomina_patron / tot
gen prop_independiente_total        = independiente_total / tot
gen prop_independiente_trabajando   = independiente_trabajando / tot
gen prop_independiente_buscando     = independiente_buscando / tot
gen prop_buscar                     = buscar_trabajo / tot
gen prop_desempleado                = desempleado / tot

label variable mujer                "Average women (dummy) per ZAT"
label variable nivel_educativo      "Average education per ZAT" // needs revision
label variable estrato_trabajador   "Average socioeconomic stratum per ZAT"
label variable limitaciones_fisicas "Average physical limitations (dummy) per ZAT"

label variable nomina_patron           "Total payroll workers and employers per ZAT"
label variable independiente_total    "Total independent workers per ZAT"
label variable independiente_trabajando "Independent workers who went to work per ZAT"
label variable independiente_buscando  "Independent workers who searched for work per ZAT"
label variable buscar_trabajo          "Total people searching for work per ZAT"

label variable prop_nomina_patron        "Payroll and employers / total ZAT"
label variable prop_independiente_total "Independents / total ZAT"
label variable prop_independiente_trabajando "Independents working / total ZAT"
label variable prop_independiente_buscando   "Independents searching / total ZAT"
label variable prop_buscar              "Searching / total ZAT"
label variable prop_desempleado         "Unemployed / total ZAT"

cd "$dir_BDD_collapsed"
save collapsed_2011.dta, replace

restore

**************************************************************************
* 2023
**************************************************************************

cd "$dir_BDD_2023"
cd "$dir_BDD_clean"

use "merge_2023.dta", clear

bysort zat_destino: summarize tot

preserve

rename estrato estrato_trabajador

* collapse to destination ZAT level

collapse (mean) mujer ingreso nivel_educativo estrato_trabajador limitaciones_fisicas total_personas ///
tipo_vivienda_d2 tipo_vivienda_d3 tipo_vivienda_d4 tipo_vivienda_d5 ///
nivel_educativo_d2 nivel_educativo_d3 nivel_educativo_d4 nivel_educativo_d5 nivel_educativo_d7 nivel_educativo_d8 nivel_educativo_d9 nivel_educativo_d11 ///
ocupacion1_d1 ocupacion1_d4 ocupacion1_d5 ocupacion1_d6 ocupacion1_d7 ocupacion1_d8 ocupacion1_d13 ocupacion1_d18 ocupacion1_d19 ocupacion1_d20 ocupacion1_d24 ///
actividad_economica1_d1 actividad_economica1_d3 actividad_economica1_d4 actividad_economica1_d5 actividad_economica1_d7 actividad_economica1_d8 actividad_economica1_d9 actividad_economica1_d10 actividad_economica1_d11 actividad_economica1_d12 actividad_economica1_d13 actividad_economica1_d14 actividad_economica1_d15 actividad_economica1_d16 actividad_economica1_d17 ///
(sum) formal_no_indep vendedor_informal independiente_total independiente_trabajando independiente_buscando buscar_trabajo con_trabajo tot desempleado, by(zat_des)

// generate proportions

gen prop_formal_no_indep       = formal_no_indep / tot
gen prop_independiente_total  = independiente_total / tot
gen prop_independiente_trabajando = independiente_trabajando / tot
gen prop_independiente_buscando   = independiente_buscando / tot
gen prop_buscar               = buscar_trabajo / tot
gen prop_desempleado          = desempleado / tot

cd "$dir_BDD_collapsed"
save collapsed_2023.dta, replace

restore

**************************************************************************
* 2015
**************************************************************************

cd "$dir_BDD_2015"
cd "$dir_BDD_clean"

use "merge_2015.dta", clear

bysort zat_destino: summarize tot

preserve

rename estrato estrato_trabajador

* collapse to destination ZAT level

collapse (mean) mujer ingreso nivel_educativo estrato_trabajador limitaciones_fisicas total_personas ///
tipo_vivienda_d2 tipo_vivienda_d3 tipo_vivienda_d4 tipo_vivienda_d5 ///
nivel_educativo_d2 nivel_educativo_d3 nivel_educativo_d4 nivel_educativo_d5 nivel_educativo_d7 nivel_educativo_d8 nivel_educativo_d9 nivel_educativo_d11 ///
ocupacion1_d1 ocupacion1_d4 ocupacion1_d5 ocupacion1_d6 ocupacion1_d7 ocupacion1_d8 ocupacion1_d13 ocupacion1_d18 ocupacion1_d19 ocupacion1_d20 ocupacion1_d24 ///
actividad_economica1_d1 actividad_economica1_d3 actividad_economica1_d4 actividad_economica1_d5 actividad_economica1_d7 actividad_economica1_d8 actividad_economica1_d9 actividad_economica1_d10 actividad_economica1_d11 actividad_economica1_d12 actividad_economica1_d13 actividad_economica1_d14 actividad_economica1_d15 actividad_economica1_d16 actividad_economica1_d17 ///
(sum) formal_no_indep independiente_total independiente_trabajando independiente_buscando buscar_trabajo con_trabajo tot desempleado, by(zat_des)

// generate proportions

gen prop_formal_no_indep       = formal_no_indep / tot
gen prop_independiente_total  = independiente_total / tot
gen prop_independiente_trabajando = independiente_trabajando / tot
gen prop_independiente_buscando   = independiente_buscando / tot
gen prop_buscar               = buscar_trabajo / tot
gen prop_desempleado          = desempleado / tot

cd "$dir_BDD_collapsed"
save collapsed_2015.dta, replace

restore
