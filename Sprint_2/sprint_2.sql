use transactions;
# NIVEL 1

#2.1 Lista los paises que estan generando ventas
select distinct(c.country) 
from company c #left join transaction t
#on c.id = t.company_id
;

#2.2 Desde cuántos paisos se generan las ventas
select count(distinct(c.country))
from company c left join transaction t
on c.id = t.company_id
;

#2.3 Identifica la compañia con la mediana mas grande de ventas 
select c.company_name, avg(t.amount) as mediana_ventas
from company c left join transaction t 
on c.id = t.company_id
group by c.company_name
#having avg(t.amount);
order by mediana_ventas desc
limit 1;

#Ejercicio 3 

#Utiliza solo subconsultas(sin utilizar join) 
#3.1- Muestra todas las transacciones realizadas por empresas de Alemania                
select * 
from transaction t
where t.company_id in (select c.id from company c where c.id = t.company_id and c.country like "Germany"); 

#3.2 Lista las empresas que han realizar transacciones por una cantidad superior a la mediana de todas las transacciones 
select *
from company c
where t.company_id > (select t.company_id 
					  from transaction t 
                      where c.id = t.company_id 
                      group by t.amount 
                      having Avg(t.amount))
#group by t.amount 
order by t.amount desc 
;

#3.3 Eliminaran del sistema las empresas que no tienen transacciones registradas, entrega el listado de aquellas empresas
select t.declined
from transaction t 
where not exists (select c.id from company c where c.id = t.company_id)
and t.declined = "0"
;


#NIVEL 2
#EJERCICIO 1
#Identifica los cincos dias que se va a generar la cantidad mas grande de ingresos 
#a la empresa por ventas.
#Muestra los datos de cada transaccion juntamente con el total de las ventas. 
select date(t.timestamp) as fecha, sum(t.amount) as total_ingresos
from transaction t
#on c.id = t.company_id
group by fecha
order by total_ingresos Desc
limit 5
;

#Ejercicio 2
#Cual es la mediana de ventas por pais? Presenta los resultados ordenados de mayor a menor media.
select avg(t.amount) as ventas, c.country
from company c left join transaction t
on c.id = t.company_id 
group by c.country
order by ventas desc
;

#EJERCICIO 3 

/*
En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas 
publicitarias para hacer competencia a la compañía "Non Institute". 
Para lo cual, te piden la lista de todas las transacciones realizadas 
por empresas que están situadas en el mismo país que esta compañía.

Muestra el listado aplicando JOIN y subconsultes.
Muestra el listado aplicando solo subconsultes.
*/

select *
from company c Left Join transaction t 
On c.id = t.company_id
where c.country In (select c.country 
from company c
where c.company_name like "Non Institute" 
#and c.country like "United Kingdom"
)
;

#Muestra el listado aplicando solo subconsultes.
select *
from transaction t
where t.company_id IN (select c.id 
						from company c
                        where c.id = t.company_id
						#and c.company_name like "Non Institute" 
                        and c.country = (select c.country 
										from company c 
                                        where c.company_name like "Non Institute"))
;

#NIVEL 3
/*
Ejercicio 1
Presenta el nombre, teléfono, país, fecha y amount, de aquellas 
empresas que realizaron transacciones con un valor comprendido 
entre 350 y 400 euros y en alguna de estas fechas:
29 de abril del 2015, 20 de julio del 2018 y 13 de marzo del 2024.
Ordena los resultados de mayor a menor cantidad.
*/
select c.company_name, c.phone, c.country, date(t.timestamp), t.amount
from company c left join transaction t 
on c.id = t.company_id
where t.amount between 350.28 and 401
and date(t.timestamp) In ('2015-04-29','2018-07-20', '2024-03-13')
order by t.amount Desc
;

/*
Ejercicio 2
Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad
operativa que se requiera, por lo cual te piden la información sobre la 
cantidad de transacciones que realicen las empresas, pero el departamento 
de recursos humanos es exigente y quiere un listado de las empresas donde 
especifiques si tienen más de 400 transacciones o menos.
*/
select c.company_name, If(count(t.amount)>= 400, "SI", "NO")  as listado
from company c left join transaction t 
on c.id = t.company_id
#where t.amount >= 400
group by c.company_name
order by c.company_name;

