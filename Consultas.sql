create schema discorama

create table discorama.actor()
create table discorama.address()
create table discorama.category()
create table discorama.city()
create table discorama.country()
create table discorama.customer()
create table discorama.film()
create table discorama.film_actor()
create table discorama.film_category()
create table discorama.inventory()
create table discorama.payment()
create table discorama.rental()
create table discorama.staff()
create table discorama.store()

select * from discorama.actor
select * from discorama.address
select * from discorama.category
select * from discorama.city
select * from discorama.country
select * from discorama.customer
select * from discorama.film
select * from discorama.film_actor
select * from discorama.film_category
select * from discorama.inventory
select * from discorama.payment
select * from discorama.rental
select * from discorama.staff
select * from discorama.store



-- VERIFICANDO PERÍODO DOS REGISTROS DOS ALUGUÉIS
SELECT
	CONCAT(EXTRACT(DAY FROM min(rental_date)), '/', EXTRACT(MONTH FROM min(rental_date)), '/', EXTRACT(YEAR FROM min(rental_date))) AS data_inicio_registro_alugueis,
	CONCAT(EXTRACT(DAY FROM max(rental_date)), '/', EXTRACT(MONTH FROM max(rental_date)), '/', EXTRACT(YEAR FROM max(rental_date))) AS data_final_registro_alugueis
FROM discorama.rental
-- O primeiro registro de aluguel foi em 24/05/2005 e o último dia foi 14/02/2006



-- ALUGUEIS POR MES E ANO
SELECT 
	EXTRACT(YEAR FROM rental_date) as ano,
	EXTRACT(MONTH FROM rental_date) as mes,	
	TO_CHAR(rental_date,'Month') as nome_mes,
	COUNT(*) as alugueis
FROM discorama.rental
GROUP BY ano, mes, nome_mes
ORDER BY ano, mes
-- Os meses de Julho/2005 e Agosto/2005 
-- foram os de melhor desenpenho dentre os dados disponíveis 



-- INVESTIGANDO AUSÊNCIA DE ALUGUEIS ENTRE 07/2005 E 01/2006
SELECT
	CONCAT(EXTRACT(DAY FROM max(rental_date)), '/', EXTRACT(MONTH FROM max(rental_date)), '/', EXTRACT(YEAR FROM max(rental_date))) AS "dia_final_registro_08/2005"
FROM discorama.rental
WHERE 
	EXTRACT(MONTH FROM rental_date) = 8 AND
	EXTRACT(YEAR FROM rental_date) = 2005
	
SELECT
	CONCAT(EXTRACT(DAY FROM min(rental_date)), '/', EXTRACT(MONTH FROM max(rental_date)), '/', EXTRACT(YEAR FROM max(rental_date))) AS "dia_inicial_registro_02/2006"
FROM discorama.rental
WHERE 
	EXTRACT(MONTH FROM rental_date) = 2 AND
	EXTRACT(YEAR FROM rental_date) = 2006
-- Não houveram registros de alugueis entre 24/08/2005 e 13/02/2006



-- ALUGUEIS POR GENERO DE FILME
SELECT
	cat.name as genero,
	COUNT(*) as alugueis 
FROM discorama.rental as ren
JOIN discorama.inventory as inv
ON ren.inventory_id = inv.inventory_id
JOIN discorama.film_category as fic
ON inv.film_id = fic.film_id
JOIN discorama.category as cat
ON fic.category_id = cat.category_id
GROUP BY cat.name
ORDER BY alugueis DESC
-- Há um equilibrio no numero de alugueis de filmes por genero
-- O top 05 de gêneros mais alugados é: Sports, Animation, Action, Sci-Fi e Family



-- FILMES MAIS ALUGADOS
SELECT
	fil.title as filme,
	fil.film_id as id,
	COUNT(*) as alugueis 
FROM discorama.rental as ren
JOIN discorama.inventory as inv
ON ren.inventory_id = inv.inventory_id
JOIN discorama.film as fil
ON inv.film_id = fil.film_id
GROUP BY filme, id
ORDER BY alugueis DESC



