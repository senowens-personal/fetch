CREATE TABLE "users" (
  uid SERIAL PRIMARY KEY,
  id Text,
  active Boolean,
  createdDate Timestamp,
  lastLogin Timestamp,
  role Text,
  signUpSource Text,
  state Text
);

CREATE TABLE "receipts" (
  id Text,
  bonusPointsEarned Int,
  bonusPointsEarnedReason Text,
  createDate Timestamp,
  dateScanned Timestamp,
  finishedDate Timestamp,
  modifyDate Timestamp,
  pointsAwardedDate Timestamp,
  pointsEarned Decimal,
  purchaseDate Timestamp,
  purchasedItemCount Int,
  rewardsReceiptStatus Text,
  totalSpent Decimal,
  userID Text,
  PRIMARY KEY (id)
);

CREATE TABLE "cpg" (
  uuid SERIAL PRIMARY KEY,
  id Text,
  ref Text
);

CREATE TABLE "brands" (
  id Text,
  cpgID Text,
  category Text,
  categoryCode Text,
  barcode Text,
  brandCode Text,
  topBrand Boolean,
  name Text,
  PRIMARY KEY (id)
);

CREATE TABLE rewardsReceiptItem (
  id SERIAL PRIMARY KEY,
  receiptID Text,
  barcode Text,
  brandCode Text,
  description Text,
  discountedItemPrice Decimal,
  finalPrice Decimal,
  itemPrice Decimal,
  partnerItemId Int,
  pointsEarned Decimal,
  pointsPayerId Text,
  quantityPurchased Int,
  rewardsGroup Text,
  rewardsProductPartnerId Text,
  originalReceiptItemText Text,
  targetPrice Decimal,
  CONSTRAINT "FK_rewardsReceiptItem.receiptID"
    FOREIGN KEY (receiptID)
      REFERENCES "receipts"(id)
);

