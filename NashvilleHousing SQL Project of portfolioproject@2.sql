/*

Cleaning Data in SQL Queries

*/
USE portfolioproject;
SELECT *
From portfolioproject.dbo.NashvilleHousing

-------------------------------------------------------------------------

-- Standardize Date Format
--SELECT SaleDate, CONVERT(DATE,SaleDate)
--From portfolioproject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

SELECT SalesDateConverted, CONVERT(DATE,SaleDate)
From portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SalesDateConverted DATE 

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(DATE,SaleDate)

-----------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM portfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM portfolioproject.dbo.NashvilleHousing a
JOIN portfolioproject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------------------------------------------------------------
--Breaking Out Address Into Individual Columns(Address,City,State)

SELECT PropertyAddress
FROM portfolioproject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity NVARCHAR (255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 

SELECT PropertyAddress, PropertySplitAddress,PropertySplitCity
FROM NashvilleHousing


SELECT OwnerAddress
FROM portfolioproject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,2)
, PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
FROM portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM portfolioproject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------
-- Change Y AND N to Yes and No in "Sold as vacant" field

SELECT SoldAsVacant
FROM portfolioproject.dbo.NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioproject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2,1

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM portfolioproject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



----------------------------------------------------------------------------------------------------
-- Remove Duplicates 

WITH ROWNUMCTE AS (
SELECT *,
     ROW_NUMBER() OVER(
     PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
				     UniqueID
					 ) row_num

FROM portfolioproject.dbo.NashvilleHousing
-- ORDER BY ParcelID
)

--DELETE 
--FROM ROWNUMCTE
--WHERE row_num > 1

SELECT * 
FROM ROWNUMCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-------------------------------------------------------------------------
--Delete Unused Column

SELECT *
FROM portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate











