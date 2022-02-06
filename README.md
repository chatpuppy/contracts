# Smart contracts

## Config ItemFactory
* Set Item scope and deploy
```
// Mystery Box
_supportedBoxTypes.add(1); // #1
_supportedBoxTypes.add(2); // #2 TODO

// ItemType
_supportedItemTypes.add(1); // ItemType#1, ChatPuppy NFT group#1
_supportedItemTypes.add(2); // ItemType#2, ChatPuppy NFT group#2, TODO

/*
	6 types of eyes, artifact#1
	4 types of ear-ornament, artifact#2
	6 types of mouths, artifact#3
	6 types of caps, artifact#4
	6 types of cloths, artifact#5
	6 types of background colors, artifact#6
	6 types of skin colors, artifact#7
*/
_addTypeArtifact(1, 1, 0, 5);  // ItemType#1，Artifact#1, 0-5
_addTypeArtifact(1, 2, 6, 10); // ItemType#1, Artifact#2, 6-10
_addTypeArtifact(1, 3, 11, 16); // ItemType#1, Artifact#3, 11-16
_addTypeArtifact(1, 4, 17, 22); // ItemType#1, Artifact#4, 17-22
_addTypeArtifact(1, 5, 23, 28); // ItemType#1, Artifact#5, 23-28
_addTypeArtifact(1, 6, 29, 34); // ItemType#1, Artifact#6, 29-34
_addTypeArtifact(1, 7, 35, 40); // ItemType#1, Artifact#7, 35-40
```

* add item and rarity for each item
```
/**
 * Add box#1, ItemType#1
 * itemId#1: PunkPuppy, rarity=3000
 * itemId#2: MuskPuppy, rarity=9000
 * itemId#3: AlienPuppy, rarity=36000
 * itemId#4: DogePuppy, rarity=270000
 * itemId#5: ChatPuppy, rarity=682000
 */
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 1, 3000).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 2, 9000).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 3, 36000).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 4, 270000).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 5, 682000).encodeABI();
```
* 
## Mint one mystery box
```
nftManager.methods.mint(user, boxType).send();
```

## Batch mint mystery boxes
```
nftManager.methods.mintBatch(user, boxType, amount).send();
```

## Unbox NFT
```
nftManager.methods.unbox(tokenId).send();
```

## Get Unboxed NFT details
```
nft.methods.tokenMetaData(tokenId).call();
```

## List NFT

## List mystery boxes

## Buy NFT by BNB

## Buy mystery box by BNB

## Buy NFT by Token

## Buy mystery box by Token

## Update NFT price(BNB)

## Update NFT price(Token)

## Unlist NFT

## Unlist mystery boxes

