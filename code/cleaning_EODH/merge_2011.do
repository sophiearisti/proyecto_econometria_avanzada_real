
************************************************************************************************************
* VERSION 3
* Merge of the 2011 mobility survey data
* The database will also be further cleaned, with the goal of leaving everything ready to create the buffers
************************************************************************************************************


cd "$dir_BDD_2011"
cd "$dir_BDD_clean"

use nuevo_MOD_viajeTipico.dta, clear

merge m:1 id_hogar id_persona using nuevo_MOD_persona.dta


/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        20,831
        from master                         0  (_merge==1)
        from using                     20,831  (_merge==2)

    Matched                           100,846  (_merge==3)
    -----------------------------------------

This is fine. There are about 20,000 observations from individuals that do not match with the survey that truly matters for our analysis; that is, the survey that is relevant and indicates the destination ZAT is the one that was fully completed and successfully matched.
*/


keep if _merge==3
drop _merge

// merge with the latest dataset; this one contains household characteristics
// this is a one-to-one merge and is performed using sorting

merge m:1 id_hogar using nuevo_MOD_Hogar.dta

// there are households that are not in the dataset we care about, so that is not a problem;
// at least in the other dataset everything was successfully matched

keep if _merge==3
drop _merge
 
 
**************************************************************
* we are going to drop some redundant variables and change the labels of others
**************************************************************


// with this, we keep only the trip reasons:
// Work (1) and Job search (13)
// everything else is dropped

keep if inlist(razon_viaje, 1, 13)

//rename orden id_hogar

//label variable id_hogar "ID del hogar"


/*
Since a person can make several trips on the previous day and may go to the same destination more than once, there are repeated values that are not of interest.
*/

duplicates report id_hogar id_persona zat_destino

duplicates drop id_hogar id_persona zat_destino, force   // drop duplicates with this combination

duplicates report id_hogar id_persona zat_destino        // verify that there are no longer duplicates

// variables that will not be used
drop mun_origen barrio_origen zat_origen

// drop variables that could be used in another study but not in this one
drop numero_viaje f_exp parentesco id_mun_hogar id_predio_hogar idm id_localidad_hogar id_upz_hogar nom_barrio_hogar zat_hogar


******************************************************************
* I am not going to drop the economic activity variables
******************************************************************


*******************************************************************************
* GENERATE DUMMIES FOR CATEGORICAL VARIABLES
*******************************************************************************


//actividad_economica1 tipo_vivienda tipo_propiedad_vivienda razon_viaje nivel_educativo ocupacion1 ocupacion2 ocupacion3 ocupacion4

// For actividad_economica1, tipo_vivienda, tipo_propiedad_vivienda, razon_viaje, and nivel_educativo,
// use the same function

// call the general function that was created in the main script

makedummies nivel_educativo tipo_vivienda tipo_propiedad_vivienda razon_viaje

// For ocupacion1, ocupacion2, ocupacion3, ocupacion4, this must be done with a different function

makemultidummies ocupacion1 ocupacion2, genprefix(ocupacion1)

makemultidummies actividad_economica1 actividad_economica2, genprefix(actividad_economica1)


*******************************************************************************
*GENERAR DUMMIES PARA LA VARIABLE DEPENDIENTE
*******************************************************************************


* Dummy trabajadores formales

gen nomina_patron = .
replace nomina_patron = 1 if inlist(ocupacion1,1,7) | inlist(ocupacion2,1,7)
replace nomina_patron = 0 if !inlist(ocupacion1,1,7) & !inlist(ocupacion2,1,7)

label variable nomina_patron "ocupacion nomina o patron"

* Dummy independientes
gen independiente_total = .
replace independiente_total = 1 if inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6)
replace independiente_total = 0 if !inlist(ocupacion1,5,6) & !inlist(ocupacion2,5,6)
label variable independiente_total "ocupacion trabajador independiente"

gen independiente_trabajando = .
replace independiente_trabajando = 1 if (inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6)) & razon_viaje==1
replace independiente_trabajando = 0 if !inlist(ocupacion1,5,6) & !inlist(ocupacion2,5,6)
label variable independiente_trabajando "trabajador independiente yendo a trabajar"

gen independiente_buscando = .
replace independiente_buscando = 1 if (inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6)) & razon_viaje==13
replace independiente_buscando = 0 if !inlist(ocupacion1,5,6) & !inlist(ocupacion2,5,6)
label variable independiente_buscando "trabajador independiente yendo a buscar trabajo"

gen buscar_trabajo=.
replace buscar_trabajo = 1 if inlist(razon_viaje,13)
replace buscar_trabajo = 0 if !inlist(razon_viaje,13)
label variable buscar_trabajo "la persona busca trabajo"

gen desempleado=.
replace desempleado = 1 if inlist(ocupacion1,20) | inlist(ocupacion2,20)
replace desempleado = 0 if !inlist(ocupacion1,20) & !inlist(ocupacion2,20)
label variable desempleado "desempleado que dice que ocupacion es buscar trabajo"

gen con_trabajo=.
replace con_trabajo = 1 if !inlist(razon_viaje,13)
replace con_trabajo = 0 if inlist(razon_viaje,13)
label variable con_trabajo "empleado"

gen tot=1

gen a2011=1

label variable a2011 "=1 si ano 2011"

save "merge_2011.dta", replace

***************************************************************
* with this, we will perform the collapse by ZAT
***************************************************************

// this dataset will be saved in the buffers data, since it is used to create the georeferenced panel

// in this step we will not take into account the following variables
// (the others will also not be considered and will disappear):
// mean mujer, mean edad, mean educacion, count formal, count informal

// I should end up with one observation per ZAT
