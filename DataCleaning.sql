--Standardize date format
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;
Update NashvilleHousing
SET SaleDate2 = CONVERT(Date,SaleDate)
--Populate Property Address data
SELECT a.[UniqueID ], b.[UniqueID ], a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
--Breaking Address into Address, city
ALTER TABLE NashvilleHousing
Add PropertyAddressSplited nvarchar(255);
UPDATE NashvilleHousing
SET PropertyAddressSplited = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertyCitySplited nvarchar(255);
UPDATE NashvilleHousing
SET PropertyCitySplited = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
--Breaking OwnerAddress into Address, City, State
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerAddressSplited nvarchar(255);
UPDATE NashvilleHousing
SET OwnerAddressSplited = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerCitySplited nvarchar(255);
UPDATE NashvilleHousing
SET OwnerCitySplited = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerStateSplited nvarchar(255);
UPDATE NashvilleHousing
SET OwnerStateSplited = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--Standardize SoldAsVacant 
SELECT SoldAsVacant
FROM PortfolioProject..NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS C
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY C


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END 
--Remove Duplicates
WITH CTE AS (
SELECT *, 
 ROW_NUMBER() OVER(
              PARTITION BY ParcelID,
			               SalePrice,
						   SaleDate,
						   PropertyAddress,
						   LegalReference
						   ORDER BY UniqueID ) row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM CTE
WHERE row_num >1

SELECT *
FROM PortfolioProject..NashvilleHousing
--Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict, PropertyAddress, SaleDate, OwnerAddress
