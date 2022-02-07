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

const itemFactoryAddress = '0xFd3250eCDb1D067a9f0A4453b3BFB92e66f6f7ca';
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
const callContract = (encodeABI, contractAddress) => execContract(web3, chainId, priKey, encodeABI, contractAddress, null, null, null, null);	

/**
 * Add box#1, ItemType#1
 * item Id#1: name=PunkPuppy, rarity=30, level=10, experience=100
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
