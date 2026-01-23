**********************************************************
* VERSION 3
* MERGE of the 2023 mobility survey data
* the database will also be further cleaned, with the goal
* of leaving everything ready to create the buffers
**********************************************************
cd "$dir_BDD_2023"
cd "$dir_BDD_clean"

// same as before: we need to perform two merges

use "nuevo_MOD_persona.dta", clear

merge 1:m id_persona id_hogar using nuevo_MOD_viajes.dta

/*
The merge is correct.

There are people who do not appear in the trips module,
which is expected.
*/

/*
. merge 1:m cod_per cod_hg using nuevo_MOD_viajes.dta
(label mujer_lbl already defined)

    Result                      Number of obs
    -----------------------------------------
    Not matched                        19,017
        from master                    19,017  (_merge==1)
        from using                          0  (_merge==2)

    Matched                           100,174  (_merge==3)
    -----------------------------------------

. 
end of do-file

*/

keep if _merge==3
drop _merge


merge m:1 id_hogar using nuevo_MOD_hogar.dta


/*
This is fine: there are around 1,000 households
that do not appear in the other survey modules.
*/

/*
. merge m:1 cod_hg using nuevo_MOD_hogar.dta

    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,247
        from master                         0  (_merge==1)
        from using                      1,247  (_merge==2)

    Matched                           100,174  (_merge==3)
    -----------------------------------------
*/

keep if _merge==3
drop _merge

**************************************************************
* we will drop some redundant variables and relabel others
**************************************************************

// redundant or unnecessary variables
drop key_hg key_persona fexp_per5años cod_vj orden_vj zat_origen utam_origen upl_origen nom_mun_origen key_pers key_pers_viaja key_viaje localidad_origen orden cod_viv fexp_vj fexp_hg realiza_desplazamientos

// variables that may be useful for other research,
// but are not needed here
drop nom_barrio_hogar id_barrio_hogar tipo_zona_hg id_manzana_hogar nom_localidad_hogar id_localidad_hogar nom_mun_hogar id_mun_hogar nom_upl_hogar nom_utam_hogar motivo_viaje_cuidado nom_mun_destino localidad_destino upl_destino utam_destino otro_vj zat_hogar id_utam_hogar id_upl_hogar nom_mun_hogar

// with this we keep only the following trip reasons:
// Job search, Going to work [stored as strings]
// All other reasons are dropped
keep if inlist(razon_viaje, 1, 13)

/*
A person may have made several trips to the same destination
for the same reason; those repetitions are not of interest
*/

duplicates report id_persona id_hogar zat_destino

duplicates drop id_persona id_hogar zat_destino, force   // drop duplicates with this combination

duplicates report id_persona id_hogar zat_destino        // check that no duplicates remain


// occasional or sporadic trips are not useful
// labels: Sporadically during the year, Occasionally during the month, Never
drop if strpos(frecuencia_viaje, "Esporádicamente en el año") | ///
        strpos(frecuencia_viaje, "Nunca") | ///
        strpos(frecuencia_viaje, "No aplica")
		
tostring id_hogar, replace		
*******************************************************************************
* GENERATE DUMMIES FOR CATEGORICAL VARIABLES
*******************************************************************************

makedummies actividad_economica1 ocupacion1 nivel_educativo razon_viaje tipo_vivienda

*******************************************************************************
* GENERATE DUMMIES FOR THE DEPENDENT VARIABLE
*******************************************************************************

gen formal_no_indep = .
replace formal_no_indep = 1 if inlist(ocupacion1,27,28,7)
replace formal_no_indep = 0 if !inlist(ocupacion1,27,28,7)
label variable formal_no_indep "occupation: public employee, private employee, or employer"

gen vendedor_informal = .
replace vendedor_informal = 1 if ocupacion1==26 
replace vendedor_informal = 0 if ocupacion1!=26
label variable vendedor_informal "occupation: informal vendor"

* Independent worker dummy
gen independiente_total = .
replace independiente_total = 1 if inlist(ocupacion1,5,6)
replace independiente_total = 0 if !inlist(ocupacion1,5,6)
label variable independiente_total "occupation: independent worker"

gen independiente_trabajando = .
replace independiente_trabajando = 1 if inlist(ocupacion1,5,6) & razon_viaje==1
replace independiente_trabajando = 0 if !inlist(ocupacion1,5,6)
label variable independiente_trabajando "independent worker going to work"

gen independiente_buscando = .
replace independiente_buscando = 1 if inlist(ocupacion1,5,6) & razon_viaje==13
replace independiente_buscando = 0 if !inlist(ocupacion1,5,6)
label variable independiente_buscando "independent worker searching for a job"

// it is better to rely on trip motive
// some people have an occupation but are searching for a job
gen buscar_trabajo = .
replace buscar_trabajo = 1 if inlist(razon_viaje,13)
replace buscar_trabajo = 0 if !inlist(razon_viaje,13)
label variable buscar_trabajo "person is looking for a job"


gen desempleado = .
replace desempleado = 1 if inlist(ocupacion1,20)
replace desempleado = 0 if !inlist(ocupacion1,20)
label variable desempleado "unemployed (occupation reports job search)"

// some people do not have an occupation but are working
gen con_trabajo = .
replace con_trabajo = 1 if !inlist(razon_viaje,13)
replace con_trabajo = 0 if inlist(razon_viaje,13)
label variable con_trabajo "employed"	

// used later to collapse and count the number of people per ZAT
gen tot = 1

gen a2023 = 1
label variable a2023 "=1 if year is 2023"

save "merge_2023.dta", replace
