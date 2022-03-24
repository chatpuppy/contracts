/**
 * Testing Item Factory
 */

import {execContract} from './web3.js';
import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import {getTokensOfOwner} from 'erc721-balance';
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method

const Web3 = require('web3');
const rpcUrl = process.env.RPC_URL;
const chainId = process.env.CHAIN_ID * 1;
const priKey = process.env.PRI_KEY;
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));

// const itemFactoryAddress = '0x93E138E8B9E4f034A6c05C3380606109b8b58D5f'; // bscTestnet
const itemFactoryAddress = '0x21C0Dd93f1c00c9741504D4640EDd5C4a8E3f128'; // mumbai
const itemFactoryJson = require('../build/contracts/ItemFactory.json');

const itemFactory = new web3.eth.Contract(itemFactoryJson.abi, itemFactoryAddress);

const boxType = 7;
const itemId = 4;
const boxTypes = [2,3,4,5,6,7];
// itemFactory.methods.owner().call().then((owner) => console.log('owner of contract', owner));
// itemFactory.methods.supportedBoxTypes().call().then((types) => console.log('box types', types));
// itemFactory.methods.totalSupply(1).call().then((response) => console.log('total supply', response));

itemFactory.methods.getItemRarity(boxType, itemId).call().then((response) => console.log('item rarity', response));
itemFactory.methods.getItemProperties(boxType, itemId).call().then((response) => console.log('item properties', response));
itemFactory.methods.getItemTotalRarity(boxType).call().then((response) => console.log('item total rarity', response));

// itemFactory.methods.getItemInitialLevel(boxTypes, [5,1,3,11,3,4]).call().then((response) => console.log('level', response));
// itemFactory.methods.getItemInitialExperience(boxTypes, [5,1,3,11,3,4]).call().then((response) => console.log('experience', response));

// itemFactory.methods.getItemIds(boxTypes).call().then((response) => console.log('items ids', response));
// itemFactory.methods.getItemProperties(boxType, itemId).call().then((response) => {
// 	console.log('item level', response[0] * 1);
// 	console.log('item experience', response[1] * 1)
// });

// Testing getRandomItem, verifying the params of item is right or not.
function checkItemData(num) {
	let randomResult = [0,0,0,0,0,0,0,0,0,0,0,0];
	let count = 0;
	for(let r = 0; r < num; r++) {
		const randomSeed = Math.floor(Math.random() * 10000000);
		itemFactory.methods.getRandomItem(randomSeed, boxType).call().then((result) => {
			randomResult[result] = randomResult[result] + 1;
			count++;
			if(num === count) {
				console.log(randomResult);
			}
		});
	}
}

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, onConfirmedFunc, onErrorFunc) => 
	execContract(web3, chainId, priKey, encodeABI, 0, contractAddress, null, onConfirmedFunc, null, onErrorFunc);	

