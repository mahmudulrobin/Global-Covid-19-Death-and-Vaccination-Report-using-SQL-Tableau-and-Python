-- exploring the whole dataset

SELECT * FROM imrul_laptop.dbo.Sheet1$;

-- standardize date format

SELECT SaleDate, CONVERT(date, SaleDate) as Converted_SaleDate FROM imrul_laptop.dbo.Sheet1$;

UPDATE imrul_laptop.dbo.Sheet1$
SET SaleDate = CONVERT(date, SaleDate);

ALTER TABLE imrul_laptop.dbo.Sheet1$ ADD Converted_SaleDate date;

UPDATE imrul_laptop.dbo.Sheet1$
SET Converted_SaleDate = CONVERT(date, SaleDate);


-- populate property address

SELECT PropertyAddress from imrul_laptop.dbo.Sheet1$
WHERE PropertyAddress is NULL;

SELECT * from imrul_laptop.dbo.Sheet1$
order by ParcelID;

-- find null PropertyAddress value
-- same ParcelID have same address
-- using self join replace null values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) from imrul_laptop.dbo.Sheet1$ a
join imrul_laptop.dbo.Sheet1$ b
on b.ParcelID = a.ParcelID and b.UniqueID <> a.UniqueID
WHERE a.PropertyAddress is NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) from imrul_laptop.dbo.Sheet1$ a
join imrul_laptop.dbo.Sheet1$ b
on b.ParcelID = a.ParcelID and b.UniqueID <> a.UniqueID
WHERE a.PropertyAddress is NULL;


-- breaking the address to street address, city

SELECT PropertyAddress from imrul_laptop.dbo.Sheet1$;

SELECT 

SUBSTRING(
    PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1
) as Address, 
SUBSTRING(
    PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)
) as City

FROM imrul_laptop.dbo.Sheet1$;


ALTER TABLE imrul_laptop.dbo.Sheet1$ 
ADD Property_Address NVARCHAR(255);

UPDATE imrul_laptop.dbo.Sheet1$
SET Property_Address = 

SUBSTRING(
    PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1
)

ALTER TABLE imrul_laptop.dbo.Sheet1$ 
ADD Property_City NVARCHAR(255);

UPDATE imrul_laptop.dbo.Sheet1$
SET Property_City = 

SUBSTRING(
    PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)
) 


-- owner address split to address, city, state

SELECT OwnerAddress FROM imrul_laptop.dbo.Sheet1$;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from imrul_laptop.dbo.Sheet1$;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
from imrul_laptop.dbo.Sheet1$;

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
from imrul_laptop.dbo.Sheet1$;

ALTER TABLE imrul_laptop.dbo.Sheet1$ ADD Owner_address NVARCHAR(255);
ALTER TABLE imrul_laptop.dbo.Sheet1$ ADD Owner_city NVARCHAR(255);
ALTER TABLE imrul_laptop.dbo.Sheet1$ ADD Owner_state NVARCHAR(255);

UPDATE imrul_laptop.dbo.Sheet1$ SET 
Owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
Owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
Owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



-- change Y to YES and N to No on SoldAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM imrul_laptop.dbo.Sheet1$
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);

UPDATE imrul_laptop.dbo.Sheet1$
SET SoldAsVacant = 
CASE
    WHEN SoldAsVacant = 'N' THEN 'No' 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    ELSE SoldAsVacant END;
     


-- remove dublicate

WITH CTE AS(
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference
        ORDER BY UniqueID 
) as row_id

FROM imrul_laptop.dbo.Sheet1$
)

delete FROM CTE
WHERE row_id > 1;
-- select * FROM CTE
-- WHERE row_id > 1;



-- delete unused columns

ALTER TABLE imrul_laptop.dbo.Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;