**********************************************************
*VERSION 2
*MERGE de los datos de la encuesta de movilidad del 2011
*tambien se limpiara aun mas la bdd, esto con el objetivo de dejar todo listo para crear los buffers
**********************************************************

cd "$dir_BDD_2011"
cd "$dir_BDD_clean"

use nuevo_MOD_viajeTipico.dta, clear

//orden es el id del hogar 

merge m:1 orden id_perso using nuevo_MOD_persona.dta

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                        20,831
        from master                         0  (_m
> erge==1)
        from using                     20,831  (_m
> erge==2)

    Matched                           100,846  (_m
> erge==3)
    -----------------------------------------

esta bien, hay 20000 de los datos de las personas que no hacen match con la encuesta que verdaderamente nos importa; es decir, la que nos importa y nos indica el zat de destino es la que si se pudo llenar en su totalidad. 

*/

keep if _merge==3
drop _merge

//hacer merge con el ultimo data set, este nos cuenta las caracteristicas del hogar
//este es un merge de 1 a 1 y se hace con orden

merge m:1 orden using nuevo_MOD_Hogar.dta

//hay hogares que no estan en el dataset que nos importa, entonces no hay problema, por lo menos en el otro si se asocio todo
keep if _merge==3
drop _merge
   
**************************************************************
*vamos a borrar algunas variables redundantes y otras les cambiaremos el label
**************************************************************

//con esto solo nos quedamos con las razones de viaje de:
//Trabajar (1) y Buscar trabajo (13)
//lo otro se dropea

keep if inlist(razon_viaje, 1, 13)

rename orden id_hogar

/*
Como una persona puede hacer varios viajes el dia anterior y puede que al mismo destino, hay valores repetidos que no nos interesa
*/

duplicates report id_hogar id_perso zat_destino

duplicates drop id_hogar id_perso zat_destino, force   // borrar duplicados que tengan esa combinacion

duplicates report id_hogar id_perso zat_destino   // comprobar que ya no haya duplicados


//variables que no usare
drop mun_origen barrio_origen zat_origen

******************************************************************
*no voy a quitar las actividades economicas
*****************************************************************

label variable id_hogar "ID del hogar"

********************************************************************************
*Generar variable multicolineal
********************************************************************************

* Dummy trabajadores formales

gen nomina_patron = .
replace nomina_patron = 1 if inlist(ocupacion1,1,7) | inlist(ocupacion2,1,7)
replace nomina_patron = 0 if inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6)

label variable nomina_patron "ocupacion nomina o patron"

* Dummy independientes
gen independiente = .
replace independiente = 1 if inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6)
replace independiente = 0 if inlist(ocupacion1,1,7) | inlist(ocupacion2,1,7)

label variable independiente "ocupacion trabajador independiente"

gen buscar_trabajo=.
replace buscar_trabajo = 1 if inlist(ocupacion1,20)
replace buscar_trabajo = 0 if !inlist(ocupacion1,20)

label variable buscar_trabajo "desempleado"

gen con_trabajo=.
replace con_trabajo = 1 if !inlist(ocupacion1,20)
replace con_trabajo = 0 if inlist(ocupacion1,20)

label variable con_trabajo "empleado"

save "merge_2011.dta", replace

***************************************************************
*con esto haremos el collapse segun el ZAT
***************************************************************

//este se guardara en el data de los buffers porque con eso se crea el panel georeferenciado

//en este no vamos a tener en cuenta las siguientes vars  (las otras no las tendremos en cuenta y se desaparecen):
//mean mujer, mean edad, mean educacion, count formal, count informal

//me debe quedar un dato por zat 

bysort zat_destino: summarize con_trabajo

preserve

rename estrato estrato_trabajador

* colapsamos al nivel ZAT destino

collapse (mean) mujer edad nivel_educativo estrato_trabajador limitaciones_fisicas ingreso (sum) nomina_patron independiente buscar_trabajo con_trabajo, by(zat_destino)
		 
//dividir (sum) nomina_patron (sum) independiente por cantTrabajadores DE ESA ZAT
//dividir buscar_trabajo por cantTotal DE ESA ZAT

gen prop_nomina_patron       = nomina_patron / con_trabajo

gen prop_independiente = independiente / con_trabajo

scalar cantTotal= con_trabajo+buscar_trabajo

gen prop_buscar      = buscar_trabajo / cantTotal


label variable mujer               "Promedio de mujeres (dummy) por ZAT"
label variable edad                "Edad promedio por ZAT"
label variable nivel_educativo     "Educación promedio por ZAT" //toca cambiar
label variable estrato_trabajador  "Estrato socioeconómico promedio por ZAT"
label variable limitaciones_fisicas "Promedio de limitaciones físicas (dummy) por ZAT" 

label variable nomina_patron       "Total trabajadores de nomina y patrones por ZAT"
label variable independiente       "Total trabajadores independientes por ZAT"
label variable buscar_trabajo      "Total personas buscando trabajo por ZAT"

label variable prop_nomina_patron         "Proporción de nomina y patrones sobre total trabajadores en dicho ZAT"
label variable prop_independiente  "Proporción de independientes sobre total trabajadores en dicho ZAT"
label variable prop_buscar         "Proporción de buscadores de trabajo sobre total población en dicho ZAT"


cd "$dir_BDD_buffers"

save collapsed_2011.dta, replace

restore 

use "collapsed_2011.dta"




//solo dejar los que en ocupacion 1 o en ocupacion 2 sean:
//  Empleado de nómina (1), Trabajador independiente (5), Profesional independiente (6), Patrón o empleador (7),  Buscar trabajo (20)

/*
Componentes de la nómina en Colombia
Una nómina en Colombia incluye varios componentes, tanto devengos como deducciones: 
Salario base: El sueldo principal acordado en el contrato. 
Horas extras y recargos: Pago adicional por horas trabajadas más allá del horario legal, o por trabajo nocturno, dominical o festivo. 
Bonificaciones y comisiones: Pagos adicionales según el desempeño o acuerdos contractuales. 
Subsidio de transporte: Auxilio de transporte para empleados con ingresos inferiores a dos salarios mínimos. 
Deducciones:
Seguridad Social: Aportes a salud (EPS) y pensión. 
Fondo de Solidaridad Pensional: Obligatorio para quienes ganan más de cuatro salarios mínimos. 
Retención en la fuente: Un anticipo del impuesto de renta para empleados con ingresos superiores a 95 UVT. 
Prestaciones sociales: Beneficios como cesantías y prima. 
*/

//keep if inlist(ocupacion1, 1, 5, 6, 7, 20) | inlist(ocupacion2, 1, 5, 6, 7, 20)

