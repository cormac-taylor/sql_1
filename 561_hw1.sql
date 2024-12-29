-- Cormac Taylor | 20014003
-- I pledge my honor that I have abided by the Stevens Honor system.

-- -- query 1:
with agg as
 (select cust, min(quant) as min_q, max(quant) as max_q, round(avg(quant), 0) as avg_q
  from sales
  group by cust)
select cust as customer, min_q, min_prod, min_date, min_st as st, max_q, max_prod, max_date, max_st as st, avg_q
 from (select cust, min_q, prod as min_prod, date as min_date, state as min_st
 		from agg natural join sales
 		where quant = min_q) as min_info
 natural join
	  (select cust, max_q, prod as max_prod, date as max_date, state as max_st, avg_q
 		from agg natural join sales
 		where quant = max_q) as max_info

-- -- query 2:
with raw as 
 (select (((month - 1) / 3) + 1) as qrtr, date, sum(quant) as day_q
   from sales
   group by date, month),
agg as
 (select qrtr, max(day_q) as max_num, min(day_q) as min_num
   from raw 
   group by qrtr)
select *
 from (select qrtr, date as most_profit_day, day_q as most_profit_total_q
 	   from raw natural join agg
 	   where day_q = max_num) as max_info
 natural join
 	 (select qrtr, date as least_profit_day, day_q as least_profit_total_q
   	   from raw natural join agg
        where day_q = min_num) as min_info
		
-- -- query 3:
with raw as 
 (select prod, month, sum(quant) as prod_month_q
   from sales
   group by prod, month),
agg as
 (select prod, min(prod_month_q) as min_prod_month_q, max(prod_month_q) as max_prod_month_q
   from raw
   group by prod)
select *
 from (select prod as product, month as most_fav_mo
	    from raw natural join agg
	    where prod_month_q = max_prod_month_q) as max_info
 natural join
	 (select prod as product, month as least_fav_mo
	   from raw natural join agg
	   where prod_month_q = min_prod_month_q) as min_info

-- -- query 4:
with raw as 
 (select cust, prod, (((month - 1) / 3) + 1) as qrtr, quant
   from sales),
filtered as
 (select cust, prod, qrtr, round(avg(quant), 0) as avg_qrtr
   from raw
   group by cust, prod, qrtr)
select cust as customer, prod as product, q1_avg, q2_avg, q3_avg, q4_avg, average, total, count
 from (select cust, prod, avg_qrtr as q1_avg
  		from filtered
  		where qrtr = 1) as q1_info
 natural join
 	  (select cust, prod, avg_qrtr as q2_avg
  		from filtered
  		where qrtr = 2) as q2_info
 natural join
 	  (select cust, prod, avg_qrtr as q3_avg
  		from filtered
  		where qrtr = 3) as q3_info
 natural join
 	  (select cust, prod, avg_qrtr as q4_avg
  		from filtered
  		where qrtr = 4) as q4_info
 natural join
 	  (select cust, prod, round(avg(quant), 0) as average, sum(quant) as total, count(quant) as count
   		from raw
   		group by cust, prod) as agg_info

-- -- query 5:
with raw as 
 (select cust, prod, state, quant, date
   from sales),
agg as
 (select cust, prod, state, max(quant) as max_q
   from raw
   group by cust, prod, state)
select cust as customer, prod as product, nj_max, nj_date as date, ny_max, ny_date as date, ct_max, ct_date as date
 from (select cust, prod, max_q as nj_max, date as nj_date
	  	from raw natural join agg
	  	where state = 'NJ' and quant = max_q) as nj_info
 natural join
 	  (select cust, prod, max_q as ny_max, date as ny_date
	  	from raw natural join agg
	  	where state = 'NY' and quant = max_q) as ny_info
 natural join
 	  (select cust, prod, max_q as ct_max, date as ct_date
	  	from raw natural join agg
	  	where state = 'CT' and quant = max_q) as ct_info
 where ny_max > nj_max or ny_max > ct_max