/**
 * Chatpuppy rarity list
 * 
 * BoxType: 2, background
 * item Id#1: name=Blue,   rarity=280000, level=1, experience=1
 * item Id#2: name=Orange, rarity=230000, level=1, experience=20
 * item Id#3: name=Purple, rarity=190000, level=1, experience=50
 * item Id#4: name=Red,    rarity=150000, level=1, experience=85
 * item Id#5: name=Green,  rarity=100000, level=1, experience=180
 * item Id#6: name=Grey,   rarity=50000,  level=1, experience=460
 * 
 * BoxType: 3, body
 * item Id#11: name=Gakuran,	rarity=330000, level=1, experience=1
 * item Id#12: name=Bandana, rarity=120000, level=1, experience=175
 * item Id#13: name=Tropical, rarity=150000, level=1, experience=120
 * item Id#14: name=Hoodie,  rarity=140000, level=1, experience=135
 * item Id#15: name=Stonks,  rarity=100000, level=1, experience=230
 * item Id#16: name=Business, rarity=160000, level=1, experience=110
 * 
 * BoxType: 4, eyes
 * item Id#21: name=Normal,  rarity=300000, level=1, experience=1
 * item Id#22: name=Bored, 	rarity=130000, level=1, experience=130
 * item Id#23: name=Laser, 	rarity= 60000, level=1, experience=400
 * item Id#24: name=Class1, 	rarity= 90000, level=1, experience=235
 * item Id#25: name=Class2,  rarity=110000, level=1, experience=170
 * item Id#26: name=Class3,	rarity=160000, level=1, experience=90
 * item Id#27: name=3D Glass,rarity=150000, level=1, experience=100
 * 
 * BoxType: 5, hats
 * item Id#31: name=Plumer,	rarity= 60000, level=1, experience=530
 * item Id#32: name=Halo, 		rarity= 65000, level=1, experience=480
 * item Id#33: name=Mohawk,  rarity= 70000, level=1, experience=440
 * item Id#34: name=Rainbow, rarity= 90000, level=1, experience=320
 * item Id#35: name=Helmet,  rarity= 95000, level=1, experience=300
 * item Id#36: name=Tophat,  rarity= 75000, level=1, experience=400
 * item Id#37: name=Wizard,  rarity= 65000, level=1, experience=480
 * item Id#38: name=Crown,   rarity= 25000, level=1, experience=1420
 * item Id#39: name=Pirate,  rarity= 40000, level=1, experience=850
 * item Id#40:name=Space,   rarity= 35000, level=1, experience=1000
 * item Id#41:name=None,    rarity=380000, level=1, experience=1
 * 
 * BoxType: 6, fur
 * item Id#51: name=Grey,    rarity=370000, level=1, experience=1
 * item Id#52: name=Green,   rarity=160000, level=1, experience=130
 * item Id#53: name=Brown,   rarity=120000, level=1, experience=210
 * item Id#54: name=Gold,    rarity= 60000, level=1, experience=520
 * item Id#55: name=Purple,  rarity=130000, level=1, experience=180
 * item Id#56: name=Pink,    rarity=160000, level=1, experience=130
 * 
 * BoxType: 7, mouth
 * item Id#61: name=Bone,    rarity=180000, level=1, experience=70
 * item Id#62: name=Grrrrr,  rarity=310000, level=1, experience=1
 * item Id#63: name=Soother, rarity=160000, level=1, experience=95
 * item Id#64: name=Beard,   rarity=150000, level=1, experience=110
 * item Id#65: name=Mask,    rarity= 80000, level=1, experience=290
 * item Id#66: name=Gold,    rarity=120000, level=1, experience=160
 */

// let sendEncodeABI = itemFactory.methods.addBoxType(3).encodeABI();
// let sendEncodeABI = itemFactory.methods.addBoxType(4).encodeABI();
// let sendEncodeABI = itemFactory.methods.addBoxType(5).encodeABI();
// let sendEncodeABI = itemFactory.methods.addBoxType(6).encodeABI();
// let sendEncodeABI = itemFactory.methods.addBoxType(7).encodeABI();

// let sendEncodeABI = itemFactory.methods.updateItem(2, 1, 280000, 1, 1).encodeABI();
// callContract(sendEncodeABI, itemFactoryAddress);

