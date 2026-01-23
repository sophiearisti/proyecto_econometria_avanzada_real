******************************************************
* VERSION 3
* MERGE of the 2019 mobility survey data
* the database will also be further cleaned, with the goal
* of leaving everything ready to create the buffers
******************************************************

cd "$dir_BDD_2019"
cd "$dir_BDD_clean"


use persona_clean.dta, clear

merge 1:m id_hogar id_persona using viaje_clean.dta

/*
. merge 1:m id_hogar id_persona using viaje_clean.dta
(label lugar_lbl already defined)

    Result                      Number of obs
    -----------------------------------------
    Not matched                        13,339
        from master                    13,339  (_merge==1)
        from using                          0  (_merge==2)

    Matched                           134,497  (_merge==3)
    -----------------------------------------
*/

/*
Result is correct because there are people
who do not appear in the trips module
*/

keep if _merge==3
drop _merge


merge m:1 id_hogar using origen_hogar_clean.dta

/*
. merge m:1 id_hogar using origen_hogar_clean.dta

    Result                      Number of obs
    -----------------------------------------
    Not matched                           628
        from master                         0  (_merge==1)
        from using                        628  (_merge==2)

    Matched                           152,310  (_merge==3)
    -----------------------------------------

*/
/*
Again, this is fine.
Not all households have trip information.
*/

keep if _merge==3
drop _merge

**************************************************************
* we will drop some redundant variables and relabel others
**************************************************************

// redundant variables
drop nro_mapa nom_utam_hogar factor nom_mun_hogar lugar_origen lugar_destino otro_motivo_viaje

// drop variables that could be useful in other research
// but are not needed here
drop parentesco f_exp id_viaje zat_origen mun_origen mun_destino utam_origen utam_destino estado sector seccion id_manzana_hogar nom_barrio_hogar latitud longitud zat_hogar vivienda nom_localidad_hogar

// keep only the following trip reasons:
// Work (1) and Job search (13)
// all others are dropped
keep if inlist(razon_viaje, 1, 13)

/*
A person may have made several trips to the same destination
for the same reason; those repetitions are not of interest
*/

duplicates report id_hogar id_persona zat_destino
duplicates drop id_hogar id_persona zat_destino, force
duplicates report id_hogar id_persona zat_destino

// occasional trips are not useful
drop if ocasional==1

drop lunes martes miercoles jueves viernes sabado domingo ocasional

label variable id_hogar "Household ID"
destring id_hogar, replace
label variable id_persona "Person ID"
label variable actividad_economica1 "Economic activity"

*******************************************************************************
* GENERATE DUMMIES FOR CATEGORICAL VARIABLES
*******************************************************************************

// For actividad_economica1, tipo_vivienda, tipo_propiedad_vivienda,
// razon_viaje, nivel_educativo, use the same function
makedummies actividad_economica1 tipo_vivienda tipo_propiedad_vivienda razon_viaje nivel_educativo

// For ocupacion1–ocupacion4, a different function is required
makemultidummies ocupacion1 ocupacion2 ocupacion3 ocupacion4, genprefix(ocupacion1)

*******************************************************************************
* GENERATE DUMMIES FOR THE DEPENDENT VARIABLE
*******************************************************************************

// formal but not independent:
// (27) Public employee
// (28) Private employee
// (7) Employer
gen formal_no_indep = .
replace formal_no_indep = 1 if inlist(ocupacion1,27,28,7) | inlist(ocupacion2,27,28,7) | inlist(ocupacion3,27,28,7) | inlist(ocupacion4,27,28,7)
replace formal_no_indep = 0 if !inlist(ocupacion1,27,28,7) & !inlist(ocupacion2,27,28,7) & !inlist(ocupacion3,27,28,7) & !inlist(ocupacion4,27,28,7)
label variable formal_no_indep "Public/private employee or employer"

gen vendedor_informal = .
replace vendedor_informal = 1 if ocupacion1==26 | ocupacion2==26 | ocupacion3==26 | ocupacion4==26
replace vendedor_informal = 0 if ocupacion1!=26 & ocupacion2!=26 & ocupacion3!=26 & ocupacion4!=26
label variable vendedor_informal "Informal street vendor"

// (5) Self-employed worker
// (6) Independent professional
gen independiente_total = .
replace independiente_total = 1 if inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6) | inlist(ocupacion3,5,6) | inlist(ocupacion4,5,6)
replace independiente_total = 0 if !inlist(ocupacion1,5,6) & !inlist(ocupacion2,5,6) & !inlist(ocupacion3,5,6) & !inlist(ocupacion4,5,6)
label variable independiente_total "Independent worker"

gen independiente_trabajando = .
replace independiente_trabajando = 1 if (inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6) | inlist(ocupacion3,5,6) | inlist(ocupacion4,5,6)) & razon_viaje==1
replace independiente_trabajando = 0 if !inlist(ocupacion1,5,6) & !inlist(ocupacion2,5,6) & !inlist(ocupacion3,5,6) & !inlist(ocupacion4,5,6)
label variable independiente_trabajando "Independent worker going to work"

gen independiente_buscando = .
replace independiente_buscando = 1 if (inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6) | inlist(ocupacion3,5,6) | inlist(ocupacion4,5,6)) & razon_viaje==13
replace independiente_buscando = 0 if !inlist(ocupacion1,5,6) & !inlist(ocupacion2,5,6) & !inlist(ocupacion3,5,6) & !inlist(ocupacion4,5,6)
label variable independiente_buscando "Independent worker searching for a job"

// it is better to use the trip motive
// some people have an occupation but are searching for a job
gen buscar_trabajo = .
replace buscar_trabajo = 1 if razon_viaje==13
replace buscar_trabajo = 0 if razon_viaje!=13
label variable buscar_trabajo "Person is looking for a job"

gen desempleado = .
replace desempleado = 1 if inlist(ocupacion1,20) | inlist(ocupacion2,20) | inlist(ocupacion3,20) | inlist(ocupacion4,20)
replace desempleado = 0 if !inlist(ocupacion1,20) & !inlist(ocupacion2,20) & !inlist(ocupacion3,20) & !inlist(ocupacion4,20)
label variable desempleado "Unemployed (occupation reports job search)"

// some people have no occupation but are working
gen con_trabajo = .
replace con_trabajo = 1 if razon_viaje!=13
replace con_trabajo = 0 if razon_viaje==13
label variable con_trabajo "Employed"
