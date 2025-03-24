Select * From PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format (Remove '00:00:00:0000')

Select SaleDate, Convert(Date, SaleDate)
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)

----------------------------------------------------------------------------------------------------------------------------

-- Populate empty Property Address data, based on equal ParcelID

select * from PortfolioProject..NashvilleHousing 
where PropertyAddress is null    --  After updating nothing will show


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a JOIN PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


update a SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a JOIN PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------

-- Adding columns and breaking out PropertyAddress into individual columns (Address, City, State) using Substring

select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing 


ALTER TABLE PortfolioProject..NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE PortfolioProject..NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

----------------------------------------------------------------------------------------------------------------------------

-- Breaking out OwnerAddress into individual columns (Address, City, State) using Parsename

Select OwnerAddress From PortfolioProject..NashvilleHousing
-- Parsename seperates each '.'
-- Replacing ',' with dots:
select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject..NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE PortfolioProject..NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

----------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to "Yes" and "No" in SoldAsVacant field 

Update PortfolioProject..NashvilleHousing 
Set SoldAsVacant =
	CASE When CAST(SoldAsVacant as VARCHAR(MAX)) = 'Y' THEN 'Yes'
		 When CAST(SoldAsVacant as VARCHAR(MAX)) = 'N' THEN 'No'
		 ELSE CAST(SoldAsVacant as VARCHAR(MAX))
		 End
-- Check:
SELECT DISTINCT CAST(SoldAsVacant AS VARCHAR(MAX)), count(CAST(SoldAsVacant AS VARCHAR(MAX)))
FROM PortfolioProject..NashvilleHousing
Group by CAST(SoldAsVacant AS VARCHAR(MAX))

----------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM PortfolioProject..NashvilleHousing
)
Delete FROM RowNumCTE
where row_num > 1

----------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns
Select * From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress
Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate