**********************************************************
* VERSION 3
* Merge of the 2015 mobility survey data
* The database will also be further cleaned, with the goal of leaving everything ready to create the buffers
**********************************************************


cd "$dir_BDD_2015"
cd "$dir_BDD_clean"

use nuevo_MOD_viajeTipico.dta, clear


merge m:1 id_hogar id_persona using nuevo_MOD_persona.dta

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                        22,515
        from master                         0  (_merge==1)
        from using                     22,515  (_merge==2)

    Matched                           147,251  (_merge==3)
    -----------------------------------------

This is fine. There are about 22,000 observations from individuals that do not match with the survey that truly matters for our analysis; that is, the survey we care about—the one that indicates the destination ZAT—was fully completed and successfully matched.

*/

keep if _merge==3
drop _merge

// merge with the household characteristics dataset; this contains household-level information
// this is a one-to-one merge and is performed using sorting

merge m:1 id_hogar using nuevo_MOD_Hogar.dta

/*
. merge m:1 id_encuesta using nuevo_MOD_Hogar.dta

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                           147,251  (_merge==3)
    -----------------------------------------
all matched

*/

// in this case, what happens is that this dataset contains information on blocks and minutes walked,
// which is why we merge using trip stages

keep if _merge==3
drop _merge

/* merge 1:m numero_viaje id_persona id_hogar using nuevo_MOD_etapas.dta

keep if _merge==3
drop _merge */

   
**************************************************************
* we are going to drop some redundant variables and change the labels of others
**************************************************************


// with this, we keep only the trip reasons:
// Work (1) and Job search (13)
// everything else is dropped

keep if inlist(razon_viaje, 1, 13)

// rename id_encuesta id_hogar
// label variable id_hogar "Household ID"

/*
Since a person can make several trips on the previous day and may go to the same destination more than once,
there are repeated values that are not of interest.
*/

duplicates report id_hogar id_persona zat_destino

duplicates drop id_hogar id_persona zat_destino, force   // drop duplicates with this combination

duplicates report id_hogar id_persona zat_destino        // verify that there are no longer duplicates

// variables that will not be used
drop zat_hogar trabajo_casa realizo_desplazamiento puntaje_sisben parentesco numero_viaje ///
     longitud_hogar longitud_destino latitud_hogar latitud_destino id_mun_destino ///
     id_mun_hogar id_manzana_hogar id_hogar id clasificacion_sisben nom_barrio_hogar

// drop numero_etapa id_municipio_descenso

// NOTE: working from home is important, but in other surveys it is not used much,
// so I am not sure whether it is worth keeping it.
// If it is to be considered, those who do not leave home and work from home
// should be kept, because that also counts.

*******************************************************************************
* GENERATE DUMMIES FOR CATEGORICAL VARIABLES
*******************************************************************************


makedummies nivel_educativo tipo_vivienda tipo_propiedad_vivienda razon_viaje ocupacion1 actividad_economica1


*******************************************************************************
* GENERATE DUMMIES FOR THE DEPENDENT VARIABLE
*******************************************************************************


//en formal pero no independiente
//(27) "Empleado público", (28) "Empleado de empresa particular" (7) "Patrón o empleador" 
gen formal_no_indep = .
replace formal_no_indep = 1 if inlist(ocupacion1,27,28,7)
replace formal_no_indep = 0 if !inlist(ocupacion1,27,28,7)

label variable formal_no_indep "ocupacion Empleado público, Empleado de empresa particular, Patrón o empleador"

// (5) "Trabajador independiente"  (6) "Profesional independiente" 

* Dummy independientes
gen independiente_total = .
replace independiente_total = 1 if inlist(ocupacion1,5,6)
replace independiente_total = 0 if !inlist(ocupacion1,5,6)

label variable independiente_total "ocupacion trabajador independiente"

gen independiente_trabajando = .
replace independiente_trabajando = 1 if inlist(ocupacion1,5,6) & razon_viaje==1
replace independiente_trabajando = 0 if !inlist(ocupacion1,5,6)
label variable independiente_trabajando "trabajador independiente yendo a trabajar"

gen independiente_buscando = .
replace independiente_buscando = 1 if inlist(ocupacion1,5,6) & razon_viaje==13
replace independiente_buscando = 0 if !inlist(ocupacion1,5,6)
label variable independiente_buscando "trabajador independiente yendo a buscar trabajo"	


// it is better to use the trip motive
// there are people who have an occupation but are looking for a job

gen buscar_trabajo = .
replace buscar_trabajo = 1 if inlist(razon_viaje, 13)
replace buscar_trabajo = 0 if !inlist(razon_viaje, 13)
label variable buscar_trabajo "person is looking for a job"


gen desempleado = .
replace desempleado = 1 if inlist(ocupacion1, 20)
replace desempleado = 0 if !inlist(ocupacion1, 20)
label variable desempleado "unemployed according to occupation (job search)"


// it is better to use the trip motive
// there are people who do not have an occupation but are working

gen con_trabajo = .
replace con_trabajo = 1 if !inlist(razon_viaje, 13)
replace con_trabajo = 0 if inlist(razon_viaje, 13)
label variable con_trabajo "employed"

gen tot=1

gen a2015=1

label variable a2015 "=1 si ano 2015"

save "merge_2015.dta", replace
