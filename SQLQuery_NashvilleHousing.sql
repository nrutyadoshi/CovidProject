-- Displaying the data

select * 
from CovidProject..NashvilleHousing

-- Standardize date format

select saledate, convert(date, saledate)
from CovidProject..NashvilleHousing

update CovidProject..NashvilleHousing
set saledate = convert(date, saledate)

alter table CovidProject..NashvilleHousing
add saledateconverted date

update CovidProject..NashvilleHousing
set saledateconverted = convert(date, saledate)

select saledateconverted
from CovidProject..NashvilleHousing

-- Populate property address data

select *
from CovidProject..NashvilleHousing
where propertyaddress is null

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from CovidProject..NashvilleHousing a
join CovidProject..NashvilleHousing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from CovidProject..NashvilleHousing a
join CovidProject..NashvilleHousing b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

-- Breaking out address into individual columns (address, city, state)

select propertyaddress
from CovidProject..NashvilleHousing

select propertyaddress,
substring(propertyaddress, 1, charindex(',', propertyaddress) - 1),
substring(propertyaddress, charindex(',', propertyaddress) + 1, len(propertyaddress))
from CovidProject..NashvilleHousing

alter table CovidProject..NashvilleHousing
add propertystreet nvarchar(255), 
propertycity nvarchar(255)

update CovidProject..NashvilleHousing
set propertystreet = substring(propertyaddress, 1, charindex(',', propertyaddress) - 1),
propertycity = substring(propertyaddress, charindex(',', propertyaddress) + 1, len(propertyaddress))

select propertyaddress, propertystreet, propertycity
from CovidProject..NashvilleHousing

select owneraddress
from CovidProject..NashvilleHousing

select parsename(replace(owneraddress, ',', '.'), 3),
parsename(replace(owneraddress, ',', '.'), 2),
parsename(replace(owneraddress, ',', '.'), 1)
from CovidProject..NashvilleHousing

alter table CovidProject..NashvilleHousing
add ownerstreet nvarchar(255), 
ownercity nvarchar(255),
ownerstate nvarchar(255)

update CovidProject..NashvilleHousing
set ownerstreet = parsename(replace(owneraddress, ',', '.'), 3),
ownercity = parsename(replace(owneraddress, ',', '.'), 2),
ownerstate = parsename(replace(owneraddress, ',', '.'), 1)

select owneraddress, ownerstreet, ownercity, ownerstate
from CovidProject..NashvilleHousing

-- Change Y and N to Yes and No

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from CovidProject..NashvilleHousing

update CovidProject..NashvilleHousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end

select soldasvacant, count(soldasvacant)
from CovidProject..NashvilleHousing
group by soldasvacant

-- Remove duplicates

with rownum as(
select *,
row_number() over (
partition by parcelid, propertyaddress, saleprice, saledate, legalreference
order by uniqueid
) row_num
from CovidProject..NashvilleHousing
)
delete 
from rownum
where row_num>1
-- order by uniqueid

with rownum as(
select *,
row_number() over (
partition by parcelid, propertyaddress, saleprice, saledate, legalreference
order by uniqueid
) row_num
from CovidProject..NashvilleHousing
)
select *
from rownum
where row_num>1
order by uniqueid

-- Delete unused columns

select *
from CovidProject..NashvilleHousing

alter table CovidProject..NashvilleHousing
drop column propertyaddress, owneraddress, taxdistrict, saledate