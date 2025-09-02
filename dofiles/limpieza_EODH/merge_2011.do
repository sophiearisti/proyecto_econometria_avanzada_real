**********************************************************
*VERSION 1
*MERGE de los datos de la encuesta de movilidad del 2011
*tambien se limpiara aun mas la bdd, esto con el objetivo de dejar todo listo para crear los buffers
**********************************************************

cd "$dir_BDD_2011"
cd "$dir_BDD_clean"

use nuevo_MOD_D.dta, clear

merge m:1 orden id_perso using nuevo_MOD_B.dta

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

merge m:1 orden using nuevo_MOD_A.dta

//hay hogares que no estan en el dataset que nos importa, entonces no hay problema, por lo menos en el otro si se asocio todo
keep if _merge==3
drop _merge
   
**************************************************************
*vamos a borrar algunas variables redundantes y otras les cambiaremos el label
**************************************************************

//con esto solo nos quedamos con las razones de viaje de:
//Trabajar (1), Asuntos de trabajo (2), Trámites (11) y Buscar trabajo (13)
//lo otro se dropea

keep if inlist(razon_viaje, 1, 2, 11, 13)

rename orden id_hogar

//variables redundantes
drop zat mun 

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

keep if inlist(ocupacion1, 1, 5, 6, 7, 20) | inlist(ocupacion2, 1, 5, 6, 7, 20)

//dejar las actividades economicas que tinen que ver con mi pregunta de investigacion
// Industrias manufactureras(4), Comercio al por mayor y al por menor de (6), Otras actividades de servicios comunita (15)


/****************************************************************************
	Nota, ya no se si es verdaderamente necesario, porque igual esta bien con todos, no?	
****************************************************************************/


//keep if inlist(actividad_economica1, 4,6,15) & inlist(actividad_economica2, 4,6,15)

label variable id_hogar "ID del hogar"

label variable mujer "mujer=1"

********************************************************************************
*Generar variable multicolineal
********************************************************************************

* Dummy trabajadores formales
gen formal = .
replace formal = 1 if inlist(ocupacion1,1,7) | inlist(ocupacion2,1,7)
replace formal = 0 if inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6)

label variable formal "ocupacion formal"

* Dummy independientes
gen independientes = .
replace independiente = 1 if inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6)
replace independiente = 0 if inlist(ocupacion1,1,7) | inlist(ocupacion2,1,7)

label variable independiente "ocupacion trabajador independiente"

save "merge_2011.dta", replace

***************************************************************
*con esto haremos el collapse segun el ZAT
***************************************************************

//este se guardara en el data de los buffers porque con eso se crea el panel georeferenciado

//en este no vamos a tener en cuenta las siguientes vars  (las otras no las tendremos en cuenta y se desaparecen):
//mean mujer, mean edad, mean educacion, count formal, count informal

//me debe quedar un dato por zat 

preserve

rename estrato estrato_trabajador

* colapsamos al nivel ZAT destino

//falta ingreso

collapse (mean) mujer edad educacion estrato_trabajador limitaciones_fisicas///
         (sum) formal independiente, by(zat_destino)

cd "$dir_BDD_buffers"

save collapsed_2011.dta, replace

restore 

clear