-- ALUGUEIS POR ATOR
SELECT
	CONCAT(act.first_name, ' ', act.last_name) as ator,
	COUNT(*) as alugueis 
FROM discorama.rental as ren
JOIN discorama.inventory as inv
ON ren.inventory_id = inv.inventory_id
JOIN discorama.film as fil
ON inv.film_id = fil.film_id
JOIN discorama.film_actor as fia
ON fil.film_id = fia.film_id
JOIN discorama.actor as act
ON fia.actor_id = act.actor_id
GROUP BY ator
ORDER BY alugueis DESC
-- Os atores que tiveram mais filmes alugados foram:
-- Susan Davis 825
-- Gina Degeneres 753
-- Matthew Carrey 678
-- Mary Keitel 674
-- Angela Witherspoon



-- VENDO EM QUE PRINCIPAIS GENEROS O TOP 03 DOS ATORES MAIS ALUGADOS ATUAM
SELECT
	COUNT(*) as alugueis,
	cat.name as genero,
	CONCAT(act.first_name, ' ', act.last_name) as ator
FROM discorama.rental as ren
JOIN discorama.inventory as inv
ON ren.inventory_id = inv.inventory_id
JOIN discorama.film_category as fic
ON inv.film_id = fic.film_id
JOIN discorama.category as cat
ON fic.category_id = cat.category_id
JOIN discorama.film as fil
ON inv.film_id = fil.film_id
JOIN discorama.film_actor as fia
ON fil.film_id = fia.film_id
JOIN discorama.actor as act
ON fia.actor_id = act.actor_id
WHERE 	act.first_name like 'Susan' or 
		act.first_name like 'Gina' or
		(act.first_name like 'Matthew' and act.last_name like 'Carrey')
GROUP BY genero, ator
ORDER BY ator, alugueis DESC
-- Gina Degeneres: Sci-Fi, Animation, Music, Family e Action
-- Matthew Carrey: Animation, Games, Action, Travel e Family
-- Susan Davis:	   Sci-Fi, Horror, Children, Music, Sports



-- ALUGUEIS POR GENERO EM CADA MES/ANO
SELECT 
	EXTRACT(YEAR FROM rental_date) as ano,
	EXTRACT(MONTH FROM rental_date) as mes,	
	TO_CHAR(rental_date,'Month') as nome_mes,
	cat.name as genero,
	COUNT(*) as alugueis
FROM discorama.rental as ren
JOIN discorama.inventory as inv
ON ren.inventory_id = inv.inventory_id
JOIN discorama.film_category as fic
ON inv.film_id = fic.film_id
JOIN discorama.category as cat
ON fic.category_id = cat.category_id
GROUP BY ano, mes, nome_mes, genero
ORDER BY ano, mes, alugueis
-- 05/2005 > Action, Documentary, Animation, Family, Drama, Sci-Fi, Sports e Animation
-- 06/2005 > Animation, Sci-Fi, Action, Documentary, Sports, Family, Drama
-- 07/2005 > Sports, Animation, Action, Drama, Sci-Fi, Family, Foreign, Documentary
-- 08/2005 > Sports, Animation, Sci-Fi, Action, Family, Foreign, Documentary, Drama
-- 02/2006 > Animation, Action, Sports, Games, Family, New




-- VERIFICANDO PERÍODO DOS REGISTROS DOS PAGAMENTOS
SELECT
	CONCAT(EXTRACT(DAY FROM min(payment_date)), '/', EXTRACT(MONTH FROM min(payment_date)), '/', EXTRACT(YEAR FROM min(payment_date))) AS data_inicio_registro_pagamentos,
	CONCAT(EXTRACT(DAY FROM max(payment_date)), '/', EXTRACT(MONTH FROM max(payment_date)), '/', EXTRACT(YEAR FROM max(payment_date))) AS data_final_registro_pagamentos
FROM discorama.payment
-- O primeiro registro de pagamaneto foi em 14/02/2007 e o último dia foi 14/05/2007



