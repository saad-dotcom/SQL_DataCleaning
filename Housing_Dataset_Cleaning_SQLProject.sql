USE SQLProject_2;

-- Cleaning Data

Select *
from Housing


--1) Remove time from SaleDate


Alter table Housing
Add SaleDateConverted Date;

Update Housing
set SaleDateConverted=cast(SaleDate as date)

Alter table Housing
drop column SaleDate;


--2) Deal with missing property address

Select *
from Housing
where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress
from Housing a
join Housing b
on a.ParcelID=b.ParcelID
and a.UniqueID!=b.UniqueID
where a.PropertyAddress is null

Update a
Set a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Housing a
join Housing b
on a.ParcelID=b.ParcelID
and a.UniqueID!=b.UniqueID
where a.PropertyAddress is null

Select *
from Housing
where PropertyAddress is null
--There is no null value in Property Address left!


-- Lets split the property address into Address and City
 Select PropertyAddress,Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1),
 Substring(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+1,len(PropertyAddress))
 from Housing

 Alter table Housing
 add Street_Address varchar(50), City varchar(25);

 Update Housing
 Set Street_Address=Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1)

 Update Housing
 Set City=Substring(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+1,len(PropertyAddress))

 Alter table Housing
 drop column PropertyAddress

 -- Lets split the owner address into Street_Address, City and State

 Select OwnerAddress,
 PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 from Housing


 Alter table Housing
 add Owner_Street_Address varchar(50), Owner_City varchar(25), Owner_State varchar(10);

 Update Housing
 Set Owner_Street_Address=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

 Update Housing
 Set Owner_City=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

 Update Housing
 Set Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


 Alter table Housing
 drop column OwnerAddress

-- Change Y and N to Yes and No for SoldasVacant!

Select SoldAsVacant, count(SoldAsVacant)
from Housing
group by SoldAsVacant
order by 2


Update Housing
set SoldAsVacant='Yes'
from Housing
where SoldAsVacant='Y'

Update Housing
set SoldAsVacant='No'
from Housing
where SoldAsVacant='N'

Select SoldAsVacant, count(SoldAsVacant)
from Housing
group by SoldAsVacant
order by 2


-- Removing Duplicates!
With RowNumCTE AS(
Select *,
ROW_NUMBER() over(Partition by ParcelID, SalePrice,LegalReference, SaleDateConverted order by UniqueID) row_num
from Housing)
Select *          --Instead of Select here we can use delete to delete teh duplicates(keeping this in CTE to show how to delete duplicates)
from RowNumCTE
where row_num>1


--- Delete Irrelevant Columns!

-- I have already got rid of SaleDate, PropertyAddress and OwnerAddress!

Alter table Housing
drop column TaxDistrict;
