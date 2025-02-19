SET timezone = 'America/New_York';

-- Step 1:  Load Users JSON data into temp table.
CREATE TEMP TABLE temp_users (
    id SERIAL PRIMARY KEY,
    data JSONB -- Or JSON if you prefer
);

COPY temp_users(data)
FROM '/Path/to/users.json'
WITH (FORMAT text);



-- Step 2: Load top level Receipts JSON data into a temp table.
CREATE TEMP TABLE temp_receipts (
    id SERIAL PRIMARY KEY,
    data JSONB
);

copy temp_receipts(data)
from '/Path/to/receipts.json'
csv quote e'\x01' delimiter e'\x02'; --Hack to properly import special characters in a JSON string.



-- Step 2b: Load data from rewardsReceiptItemList field into a temp table.
CREATE TEMP TABLE temp_rewardsReceiptItemList (
	id SERIAL PRIMARY KEY,
	receiptID TEXT,
    data JSONB	
);

INSERT INTO temp_rewardsReceiptItemList (receiptID, data)
select data->'_id'->>'$oid'
, data->'rewardsReceiptItemList'
from temp_receipts
where data->'rewardsReceiptItemList' IS not NULL;


--Step 3:  Load top level Brands JSON data into a temp table.
CREATE TEMP TABLE temp_brands (
    id SERIAL PRIMARY KEY,
    data JSONB
);

copy temp_brands(data)
from '/Path/to/brands.json'
csv quote e'\x01' delimiter e'\x02'; --Hack to properly import special characters in a string.



--Step 3b:  Load JSON data from the cpg field in Brands into a temp table. 
CREATE TEMP TABLE temp_cpg (
    id SERIAL PRIMARY KEY,
    data JSONB
);

INSERT INTO temp_cpg (data)
select data->'cpg'
from temp_brands
where data->'cpg' IS not NULL;

--Note: Due to foreign key relationships temp table data has to be loaded into the 
--permanent tables in a certain order.


--Step 4:  Load temp Users data into permanent table.
INSERT INTO users (id, active, createdDate, lastLogin, role, signUpSource, state)
select data->'_id'->>'$oid'
, (data->>'active')::boolean
, TO_TIMESTAMP((data->'createdDate'->>'$date')::bigint/1000) --Convert Unix timestamp to SQL timestamp
, TO_TIMESTAMP((data->'createdDate'->>'$date')::bigint/1000)
, data->>'role'
, data->>'signUpSource'
, data->>'state'
from temp_users;

--Step 5:  Load temp Receipts data (without rewardsReceiptItemList field) into permanent table.
INSERT INTO receipts (id, bonusPointsEarned, bonusPointsEarnedReason, createDate, dateScanned
					 , finishedDate, modifyDate, pointsAwardedDate, pointsEarned, purchaseDate
					 , purchasedItemCount, rewardsReceiptStatus, totalSpent, userID)
select data->'_id'->>'$oid'
, (data->>'bonusPointsEarned')::int
, data->>'bonusPointsEarnedReason'
, TO_TIMESTAMP((data->'createDate'->>'$date')::bigint/1000)
, TO_TIMESTAMP((data->'dateScanned'->>'$date')::bigint/1000)
, TO_TIMESTAMP((data->'finishedDate'->>'$date')::bigint/1000)
, TO_TIMESTAMP((data->'modifyDate'->>'$date')::bigint/1000)
, TO_TIMESTAMP((data->'pointsAwardedDate'->>'$date')::bigint/1000)
, (data->>'pointsEarned')::decimal
, TO_TIMESTAMP((data->'purchaseDate'->>'$date')::bigint/1000)
, (data->>'purchasedItemCount')::int
, data->>'rewardsReceiptStatus'
, (data->>'totalSpent')::decimal
, data->>'userId'
from temp_receipts;

--Step 6:  Load temp CPG data into permanent table.
INSERT INTO cpg (id, ref)

select data->'$id'->>'$oid'
, data->>'$ref'
from temp_cpg


--Step 7:  Load temp Brands data into permanent table.
INSERT INTO brands (id, cpgID, category, categoryCode, barcode, brandCode, topBrand, name)

select data->'_id'->>'$oid'
, data->'cpg'->>'$id'
, data->>'category'
, data->>'categoryCode'
, data->>'barcode'
, data->>'brandCode'
, (data->>'topBrand')::boolean
, data->>'name'
from temp_brands;



--Step 8:  Load temp rewardsReceiptItemList data into permanent table and link to 
--receipt using the receipt
INSERT INTO rewardsReceiptItem (receiptID, barcode, brandCode, description, discountedItemPrice
								, finalPrice, itemPrice, partnerItemId, pointsEarned, pointsPayerId
								, quantityPurchased, rewardsGroup, rewardsProductPartnerId
								, originalReceiptItemText, targetPrice)
select receiptID
, data->>'barcode'
, data->>'brandCode'
, data->>'description'
, (data->>'discountedItemPrice')::decimal
, (data->>'finalPrice')::decimal
, (data->>'itemPrice')::decimal
, (data->>'partnerItemId')::int
, (data->>'pointsEarned')::decimal
, data->>'pointsPayerId'
, (data->>'quantityPurchased')::int
, data->>'rewardsGroup'
, data->>'rewardsProductPartnerId'
, data->>'originalReceiptItemText'
, (data->>'targetPrice')::decimal
from (select receiptID, jsonb_array_elements(data) data from temp_rewardsReceiptItemList) exploded;