-- NÚMERO DE PAGAMENTOS, VALOR RECEBIDO E TICKET MÉDIO POR MÊS/ANO
WITH tabela AS(
	SELECT 
		EXTRACT(YEAR FROM payment_date) as ano,
		EXTRACT(MONTH FROM payment_date) as mes,	
		TO_CHAR(payment_date,'Month') as nome_mes,
		COUNT(*) as pagamentos,
		SUM(amount) as valor_recebido
		FROM discorama.payment
		GROUP BY ano, mes, nome_mes
		ORDER BY ano, mes
	)
SELECT 
		ano,
		mes,
		nome_mes,
		pagamentos,
		valor_recebido,
		ROUND(valor_recebido/pagamentos,2) as ticket_medio
FROM tabela



-- NÚMERO DE PAGAMENTOS, VALOR RECEBIDO E TICKET MÉDIO GERAL
WITH tabela2 AS(
	SELECT 
		COUNT(*) as pagamentos,
		SUM(amount) as valor_recebido
		FROM discorama.payment
	)
SELECT 
		pagamentos,
		valor_recebido,
		ROUND(valor_recebido/pagamentos,2) as ticket_medio
FROM tabela2
-- 14596 		pagamentos
-- 61312.04		valor_recebido
-- 4.20			ticket_medio



-- NUMERO DE ALUGUEIS E VALOR RECEBIDO POR LOJA
SELECT
	sto.store_id as loja,
	sta.first_name as gerente,	
	COUNT(*) as alugueis,
	SUM(amount) as valor_recebido
FROM discorama.rental as ren
JOIN discorama.inventory as inv
ON ren.inventory_id = inv.inventory_id
JOIN discorama.store as sto
ON inv.store_id = sto.store_id
JOIN discorama.staff as sta
ON sto.staff_id = sta.staff_id
JOIN discorama.payment as pay
ON ren.rental_id = pay.rental_id
GROUP BY loja, gerente
ORDER BY loja
-- As lojas tiverem numero de alugueis e faturamento bem semelhantes



-- TICKET MÉDIO POR CATEGORIA
WITH tabela4 AS(
	SELECT
		cat.name as genero,
		COUNT(*) as pagamentos,
		SUM(amount) as valor_recebido
	FROM discorama.payment as pay
	JOIN discorama.rental as ren
	ON pay.rental_id = ren.rental_id
	JOIN discorama.inventory as inv
	ON ren.inventory_id = inv.inventory_id
	JOIN discorama.film_category as fic
	ON inv.film_id = fic.film_id
	JOIN discorama.category as cat
	ON fic.category_id = cat.category_id
	GROUP BY cat.name
	)
SELECT 
		genero,
		pagamentos,
		valor_recebido,
		ROUND(valor_recebido/pagamentos,2) as ticket_medio
FROM tabela4
ORDER BY ticket_medio DESC


-- TICKET MÉDIO POR CIDADE
WITH tabela5 AS(
	SELECT
		city as cidade,
		country as pais,
		COUNT(*) as pagamentos,
		SUM(amount) as valor_recebido
	FROM discorama.payment as pay
	JOIN discorama.customer as cus
	ON pay.customer_id = cus.customer_id
	JOIN discorama.address as ads
	ON cus.address_id = ads.address_id
	JOIN discorama.city as cit
	ON ads.city_id = cit.city_id
	JOIN discorama.country as cou
	ON cit.country_id = cou.country_id
	GROUP BY city, country
)
SELECT 
		cidade,
		pais,
		pagamentos,
		valor_recebido,
		ROUND(valor_recebido/pagamentos,2) as ticket_medio
FROM tabela5
ORDER BY ticket_medio DESC



-- TICKET MÉDIO POR PÁIS
WITH tabela5 AS(
	SELECT
		country as pais,
		COUNT(*) as pagamentos,
		SUM(amount) as valor_recebido
	FROM discorama.payment as pay
	JOIN discorama.customer as cus
	ON pay.customer_id = cus.customer_id
	JOIN discorama.address as ads
	ON cus.address_id = ads.address_id
	JOIN discorama.city as cit
	ON ads.city_id = cit.city_id
	JOIN discorama.country as cou
	ON cit.country_id = cou.country_id
	GROUP BY country
)
SELECT 
		pais,
		pagamentos,
		valor_recebido,
		ROUND(valor_recebido/pagamentos,2) as ticket_medio
