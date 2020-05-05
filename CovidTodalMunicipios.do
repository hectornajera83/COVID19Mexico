import delimited C:\Users\Hector\Desktop\200429COVID19MEXICO.csv, clear

gen covid=1 if resultado==1

egen contagios=sum(covid), by(entidad_res municipio_res)

egen municipio=tag(entidad_res municipio_res)

keep if municipio==1

drop if contagios==0

keep entidad_res municipio_res contagios

gen ent=entidad_res*1000

gen municipio = ent + municipio_res

keep municipio contagios

