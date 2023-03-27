/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM Portfolio23.dbo.NashvilleHousing

--Change Sale Date

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE

Select SaleDate
FROM NashvilleHousing

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null

--Join table to iself to retrieve Property Address using ParcelID

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM portfolio23.dbo.NashvilleHousing AS a
JOIN portfolio23.dbo.NashvilleHousing AS b
	ON a.parcelid = b.parcelid
	AND a.[uniqueid] <> b.[uniqueid]
WHERE a.PropertyAddress is null

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM portfolio23.dbo.NashvilleHousing AS a
JOIN portfolio23.dbo.NashvilleHousing AS b
	ON a.parcelid = b.parcelid
	AND a.[uniqueid] <> b.[uniqueid]
WHERE a.PropertyAddress is null

SELECT propertyaddress
FROM NashvilleHousing 
WHERE propertyaddress is null

--Separating Address into individual columns (Address, City, State)

SELECT propertyaddress
FROM NashvilleHousing 
--WHERE propertyaddress is null

SELECT
Substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) AS Address,
Substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress)) AS Address
FROM NashvilleHousing 
--WHERE propertyaddress is null

ALTER TABLE portfolio23.dbo.NashvilleHousing 
Add PropertySplitAddress NVARCHAR(255);

Update portfolio23.dbo.NashvilleHousing
SET PropertySplitAddress = Substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)

ALTER TABLE portfolio23.dbo.NashvilleHousing 
Add PropertySplitCity NVARCHAR(255);

UPDATE portfolio23.dbo.NashvilleHousing
SET PropertySplitCity = Substring(propertyaddress, CHARINDEX(',',propertyaddress)+1, LEN(propertyaddress))

SELECT *
FROM Portfolio23.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio23.dbo.NashvilleHousing

ALTER TABLE portfolio23.dbo.NashvilleHousing 
Add OwnerSplitAddress NVARCHAR(255);

Update portfolio23.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE portfolio23.dbo.NashvilleHousing 
Add OwnerSplitCity NVARCHAR(255);

UPDATE portfolio23.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE portfolio23.dbo.NashvilleHousing 
Add OwnerSplitState NVARCHAR(255);

UPDATE portfolio23.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in the 'SoldAsVacant' Column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio23.dbo.NashvilleHousing
GROUP by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Portfolio23.dbo.NashvilleHousing

UPDATE Portfolio23.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio23.dbo.NashvilleHousing
--order by ParcelID
)
SELECT*
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


FROM Portfolio23.dbo.NashvilleHousing

--Delete unused columns

ALTER TABLE portfolio23.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress