# Smart contracts

## Config ItemFactory
* Set Item scope and deploy
```
// Mystery Box
_supportedBoxTypes.add(1); // #1
_supportedBoxTypes.add(2); // #2

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
_addTypeArtifact(1, 2, 0, 4); // ItemType#1, Artifact#2, 0-4
_addTypeArtifact(1, 3, 0, 5); // ItemType#1, Artifact#3, 0-5
_addTypeArtifact(1, 4, 0, 5); // ItemType#1, Artifact#4, 0-5
_addTypeArtifact(1, 5, 0, 5); // ItemType#1, Artifact#5, 0-5
_addTypeArtifact(1, 6, 0, 5); // ItemType#1, Artifact#6, 0-5
_addTypeArtifact(1, 7, 0, 5); // ItemType#1, Artifact#7, 0-5
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
## Mint mystery box
```
let sendEncodeABI = nftManager.methods.mint(user, 1).encodeABI();
```

## Batch mint mystery boxes
```
let sendEncodeABI = nftManager.methods.mintBatch(user, 1, 2).encodeABI();
```

## List NFT

## List mystery boxes

## Unbox NFT
```
let sendEncodeABI = nftManager.methods.unbox(1).encodeABI();
```

## Get Unboxed NFT details
```

```

## Buy NFT by BNB

## Buy mystery box by BNB

## Buy NFT by Token

## Buy mystery box by Token

## Update NFT price(BNB)

## Update NFT price(Token)

## Unlist NFT

## Unlist mystery boxes

