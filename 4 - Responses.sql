
--QUESTION:  What are the top 5 brands by receipts scanned for most recent month?
select rri.brandcode, count(distinct receipts.id) receipts_scanned 
from receipts 
join rewardsReceiptItem rri on receipts.id = rri.receiptID
where EXTRACT(MONTH FROM DATESCANNED) = 2 and EXTRACT(YEAR FROM DATESCANNED) = 2021
group by rri.brandcode
order by 2 desc
limit 6

--RESPONSE:  Using brand codes, there were only three brands scanned in the receipt data for February 2021 on six receipts, which is the 
--most recent complete month of receipt data available.  Brand, Mission, and Viva were the only brands with receipt scans.


--QUESTION:  How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
select rri.brandcode, count(distinct receipts.id) receipts_scanned 
from receipts 
join rewardsReceiptItem rri on receipts.id = rri.receiptID
where EXTRACT(MONTH FROM DATESCANNED) = 1 and EXTRACT(YEAR FROM DATESCANNED) = 2021
group by rri.brandcode
order by 2 desc
limit 6

--RESPONSE:  January 2021 shows more brands with receipt scans as well as a much larger number of scans.  Ben and Jerry's,
--Folgers, Pepsi, Kellogg's, and Kraft were the brands most often on scanned receipts.


--QUESTION:  When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT *
FROM (select round(avg(totalspent)::numeric,2) accepted_total
	  from receipts
	  where LOWER(rewardsReceiptStatus) = 'finished'
	 ) accepted
CROSS JOIN (
	select round(avg(totalspent)::numeric,2) rejected_total
	  from receipts
	  where LOWER(rewardsReceiptStatus) = 'rejected'
) rejected

--RESPONSE:  The average spend for receipts with a status of finished (80.85) is greater than the average of rejected
--receipts (23.33).


--QUESTION:  When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT *
FROM (select sum(purchasedItemCount) accepted_total
	  from receipts
	  where LOWER(rewardsReceiptStatus) = 'finished'
	 ) accepted
CROSS JOIN (
	select sum(purchasedItemCount) rejected_total
	  from receipts
	  where LOWER(rewardsReceiptStatus) = 'rejected'
) rejected''

--RESPONSE:  The total number of purchased items on receipts with a status of finished (8,184) is greater than the number of items on rejected
--receipts (173).


--QUESTION:  Which brand has the most spend among users who were created within the past 6 months?

select rri.brandcode, sum(rri.finalprice) 
from receipts 
join rewardsReceiptItem rri on receipts.id = rri.receiptID
where receipts.userId in
(
	select id from users 
	where active = True and createddate > ((select max(createddate) from users) - interval ' 6 months')
	order by createddate desc
)
and brandcode is not null
group by rri.brandcode
order by 2 desc
limit 1

--RESPONSE:  Using the finalprice field to calculate spend per item sold, Ben and Jerry's has the most spend
--among users created within six months of the most recently created user.


--QUESTION:  Which brand has the most transactions among users who were created within the past 6 months?
select rri.brandcode, sum(rri.id) 
from receipts 
join rewardsReceiptItem rri on receipts.id = rri.receiptID
where receipts.userId in
(
	select id from users 
	where active = True and createddate > ((select max(createddate) from users) - interval ' 6 months')
	order by createddate desc
)
and brandcode is not null
group by rri.brandcode
order by 2 desc
limit 1

--RESPONSE:  HY-VEE has the most transactions among users created within six months of the most recently created user.