FROM tabela5
ORDER BY ticket_medio DESC



-- NUMERO DE ALUGUEIS POR CLIENTE
SELECT
	CONCAT(cus.first_name,' ', cus.last_name) as cliente,
	country as pais,
	COUNT(*) as alugueis
FROM discorama.rental as ren
JOIN discorama.payment as pay
ON ren.rental_id = pay.rental_id
JOIN discorama.customer as cus
ON pay.customer_id = cus.customer_id
JOIN discorama.address as ads
ON cus.address_id = ads.address_id
JOIN discorama.city as cit
ON ads.city_id = cit.city_id
JOIN discorama.country as cou
ON cit.country_id = cou.country_id
GROUP BY cliente,country
ORDER BY alugueis DESC



-- Data aluguel, devolucao e pagamento
WITH tabela3 AS (
	SELECT 
		ren.rental_id AS id_aluguel,
		TO_CHAR(rental_date, 'DD/MM/YYYY') AS data_aluguel,
		TO_CHAR(return_date, 'DD/MM/YYYY') AS data_devolucao,
		TO_CHAR(payment_date, 'DD/MM/YYYY') AS data_pagamento
	FROM discorama.rental AS ren
	JOIN discorama.payment AS pay ON ren.rental_id = pay.rental_id
)
SELECT 
    id_aluguel,
    data_aluguel,
    data_devolucao,
    data_pagamento,
	TO_DATE(data_devolucao, 'DD/MM/YYYY') - TO_DATE(data_aluguel, 'DD/MM/YYYY') AS dias_de_aluguel,
    TO_DATE(data_pagamento, 'DD/MM/YYYY') - TO_DATE(data_devolucao, 'DD/MM/YYYY') AS dias_entre_devolucao_e_pagamento
FROM tabela3 
ORDER BY dias_entre_devolucao_e_pagamento



-- MÉDIA DE DIAS PARA DEVOLUÇÃO POR PAÍS
WITH tabela6 as(
	SELECT
		ren.rental_id AS id_aluguel,
		country as pais,
		TO_CHAR(rental_date, 'DD/MM/YYYY') AS data_aluguel,
		TO_CHAR(return_date, 'DD/MM/YYYY') AS data_devolucao
	FROM discorama.rental as ren
	JOIN discorama.payment as pay
	ON ren.rental_id = pay.rental_id
	JOIN discorama.customer as cus
	ON pay.customer_id = cus.customer_id
	JOIN discorama.address as ads
	ON cus.address_id = ads.address_id
	JOIN discorama.city as cit
	ON ads.city_id = cit.city_id
	JOIN discorama.country as cou
	ON cit.country_id = cou.country_id
)
SELECT
	pais,
	AVG(TO_DATE(data_devolucao, 'DD/MM/YYYY') - TO_DATE(data_aluguel, 'DD/MM/YYYY')) AS dias_de_aluguel
FROM tabela6
GROUP BY pais
ORDER BY dias_de_aluguel



-- MÉDIA DE DIAS PARA DEVOLUÇÃO POR GENERO
WITH tabela7 AS(
	SELECT
		cat.name as genero,
		TO_CHAR(rental_date, 'DD/MM/YYYY') AS data_aluguel,
		TO_CHAR(return_date, 'DD/MM/YYYY') AS data_devolucao
	FROM discorama.payment as pay
	JOIN discorama.rental as ren
	ON pay.rental_id = ren.rental_id
	JOIN discorama.inventory as inv
	ON ren.inventory_id = inv.inventory_id
	JOIN discorama.film_category as fic
	ON inv.film_id = fic.film_id
	JOIN discorama.category as cat
	ON fic.category_id = cat.category_id
	)
SELECT 
		genero,
		AVG(TO_DATE(data_devolucao, 'DD/MM/YYYY') - TO_DATE(data_aluguel, 'DD/MM/YYYY')) AS dias_de_aluguel
FROM tabela7
GROUP BY genero
ORDER BY dias_de_aluguel