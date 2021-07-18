-- Deleting markets outside India

select * 
from sales.markets
where markets_code in ('Mark097', 'Mark999')

delete from sales.markets
where markets_code in ('Mark097', 'Mark999') 

select *
from sales.markets

-- Removing 0 and -1 from sales_amount

select *
from sales.transactions
where sales_amount not in (0, -1)

delete from sales.transactions
where sales_amount in (0, -1)

select *
from sales.transactions

-- convert usd to inr

select *,
case when currency = 'USD' then sales_amount * 74.61 
else sales_amount
end,
case when currency = 'USD' then 'INR' 
else currency
end
from sales.transactions

update sales.transactions
set sales_amount = case when currency = 'USD' then sales_amount * 74.61 
else sales_amount 
end,
currency = case when currency = 'USD' then 'INR' 
else currency 
end

select *
from sales.transactions