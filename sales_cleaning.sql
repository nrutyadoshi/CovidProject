SELECT * FROM sales.markets;

-- Deleting markets outside India

select * 
from sales.markets
where markets_code in ('Mark097', 'Mark999')

delete from sales.markets
where markets_code in ('Mark097', 'Mark999') 

select * 
from sales.markets