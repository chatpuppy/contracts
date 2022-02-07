# Smart contracts

## Addresses on kovan
* NFT token: `0x7820D4158627F329f44c94e294109F91FE86cB77`
* NFT Manager(mystery box): `0x0528E41841b8BEdD4293463FAa061DdFCC5E41bd`
* Item Factory: `0xFd3250eCDb1D067a9f0A4453b3BFB92e66f6f7ca`
* Random Generator: `0xA28D90320005C8c043Ee79ae59e82fDd5f983f30`
* Marketplace: 

## Mystery box artifacts format
```
0~7: boxType, len=8, 0-255
8~15: itemType, len=8, 0-255
16~31: itemId, len=16, 0-65535
32~47: Initial level, len=16, 0-65535
48~63: Initial experience, len=16, 0-65535
64~87: picId, len=24, the picture will save as itemId_picId.png, such as `3_12.png` it is the 12th pic in item#3
88~95: artifactId_1, len=8
96~111: artifactValue_1, len=16
112~119: artifactId_2, len=8
120~135: artifactValue_2, len=16
...
```
Max store: (256 - 88) / 24 = 7 artifacts

## dna format
```
dna = bytes32(keccak256(abi.encodePacked(tokenId_, randomness_)));
```

## NFT URI
* method
```
nft.methods.tokenURI(tokenId).call();
```
* return
```
https://nft.chatpuppy.com/token/0x08/0x2607002106001705001604000c030009020001010000020046000700040101
```
* explaination
	* 0x08: tokenId
	* 0x2607002106001705001604000c030009020001010000020046000700040101: see below:
  
	0x26 07 0021 06 0017 05 0016 04 000c 03 0009 02 0001 01 000092 0046 0007 0004 01 01

  |offset|lengh|data|memo|
	|-:|-:|-:|-:|
	|0|8|01|BoxType=1|
	|8|8|01|ItemType=1|
	|16|16|0004|ItemId=4|
	|32|16|0007|InitialLevel=0x0007|
	|48|16|0046|InitialExperience=0x0046|
	|64|24|000092|NFT picId=0x000092|
	|88|8|01|artifactId=1|
	|96|16|0001|artificatValue=1|
	|112|8|02|artifactId=2|
	|120|16|0009|artifactId=9|
	|136|8|03|artifactId=3|
	|144|16|000c|artificatValue=0x000c|
	|160|8|04|artifactId=4|
	|168|16|0016|artificatValue=0x0016|
	|184|8|05|artifactId=5|
	|192|16|0017|artificatValue=0x0017|
	|208|8|06|artifactId=6|
	|216|16|0021|artificatValue=0x0021|
	|232|8|07|artifactId=7|
	|240|16|0026|artificatValue=0x0026|

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
 * itemId#1: PunkPuppy, rarity=3000(0.3%)
 * itemId#2: MuskPuppy, rarity=9000(0.9%)
 * itemId#3: AlienPuppy, rarity=36000(3.6%)
 * itemId#4: DogePuppy, rarity=270000(27%)
 * itemId#5: ChatPuppy, rarity=682000(68.2%)
 */
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 1, 3000).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 2, 9000).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 3, 36000).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 4, 270000).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(1, 1, 5, 682000).encodeABI();
```

## Mint one mystery box(only contract manager can do)
```
nftManager.methods.mint(userAddress, boxType).send();
```

## Buy mystery box and don't unbox(anybody can do)
```
nftManager.methods.buyAndMint(boxType).send();
```

## Buy mystery box and unbox immediately(anybody can do)
```
nftManager.methods.buyMintAndUnbox(boxType).send();
```

## Batch buy mystery box and mint(anybody can do)
```
nftManager.methods.buyAndMintBatch(boxType, amount).send();
```

## Batch mint mystery boxes (only contract manager can do)
```
nftManager.methods.mintBatch(userAddress, boxType, amount).send();
```

## Unbox NFT(only mystery box's owner can do)
```
nftManager.methods.unbox(tokenId).send();
```

## Get mystery box NFT status
```
nftManager.methods.boxStatus(tokenId).call();
```

## Withdraw from contract(only called by contract manager)
```
nftManager.methods.withdraw(toAddress, amount).send()
```

## Get NFT metadata
```
nft.methods.tokenMetaData(tokenId).call();
```

## List NFT

## List mystery boxes

## Buy NFT by BNB from marketplace

## Buy mystery box by BNB from marketplace

## Update NFT price(BNB) on marketplace

## Update NFT price(Token) on marketplace

## Unlist NFT from marketplace

## Unlist mystery boxes from marketplace

