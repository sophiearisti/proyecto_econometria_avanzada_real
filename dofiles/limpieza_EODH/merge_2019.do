**********************************************************
*VERSION 1
*MERGE de los datos de la encuesta de movilidad del 2019
*tambien se limpiara aun mas la bdd, esto con el objetivo de dejar todo listo para crear los buffers
**********************************************************

cd "$dir_BDD_2019"
cd "$dir_BDD_clean"

//personas 1 a muchos con viajes, llave foranea doble
//viajes 1 a muchas con etapas, foranea doble (no lo usare al final)
//hogares 1 a muchos con personas

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

esta bien, porque hay personas que no estan en el modulo de viajes
*/

keep if _merge==3
drop _merge

merge m:1 id_hogar using origen_hogar_clean.dta

/*
nuevamente esta bien
. merge m:1 id_hogar using origen_hogar_clean.dta

    Result                      Number of obs
    -----------------------------------------
    Not matched                           628
        from master                         0  (_merge==1)
        from using                        628  (_merge==2)

    Matched                           152,310  (_merge==3)
    -----------------------------------------

en hogares no todos tienen info del viaje

*/

keep if _merge==3
drop _merge


**************************************************************
*vamos a borrar algunas variables redundantes y otras les cambiaremos el label
**************************************************************

//variables redundantes
drop nro_mapa utam tipo_vivienda vivienda factor municipio lugar_origen lugar_destino camino_cuadras camino_minutos


//con esto solo nos quedamos con las razones de viaje de:
//Trabajar (1) y Buscar trabajo (13)
//lo otro se dropea
keep if inlist(motivo_viaje, 1, 13)

//solo dejar los que en ocupacion 1 o en ocupacion 2 o en 3 o en 4 sean:
//  Trabajador sin remuneración (15), Empleado de empresa particular (16), Profesional independiente (18), Trabajador independiente (19), Vendedor informal (21), Patrón o empleador (20),  Buscar trabajo (33), Empleado público
keep if inlist(ocupacion1, 15, 16, 18, 19, 20, 21, 33) | inlist(ocupacion2, 15, 16, 18, 19, 20, 21, 33) | inlist(ocupacion3, 15, 16, 18, 19, 20, 21, 33) | inlist(ocupacion4, 15, 16, 18, 19, 20, 21, 33)

//dejar las actividades economicas que tinen que ver con mi pregunta de investigacion

/****************************************************************************
	Nota, ya no se si es verdaderamente necesario, porque igual esta bien con todos, no?	
****************************************************************************/


//tab actividad_economica, nolabel

//keep if inlist(actividad_economica,7,) 

//no me sirve si el viaje es ocasional
drop if ocasional==1

drop lunes martes miercoles jueves viernes sabado domingo ocasional

label variable id_hogar "ID del hogar"

label variable id_persona "ID de la persona"

label variable actividad_economica1 "actividad economica a la que se dedica"

//generar dos variables multicolineales


gen formal = .
gen vendedor_informal = .
gen independiente= .

replace formal = 1 if ocupacion2 == 16 | ocupacion2 == 20 | ocupacion1 == 16 | ocupacion1 == 20 | ocupacion3 == 16 | ocupacion3 == 20 | ocupacion4 == 16 | ocupacion4 == 20 

replace formal = 0 if ocupacion2 != 16 & ocupacion2 != 20 & ocupacion2 != 33 & ocupacion1 != 16 & ocupacion1 != 20 & ocupacion1 != 33 & ocupacion3 != 16 & ocupacion3 != 20 & ocupacion3 != 33 & ocupacion4 != 16 & ocupacion4 != 20 & ocupacion4 != 33

replace informal = 1 if inlist(ocupacion2, 15, 18, 19, 21) | inlist(ocupacion1, 15, 18, 19, 21) | inlist(ocupacion3, 15, 18, 19, 21) | inlist(ocupacion4, 15, 18, 19, 21)

replace informal = 0 if !inlist(ocupacion2, 15, 18, 19, 21, 33) & !inlist(ocupacion1, 15, 18, 19, 21, 33) & !inlist(ocupacion3, 15, 18, 19, 21, 33) & !inlist(ocupacion4, 15, 18, 19, 21, 33)

label variable formal "ocupacion formal"

label variable informal "ocupacion informal"

save "merge_2019.dta", replace

***************************************************************
*con esto haremos el collapse segun el ZAT
***************************************************************

//este se guardara en el data de los buffers porque con eso se crea el panel georeferenciado

//en este no vamos a tener en cuenta las siguientes vars  (las otras no las tendremos en cuenta y se desaparecen):
//mean mujer, mean edad, mean educacion, count formal, count informal

//me debe quedar un dato por zat 

preserve

* colapsamos al nivel ZAT destino
collapse (mean) mujer edad nivel_educativo ingreso///
         (sum) formal informal, by(zat_destino)

cd "$dir_BDD_buffers"

save collapsed_2019.dta, replace

restore 

clear

