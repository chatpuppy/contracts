# Smart contracts

## Addresses on kovan
* CPT Token: `0x7C4b6E294Fd0ae77B6E1730CBEb1B8491859Ee24`
* NFT token: `0xAb50F84DC1c8Ef1464b6F29153E06280b38fA754`
* NFT Manager(mystery box): `0x0528E41841b8BEdD4293463FAa061DdFCC5E41bd`
* Item Factory: `0xFd3250eCDb1D067a9f0A4453b3BFB92e66f6f7ca`
* Random Generator: `0xA28D90320005C8c043Ee79ae59e82fDd5f983f30`
* Marketplace: `0xc60a6AE3a85838D3bAAf359219131B1e33103560`

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

 * note: artifacts data generally is for `Game`, normal NFT Dapp can neglect artifacts and no need to setup `_addTypeArtifact` in `ItemFactory` contract.

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

* Add item and set rarity for each item
```
/**
 * Add box#1, ItemType#1
 * item Id#1: name=PunkPuppy, rarity=30 (0.3%), level=10, experience=100
 * item Id#2: name=MuskPuppy, rarity=9000 (0.9%), level=9, experience=90
 * item Id#3: name=AlienPuppy, rarity=36000 (3.6%), level=8, experience=80
 * item Id#4: name=DogePuppy, rarity=270000 (27%), level=7, experience=70
 * item Id#5: name=ChatPuppy, rarity=682000 (68.2%), level=6, experience=60
 */
itemFactory.methods.addItem(1, 1, 1, 3000, 10, 100).send();
itemFactory.methods.addItem(1, 1, 2, 9000, 9, 90).send();
itemFactory.methods.addItem(1, 1, 3, 36000, 8, 80).send();
itemFactory.methods.addItem(1, 1, 4, 270000, 7, 70).send();
itemFactory.methods.addItem(1, 1, 5, 682000, 6, 60).send();
```

## Mint one mystery box(only contract manager can do)
```
nftManager.methods.mint(userAddress, boxType).send();
```

## Buy one mystery box and don't unbox(anybody can do)
```
nftManager.methods.buyAndMint(boxType).send();
```
* Note: Using BNB/ETH while buying mystery box, but if trading on marketplace, must use ChatPuppyToken(CPT)

## Buy one mystery box and unbox immediately(anybody can do)
```
nftManager.methods.buyMintAndUnbox(boxType).send();
```

## Batch buy mystery box and mint(anybody can do)
```
nftManager.methods.buyAndMintBatch(boxType, amount).send();
```
* Suggest not more than 3 mystery boxes once.

## Batch mint mystery boxes (only contract manager can do)
```
nftManager.methods.mintBatch(userAddress, boxType, amount).send();
```

## Unbox NFT(only mystery box's owner can do)
```
nftManager.methods.unbox(tokenId).send();
```
* This method will call `requestRandomNumber` of `ChainLinkRandomGenerator.sol`, after random number issue, callback function `fulfillRandomness` will be executed. This process need several blockchain confirmation.

## Get mystery box NFT status
```
nftManager.methods.boxStatus(tokenId).call();
```
* return:
  * 2: still unboxing, that means the `fulfillRandomness` has not been executed.
  * 1: unboxed
  * 0: not boxed

## Withdraw from NFT manager contract(only called by contract manager)
```
nftManager.methods.withdraw(toAddress, amount).send();
```

## Get NFT metadata
```
nft.methods.tokenMetaData(tokenId).call();
```

## add NFT to order list
First, you need to approve marketplace contract to use the NFT tokenId:
```
nft.methods.approve(marketplaceAddress, tokenId).send();
```

Then, `addOrder`
```
marketplace.methods.addOrder(tokenId, paymentToken, price).send();
```
* paymentToken: use `CPT` token
* price: `'100000000000000000000'` means `100 CPT`


## List all order details
```
	marketplace.methods.onSaleOrderCount().call().then((orderAccount) => { 
		console.log('onSaleOrderCount', orderAccount);
		for(let i = 0; i < orderAccount; i++) {
			marketplace.methods.onSaleOrderAt(i).call().then((orderId) => {
				console.log('orderId', orderId);
				marketplace.methods.orders(orderId).call().then((orderDetails) => console.log('orderId', orderId, 'details', orderDetails));
			});
		}
	});
```

## Unlist NFT from marketplace
```
marketplace.methods.cancelOrder(orderId).send();
```
* Note: if an NFT was listed, it can not be transfered. If you want to transfer, must run `cancelOrder` to unlist.

