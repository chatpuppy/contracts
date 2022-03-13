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

const itemFactoryAddress = '0x4b0964d7DB4409578fA7935f32713dAf82E53393'; // bscTestnet
const itemFactoryJson = require('../build/contracts/ItemFactory.json');

const itemFactory = new web3.eth.Contract(itemFactoryJson.abi, itemFactoryAddress);

const boxType = 7;
const boxTypes = [2,3,4,5,6,7];
itemFactory.methods.owner().call().then((owner) => console.log('owner of contract', owner));
itemFactory.methods.supportedBoxTypes().call().then((types) => console.log('box types', types));
itemFactory.methods.totalSupply(1).call().then((response) => console.log('total supply', response));
itemFactory.methods.getItemRarity(boxType, 4).call().then((response) => console.log('item rarity', response));
itemFactory.methods.getItemTotalRarity(boxType).call().then((response) => console.log('item total rarity', response));

itemFactory.methods.getItemInitialLevel(boxTypes, [5,1,3,11,3,4]).call().then((response) => console.log('level', response));
itemFactory.methods.getItemInitialExperience(boxTypes, [5,1,3,11,3,4]).call().then((response) => console.log('experience', response));

// Testing getRandomItem, verifying the params of item is right or not.
// const num = 1000;
// let randomResult = [0,0,0,0,0,0,0,0,0,0,0,0];
// let count = 0;
// for(let r = 0; r < num; r++) {
// 	const randomSeed = Math.floor(Math.random() * 10000000);
// 	itemFactory.methods.getRandomItem(randomSeed, boxType).call().then((result) => {
// 		randomResult[result] = randomResult[result] + 1;
// 		count++;
// 		if(num === count) {
// 			console.log(randomResult);
// 		}
// 	});
// }

/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

/**
 * Testing
 * Add box#1, ItemType#1
 * item Id#1: name=PunkPuppy, rarity=3000, level=10, experience=100
 * item Id#2: name=MuskPuppy, rarity=9000, level=9, experience=90
 * item Id#3: name=AlienPuppy, rarity=36000, level=8, experience=80
 * item Id#4: name=DogePuppy, rarity=270000, level=7, experience=70
 * item Id#5: name=ChatPuppy, rarity=682000, level=6, experience=60
 */
// let sendEncodeABI = itemFactory.methods.addItem(1, 1, 1, 3000, 10, 100).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(1, 1, 2, 9000, 9, 90).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(1, 1, 3, 36000, 8, 80).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(1, 1, 4, 270000, 7, 70).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(1, 1, 5, 682000, 6, 60).encodeABI();
// callContract(sendEncodeABI, itemFactoryAddress);

/**
 * Chatpuppy rarity list
 * 
 * BoxType: 2, background
 * item Id#1: name=Blue,   rarity=280000, level=1, experience=0
 * item Id#2: name=Orange, rarity=230000, level=1, experience=20
 * item Id#3: name=Purple, rarity=190000, level=1, experience=50
 * item Id#4: name=Red,    rarity=150000, level=1, experience=85
 * item Id#5: name=Green,  rarity=100000, level=1, experience=180
 * item Id#6: name=Grey,   rarity=50000,  level=1, experience=460
 * 
 * BoxType: 3, body
 * item Id#11: name=Gakuran,	rarity=330000, level=1, experience=0
 * item Id#12: name=Bandana, rarity=120000, level=1, experience=175
 * item Id#13: name=Tropical, rarity=150000, level=1, experience=120
 * item Id#14: name=Hoodie,  rarity=140000, level=1, experience=135
 * item Id#15: name=Stonks,  rarity=100000, level=1, experience=230
 * item Id#16: name=Business, rarity=160000, level=1, experience=110
 * 
 * BoxType: 4, eyes
 * item Id#21: name=Normal,  rarity=300000, level=1, experience=0
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
 * item Id#41:name=None,    rarity=380000, level=1, experience=0
 * 
 * BoxType: 6, fur
 * item Id#51: name=Grey,    rarity=370000, level=1, experience=0
 * item Id#52: name=Green,   rarity=160000, level=1, experience=130
 * item Id#53: name=Brown,   rarity=120000, level=1, experience=210
 * item Id#54: name=Gold,    rarity= 60000, level=1, experience=520
 * item Id#55: name=Purple,  rarity=130000, level=1, experience=180
 * item Id#56: name=Pink,    rarity=160000, level=1, experience=130
 * 
 * BoxType: 7, mouth
 * item Id#61: name=Bone,    rarity=180000, level=1, experience=70
 * item Id#62: name=Grrrrr,  rarity=310000, level=1, experience=0
 * item Id#63: name=Soother, rarity=160000, level=1, experience=95
 * item Id#64: name=Beard,   rarity=150000, level=1, experience=110
 * item Id#65: name=Mask,    rarity= 80000, level=1, experience=290
 * item Id#66: name=Gold,    rarity=120000, level=1, experience=160
 * 
 * 
 */

// Background
// let sendEncodeABI = itemFactory.methods.addItem(2, 1, 280000, 1, 0).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(2, 2, 230000, 1, 20).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(2, 3, 190000, 1, 50).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(2, 4, 150000, 1, 85).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(2, 5, 100000, 1, 180).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(2, 6,  50000, 1, 460).encodeABI();

// Body
// let sendEncodeABI = itemFactory.methods.addBoxType(3).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(3, 1, 330000, 1, 0).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(3, 2, 120000, 1, 175).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(3, 3, 150000, 1, 120).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(3, 4, 140000, 1, 135).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(3, 5, 100000, 1, 230).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(3, 6, 160000, 1, 110).encodeABI();

// Eye
// let sendEncodeABI = itemFactory.methods.addBoxType(4).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(4, 1, 300000, 1, 0).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(4, 2, 130000, 1, 130).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(4, 3,  60000, 1, 400).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(4, 4,  90000, 1, 235).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(4, 5, 110000, 1, 170).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(4, 6, 160000, 1, 90).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(4, 7, 150000, 1, 100).encodeABI();

// Hat
// let sendEncodeABI = itemFactory.methods.addBoxType(5).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 1,  60000, 1, 530).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 2,  65000, 1, 480).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 3,  70000, 1, 440).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 4,  90000, 1, 320).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 5,  95000, 1, 300).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 6,  75000, 1, 400).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 7,  65000, 1, 480).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 8,  25000, 1, 1420).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 9,  40000, 1, 850).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 10, 35000, 1, 1000).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(5, 11,380000, 1, 0).encodeABI();

// Fur
// let sendEncodeABI = itemFactory.methods.addBoxType(6).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(6, 1, 370000, 1, 0).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(6, 2, 160000, 1, 130).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(6, 3, 120000, 1, 210).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(6, 4,  60000, 1, 520).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(6, 5, 130000, 1, 180).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(6, 6, 160000, 1, 130).encodeABI();

// Mouth
// let sendEncodeABI = itemFactory.methods.addBoxType(7).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(7, 1, 180000, 1, 70).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(7, 2, 310000, 1, 0).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(7, 3, 160000, 1, 95).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(7, 4, 150000, 1, 110).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(7, 5,  80000, 1, 290).encodeABI();
// let sendEncodeABI = itemFactory.methods.addItem(7, 6, 120000, 1, 160).encodeABI();

// callContract(sendEncodeABI, itemFactoryAddress);