const itemParams = [
	{
		boxType: 2,
		itemId:  1,
		rarity:  280000,
		level:   1,
		experience: 1,
	}, 
	{
		boxType: 2,
		itemId:  2,
		rarity:  230000,
		level:   1,
		experience: 20,
	}, 
	{
		boxType: 2,
		itemId:  3,
		rarity:  190000,
		level:   1,
		experience: 50,
	}, 
	{
		boxType: 2,
		itemId:  4,
		rarity:  150000,
		level:   1,
		experience: 85,
	}, {
		boxType: 2,
		itemId:  5,
		rarity:  100000,
		level:   1,
		experience: 180,
	}, {
		boxType: 2,
		itemId:  6,
		rarity:  50000,
		level:   1,
		experience: 460,
	}, {
		boxType: 3,
		itemId:  1,
		rarity:  330000,
		level:   1,
		experience: 1,
	}, {
		boxType: 3,
		itemId:  2,
		rarity:  120000,
		level:   1,
		experience: 175,
	}, {
		boxType: 3,
		itemId:  3,
		rarity:  150000,
		level:   1,
		experience: 120,
	}, {
		boxType: 3,
		itemId:  4,
		rarity:  140000,
		level:   1,
		experience: 135,
	}, {
		boxType: 3,
		itemId:  5,
		rarity:  100000,
		level:   1,
		experience: 230,
	}, {
		boxType: 3,
		itemId:  6,
		rarity:  160000,
		level:   1,
		experience: 110,
	}, {
		boxType: 4, // ===
		itemId:  1,
		rarity:  300000,
		level:   1,
		experience: 1,
	}, {
		boxType: 4,
		itemId:  2,
		rarity:  130000,
		level:   1,
		experience: 130,
	}, {
		boxType: 4,
		itemId:  3,
		rarity:  60000,
		level:   1,
		experience: 400,
	}, {
		boxType: 4,
		itemId:  4,
		rarity:  90000,
		level:   1,
		experience: 235,
	}, {
		boxType: 4,
		itemId:  5,
		rarity:  110000,
		level:   1,
		experience: 170,
	}, {
		boxType: 4,
		itemId:  6,
		rarity:  160000,
		level:   1,
		experience: 90,
	}, {
		boxType: 4,
		itemId:  7,
		rarity:  150000,
		level:   1,
		experience: 100,
	}, {
		boxType: 5,
		itemId:  1,
		rarity:  60000,
		level:   1,
		experience: 530,
	}, {
		boxType: 5,
		itemId:  2,
		rarity:  65000,
		level:   1,
		experience: 480,
	}, {
		boxType: 5,
		itemId:  3,
		rarity:  70000,
		level:   1,
		experience: 440,
	}, {
		boxType: 5,
		itemId:  4,
		rarity:  90000,
		level:   1,
		experience: 320,
	}, {
		boxType: 5,
		itemId:  5,
		rarity:  95000,
		level:   1,
		experience: 300,
	}, {
		boxType: 5,
		itemId:  6,
		rarity:  75000,
		level:   1,
		experience: 400,
	}, {
		boxType: 5,
		itemId:  7,
		rarity:  65000,
		level:   1,
		experience: 480,
	}, {
		boxType: 5,
		itemId:  8,
		rarity:  25000,
		level:   1,
		experience: 1420,
	}, {
		boxType: 5,
		itemId:  9,
		rarity:  40000,
		level:   1,
		experience: 850,
	}, {
		boxType: 5,
		itemId:  10,
		rarity:  35000,
		level:   1,
		experience: 1000,
	}, {
		boxType: 5,
		itemId:  11,
		rarity:  380000,
		level:   1,
		experience: 1,
	}, {
		boxType: 6,
		itemId:  1,
		rarity:  370000,
		level:   1,
		experience: 1,
	}, {
		boxType: 6,
		itemId:  2,
		rarity:  160000,
		level:   1,
		experience: 130,
	}, {
		boxType: 6,
		itemId:  3,
		rarity:  120000,
		level:   1,
		experience: 210,
	}, {
		boxType: 6,
		itemId:  4,
		rarity:  60000,
		level:   1,
		experience: 520,
	}, {
		boxType: 6,
		itemId:  5,
		rarity:  130000,
		level:   1,
		experience: 180,
	}, {
		boxType: 6,
		itemId:  6,
		rarity:  160000,
		level:   1,
		experience: 130,
	}, {
		boxType: 7,
		itemId:  1,
		rarity:  180000,
		level:   1,
		experience: 70,
	}, {
		boxType: 7,
		itemId:  2,
		rarity:  310000,
		level:   1,
		experience: 1,
	}, {
		boxType: 7,
		itemId:  3,
		rarity:  160000,
		level:   1,
		experience: 95,
	}, {
		boxType: 7,
		itemId:  4,
		rarity:  150000,
		level:   1,
		experience: 110,
	}, {
		boxType: 7,
		itemId:  5,
		rarity:  80000,
		level:   1,
		experience: 290,
	}, {
		boxType: 7,
		itemId:  6,
		rarity:  120000,
		level:   1,
		experience: 160,
	}
];

function addItems(id) {
	const params = itemParams[id];
	const sendEncodeABI = itemFactory.methods.addItem(
		params.boxType,
		params.itemId,
		params.rarity,
		params.level,
		params.experience
	).encodeABI();

	callContract(sendEncodeABI, itemFactoryAddress, (confirmationNumber, receipt) => {
		// onConfirmedFunc
		console.log(`#${id}/${itemParams.length} BoxType ${params.boxType}, item ${params.itemId} is done...`);
		if(id + 1 < itemParams.length) addItems(id + 1);
		else console.log(`All items are added...`);
	}, (error) => {
		// onError
		console.log(`#${id} BoxType ${params.boxType}, item ${params.itemId} is error...`);
		if(id + 1 < itemParams.length) addItems(id + 1);
		else console.log(`All items are added...`);
	});
}

// After deploying the ItemFactory contract, you need to config the Item data.
// Run the following function, it will automaticly update the Item data on chain.
// If the operation is paused, check the latest Item Id, and restart from that.
// If the transaction is fault, check the transactionHash in the explorer and get the reason.
// addItems(32);

// After config the item data, we highly suggest to use checkItemData to verify that the configuration is correct.
checkItemData(30);
