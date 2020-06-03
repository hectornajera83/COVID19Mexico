
import delimited "C:\OneDrive\Proyectos Investigacion\COVID19\COVID19Mexico\200531COVID19MEXICO", clear

*
gen edad2 = edad^2

*Sintomas
split fecha_sintomas, parse("-") gen(d_) destring
gen f_sintomas = mdy(d_2, d_3, d_1) 
*gen f_sintomas = date(fecha_sintomas,"DMY")

drop d_1 d_2 d_3

*Ingreso
*gen f_ingreso = date(fecha_ingreso,"DMY")
split fecha_ingreso, parse("-") gen(d_) destring
gen f_ingreso = mdy(d_2, d_3, d_1) 

drop d_1 d_2 d_3

* Muerte

*gen f_def = date(fecha_def,"DMY")
split fecha_def, parse("-") gen(d_) destring
gen f_def = mdy(d_2, d_3, d_1) 

drop d_1 d_2 d_3

*Date format

format f_sintomas %td
format f_ingreso %td
format f_def %td

*Create today

gen tod = "$S_DATE"
split tod, parse(" ") gen(d_) destring
egen today = concat(d_1 d_2 d_3)
gen today2 = date(today, "DMY")
format today2 %td

* Gap sintomas ingreso

gen f_gap =  f_ingreso - f_sintomas
gen f_gap2 = f_gap^2

* Last two weeks

gen todaygap = today2-f_ingreso

gen lastWeek = 1 if todaygap<=8
replace lastWeek = 2 if (todaygap>8 & todaygap<=15)
replace lastWeek = 3 if (todaygap>15 & todaygap<=21)
replace lastWeek = 4 if (todaygap>21 & todaygap<=29)
recode lastWeek (.=0)

* Muerte

gen death=1 if f_def!=.
recode death (.=0)

recode embarazo (2/98=2) (1=1)

drop if cardiovascular==98 | tabaquismo==98 | hipertension==98 | renal_cronica==98 | obesidad==98 | diabetes==98 | inmusupr==98

save "C:\OneDrive\Proyectos Investigacion\COVID19\COVID19Mexico\COVID19.dta", replace 

* Modelo: (con o sin entidad)

use "C:\OneDrive\Proyectos Investigacion\COVID19\COVID19Mexico\COVID19.dta", clear

tab sector, gen(sector)
tab habla_lengua_indig, gen(indigena)

logit death f_gap f_gap2 sector3 sector4 sector6 sector8 sector9 sector11 sector12 edad edad2 indigena2 ///
 i.obesidad i.cardiovascular i.renal_cronica i.tabaquismo i.hipertension i.inmusupr ///
 asma i.diabetes i.embarazo i.sexo i.lastWeek i.tabaquismo  if resultado==1, or
 
 melogit death f_gap f_gap2 sector3 sector4 sector6 sector8 sector9 sector11 sector12 edad edad2 indigena2 ///
 i.obesidad cardiovascular renal_cronica tabaquismo hipertension inmusupr ///
 asma i.diabetes embarazo i.sexo i.lastWeek  if resultado==1 || entidad_res: , or
  
 margins , at(f_gap=(0(1)7))
 marginsplot
 margins obesidad, at(f_gap=(0(1)7))
 marginsplot
 
 margins , at(sector=(3 4 6 8 9 11 12 13))
 margins obesidad
 marginsplot
 margins obesidad,  at(edad= (0(10)90))
 marginsplot
 margins obesidad, at(edad= (0(10)90) diabetes=(1 2))
 marginsplot, recast(line) recastci(rarea)
 
* Modelo Gap

nbreg f_gap intubado i.sector  tipo_paciente edad edad2 habla_lengua_indig ///
 i.obesidad cardiovascular renal_cronica tabaquismo hipertension inmusupr ///
 asma i.diabetes embarazo sexo i.entidad_um i.lastWeek if resultado==1, ir
 
  margins , at(sector=(3 4 6 8 9 11 12 13))

 