## Update NFT price(CPT Token) in marketplace
```
marketplace.methods.updatePrice(orderId, price).send();
```

## Buy NFT by CPT token from marketplace
First, approve the marketplace contract use CPT token
```
cptToken.methods.approve(marketplaceAddress, amount).send();
```

Then, call `matchOrder` in marketplace contract
```
marketplace.methods.matchOrder(orderId, price).send();
```
* Note: if buy or sell in the marketplace, must use CPT token.

----------------------------------------------------------------

# Token vesting managment
## 1- Only operated by owner
### Update ERC20 token
```
updateToken(tokenAddress)
```
OK

### Add beneficiary by owner
```
function addBeneficiary(
		address beneficiary_,
		uint256 genesisTimestamp_,
		uint256 totalAmount_,
		uint256 tgeAmount_,
		uint256 cliff_,
		uint256 duration_,
		uint8   participant_,
		uint256 basis_
) external;
```
OK

### Start vesting of a beneficiary by owner
```
activate(beneficiaryIndex)
```
OK

### Start all beneficiaries' vesting by owner
```
activateAll()
```
OK

### Start a type of participants vesting by owner
```
activeParticipant(participant)
```
Ok

### Release all amount for all beneficiaries by owner
* Note: make sure the token vesting contract address is authorized by CPT Token
```
releaseAll()
```
OK

### Release all amount for a type of participants by owner
```
releaseParticipant(participant)
```
OK

### Forbiden a beneficiary to claim by owner
```
revoke(beneficiaryIndex)
```
OK

### Withdraw all revoked amount from contract by owner
```
withdraw(amount)
```
OK

#### Get all beneficiaries data only by owner
```
getAllBeneficiaries()
```
OK

### Set croud funding params by owner
```
setCrowdFundingParams
```
OK

### Add price and amount range for each phase by owner
```
setPriceRange
```
OK

### Update price and amount range for each phase by owner
```
updatePriceRange
```

### Withdraw ETH/BNB from contract by owner
```
withdrawCoin(amount)
```

## 2- Operated by all
### 2.1- Get methods
#### Get ERC20 token address
```
token
```
OK

#### Get total amount
```
total()
```
OK

#### Get totol amount of all beneficiaries
```
getTotalAmountByParticipant(participant)
```
OK

#### Get count of all beneficiaries
```
getBeneficiaryCount()
```
OK

#### Get total amount of a type of participants
```
getTotalAmountByParticipant(participant)
```
OK

#### Get all releasable amount of all beneficiaries
```
releasable()
```
OK

#### Get releasable amount of a beneficiary
```
releasable(beneficiaryIndex)
```
OK

#### Get releasable amount of of a type of participants
```
participantReleasable(participant)
```
OK

#### Get all released amount of all beneficiaries
* Note: make sure the token vesting contract address is authorized by CPT Token
```
released()
```
OK

#### Get all released amount of a type of participants
```
participantReleased(participant)
```
OK

#### Get is already in the beneficiaries list
```
getBeneficiaryCount()
```
OK

#### Get beneficiary's index
```
getIndex(beneficiaryAddress)
```
OK

#### Get beneficiary by index
```
getBeneficiary(beneficiaryIndex)
```
OK

#### Get revoked amount
```
revokedAmount
```
OK

#### Get revoked and withdrawed amount
```
revokedAmountWithdrawn
```
OK

#### Get price for phase according to the raised amount
```
getPriceForAmount(participant, amount)
```

#### Get price for the current phase
```
getCurrentPrice(participant)
```

#### Get price range data of given participant for crowd funding
```
_priceRange(participant)
```
OK

#### Get Genesis Timestamp of given participant for crowd funding
```
_genesisTimestamp(participant)
```
OK

#### Get tge amount ratio of given participant for crowd funding
```
_tgeAmountRatio(participant)
```
OK

#### Get tge amount ratio decimals of given participant for crowd funding
```
_ratioDecimals(participant)
```
OK

#### Get cliff of given participant for crowd funding
```
_cliff(participant)
```
OK

#### Get duration of given participant for crowd funding
```
_duration(participant)
```
OK

#### Get basis of given participant for crowd funding
```
_basis(participant)
```
OK

#### Get limitation of given participant for crowd funding
```
_limitation(participant)
```
OK

### 2.2- Set methods buy beneficiary or donator

#### Release/claim by the beneficiary himself
```
release()
```
OK

### CrowdFunding
This is payable function, pay ETH/BNB and get token benefit, the investor should claim the token then can get real token.
```
crowdFunding(participant)
```
