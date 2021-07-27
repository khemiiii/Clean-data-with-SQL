select *
from NashvilleHousing


--Standardizing Date Format
select SaleDate
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateConverted
from NashvilleHousing


--Populating the property address data, NOTE: for this data, parcel ID's with the same number had the same property address, thus the data could be populated.
select PropertyAddress
from NashvilleHousing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject1.dbo.NashvilleHousing a
join PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject1.dbo.NashvilleHousing a
join PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--Splitting the property address column into address and city
select PropertyAddress
from NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from NashvilleHousing


--Splitting the owner address column into address, city and state
select OwnerAddress
from NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(replace(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(replace(OwnerAddress, ',', '.'), 1) as State
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


--Updating the soldasvacant field by changing the y's and n's to yes and no so the field would be proper
select distinct SoldAsVacant, COUNT(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	else SoldAsVacant
	end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	else SoldAsVacant
	end

--Removing Duplicates
with RowNumCte as (
select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
) row_num
from NashvilleHousing
--order by ParcelID
)
delete
FROM RowNumCte
where row_num > 1

--Deleting Unused Columns
alter table NashvilleHousing
drop column saledate, owneraddress, taxdistrict, propertyaddress

select *
from NashvilleHousing