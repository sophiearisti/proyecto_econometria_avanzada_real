******************************************************************
/*
version 4:
Here we run all the other dofiles
this, with the objective of modularizing responsabilities
*/
*****************************************************************

*--------------Directories --------------------------------------------*

******************************************************************
* Change this with the  proyect's main folder location (proyecto_econometria_avanzada)
******************************************************************

global global_dir "/Users/sophiaaristizabal/Desktop/1 economia/7/econometría avanzada/proyecto_econometria_avanzada"

global dir_data "$global_dir/data/EODH" // this is where all the EODH is located

global dir_dofile "$global_dir/code" //this is where all codes are located

global dir_dofile_EODH "$dir_dofile/cleaning_EODH" //this is where all dofiles are located

global dir_BDD_2011 "$dir_data/sample 2011"
global dir_BDD_2015 "$dir_data/sample 2015"
global dir_BDD_2019 "$dir_data/sample 2019"
global dir_BDD_2023 "$dir_data/sample 2023"

global dir_BDD_clean "dta_limpios" 

global dir_BDD_buffers "$global_dir/data/panel" 

global dir_BDD_collapsed "$dir_BDD_buffers/collapsed_years" 

global dir_reg_dif_med_results "$global_dir/data/reg_dif_med_results"

*----------------------------------------------------------------------*

clear all

/*
This function receives a list of categorical variables and converts each in a dummy
*/


capture program drop makedummies
program define makedummies
    syntax varlist
    foreach v of varlist `varlist' {
        quietly levelsof `v', local(cats)
        foreach c of local cats {
            gen byte `v'_d`c' = (`v' == `c')
        }
    }
end


/*
This function receives a list of categorical variables that represent the same concept (meaning that a person can belong to multiple categories). It converts each category into a dummy variable and sets it to 1 if the person has that category in any of the variables (i.e., it applies a logical OR).
*/
capture program drop makemultidummies
program define makemultidummies
    syntax varlist, genprefix(string)

    * we take just the first variable in order to extractthe category
    local first : word 1 of `varlist'
    quietly levelsof `first', local(cats)

    * we create dummies for each category
    foreach c of local cats {
        gen `genprefix'_d`c' = 0
        foreach v of varlist `varlist' {
            replace `genprefix'_d`c' = 1 if `v' == `c'
        }
    }
end

/*

All "limpieza" dofiles are intended for making all surveys as similar as possible.

Some questions and categories tend to change in each version, this is a barrier to guarantee comparability between cross-sectional data. Itry my best to correct this issue. 

All merge dofiles have the purpose of merging (for each year) all @data modules@ into a single dta
*/

* 2011
do "$dir_dofile_EODH/limpieza_2011.do"

do "$dir_dofile_EODH/merge_2011.do"

* 2015
do "$dir_dofile_EODH/limpieza_2015.do"

do "$dir_dofile_EODH/merge_2015.do"

* 2019
do "$dir_dofile_EODH/limpieza_2019.do"

do "$dir_dofile_EODH/merge_2019.do"

* 2023
do "$dir_dofile_EODH/limpieza_2023.do"

do "$dir_dofile_EODH/merge_2023.do"


* Mean differences between cohorts to assess homogeneity across cross-sectional data
* Initial panel data is also created here
do "$dir_dofile_EODH/dif_medias_entre_anos.do"
