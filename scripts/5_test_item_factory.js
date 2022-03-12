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

// const itemFactoryAddress = '0xFd3250eCDb1D067a9f0A4453b3BFB92e66f6f7ca'; // kovan
// const itemFactoryAddress = '0xE10A746fa43010237F28F970896248192A0348eE'; // rinkeby
const itemFactoryAddress = '0xB9323Be650ABD32D4321ED4B8D8010Ca89ABd8E0'; // bscTestnet
const itemFactoryJson = require('../build/contracts/ItemFactory.json');

const itemFactory = new web3.eth.Contract(itemFactoryJson.abi, itemFactoryAddress);

itemFactory.methods.owner().call().then((owner) => console.log('owner of contract', owner));
itemFactory.methods.supportedBoxTypes().call().then((types) => console.log('box types', types));
itemFactory.methods.supportedItemTypes().call().then((types) => console.log('item types', types));
itemFactory.methods.totalSupply(1).call().then((response) => console.log('total supply', response));
itemFactory.methods.artifactsLength(1).call().then((response) => console.log('artifactsLength', response));
itemFactory.methods.getItemRarity(1, 1).call().then((response) => console.log('item rarity', response));
itemFactory.methods.getItemTotalRarity(1).call().then((response) => console.log('item total rarity', response));

// const randomness = '18587561072496307797482513791315350567212816545271487533366584041538045352993';
// itemFactory.methods.getRandomItem(randomness, 1).call().then((response) => console.log('getRandomItem', response));
// Error: ItemFactory: add items for this type before using function

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
 * BoxType: 2
 * 
 * ItemType: 2, background
 * item Id#1: name=Blue,   rarity=280000, level=3, experience=0
 * item Id#2: name=Orange, rarity=230000, level=3, experience=20
 * item Id#3: name=Purple, rarity=190000, level=3, experience=50
 * item Id#4: name=Red,    rarity=150000, level=3, experience=85
 * item Id#5: name=Green,  rarity=100000, level=3, experience=180
 * item Id#6: name=Grey,   rarity=50000,  level=3, experience=460
 * 
 * ItemType: 3, body
 * item Id#1: name=Gakuran,	rarity=330000, level=3, experience=0
 * item Id#2: name=Bandana, rarity=120000, level=3, experience=175
 * item Id#3: name=Tropical, rarity=150000, level=3, experience=120
 * item Id#4: name=Hoodie,  rarity=140000, level=3, experience=135
 * item Id#5: name=Stonks,  rarity=100000, level=3, experience=230
 * item Id#6: name=Business, rarity=160000, level=3, experience=110
 * 
 * ItemType: 4, eyes
 * item Id#1: name=Normal,  rarity=300000, level=3, experience=0
 * item Id#2: name=Bored, 	rarity=130000, level=3, experience=130
 * item Id#3: name=Laser, 	rarity= 60000, level=3, experience=400
 * item Id#4: name=Class1, 	rarity= 90000, level=3, experience=235
 * item Id#5: name=Class2,  rarity=110000, level=3, experience=170
 * item Id#6: name=Class3,	rarity=160000, level=3, experience=90
 * item Id#7: name=3D Glass,rarity=150000, level=3, experience=100
 * 
 * ItemType: 5, hats
 * item Id#1: name=Plumer,	rarity= 60000, level=3, experience=530
 * item Id#2: name=Halo, 		rarity= 65000, level=3, experience=480
 * item Id#3: name=Mohawk,  rarity= 70000, level=3, experience=440
 * item Id#4: name=Rainbow, rarity= 90000, level=3, experience=320
 * item Id#5: name=Helmet,  rarity= 95000, level=3, experience=300
 * item Id#6: name=Tophat,  rarity= 75000, level=3, experience=400
 * item Id#7: name=Wizard,  rarity= 65000, level=3, experience=480
 * item Id#8: name=Crown,   rarity= 25000, level=3, experience=1420
 * item Id#9: name=Pirate,  rarity= 40000, level=3, experience=850
 * item Id#10:name=Space,   rarity= 35000, level=3, experience=1000
 * item Id#11:name=None,    rarity=380000, level=3, experience=0
 * 
 * ItemType: 6, fur
 * item Id#1: name=Grey,    rarity=370000, level=3, experience=0
 * item Id#2: name=Green,   rarity=160000, level=3, experience=130
 * item Id#3: name=Brown,   rarity=120000, level=3, experience=210
 * item Id#4: name=Gold,    rarity= 60000, level=3, experience=520
 * item Id#5: name=Purple,  rarity=130000, level=3, experience=180
 * item Id#6: name=Pink,    rarity=160000, level=3, experience=130
 * 
 * ItemType: 7, mouth
 * item Id#1: name=Bone,    rarity=180000, level=3, experience=70
 * item Id#2: name=Grrrrr,  rarity=310000, level=3, experience=0
 * item Id#3: name=Soother, rarity=160000, level=3, experience=95
 * item Id#4: name=Beard,   rarity=150000, level=3, experience=110
 * item Id#5: name=Mask,    rarity= 80000, level=3, experience=290
 * item Id#6: name=Gold,    rarity=120000, level=3, experience=160
 * 
 * 
 */

// Background
let sendEncodeABI = itemFactory.methods.addItem(2, 2, 1, 280000, 3, 0).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 2, 2, 230000, 3, 20).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 2, 3, 190000, 3, 50).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 2, 4, 150000, 3, 85).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 2, 5, 100000, 3, 180).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 2, 6,  50000, 3, 460).encodeABI();

// Body
let sendEncodeABI = itemFactory.methods.addItem(2, 3, 1, 330000, 3, 0).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 3, 2, 120000, 3, 175).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 3, 3, 150000, 3, 120).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 3, 4, 140000, 3, 135).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 3, 5, 100000, 3, 230).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 3, 6, 160000, 3, 110).encodeABI();

// Eye
let sendEncodeABI = itemFactory.methods.addItem(2, 4, 1, 300000, 3, 0).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 4, 2, 130000, 3, 130).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 4, 3,  60000, 3, 400).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 4, 4,  90000, 3, 235).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 4, 5, 110000, 3, 170).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 4, 6, 160000, 3, 90).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 4, 7, 150000, 3, 100).encodeABI();

// Hat
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 1,   60000, 3, 530).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 2,   65000, 3, 480).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 3,   70000, 3, 440).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 4,   90000, 3, 320).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 5,   95000, 3, 300).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 6,   75000, 3, 400).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 7,   65000, 3, 480).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 8,   25000, 3, 1420).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 9,   40000, 3, 850).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 10,  35000, 3, 1000).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 5, 11, 380000, 3, 0).encodeABI();

// Fur
let sendEncodeABI = itemFactory.methods.addItem(2, 6, 1, 370000, 3, 0).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 6, 2, 160000, 3, 130).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 6, 3, 120000, 3, 210).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 6, 4,  60000, 3, 520).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 6, 5, 130000, 3, 180).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 6, 6, 160000, 3, 130).encodeABI();

// Mouth
let sendEncodeABI = itemFactory.methods.addItem(2, 7, 1, 180000, 3, 70).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 7, 2, 310000, 3, 0).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 7, 3, 160000, 3, 95).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 7, 4, 150000, 3, 110).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 7, 5,  80000, 3, 290).encodeABI();
let sendEncodeABI = itemFactory.methods.addItem(2, 7, 6, 120000, 3, 160).encodeABI();

// callContract(sendEncodeABI, itemFactoryAddress);
