/**
 * Testing NFT Core
 */

import {execContract} from './web3.js';
import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import {getTokensOfOwner} from 'erc721-balance';
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method

const rpcUrl = process.env.RPC_URL;
const chainId = process.env.CHAIN_ID * 1;
const Web3 = require('web3');
const priKey = process.env.PRI_KEY;
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));

const nftAddress = '0x10761406c9a8898e9B0e0874e0408fc841aaa64c'; // Issued by nft core
// const nftAddress = '0x1cB4121a8cF941Ec5d83DBd4953ed0f3551F3CFD'; // Issued by nft manager
const nftJson = require('../build/contracts/DragonaireNFTCore.json');

const nft = new web3.eth.Contract(nftJson.abi, nftAddress);

nft.methods.name().call().then((response) => console.log('nft name', response));
nft.methods.totalSupply().call().then((response) => console.log('totalSupply', response / 1));
nft.methods.cap().call().then((cap) => console.log('cap', cap * 1));

// nft.methods.balanceOf('0x615b80388E3D3CaC6AA3a904803acfE7939f0399').call().then((response) => console.log('balanceOf', response / 1));
// nft.methods.owner().call().then((owner) => console.log('owner of contract', owner));
// nft.methods.tokenURI(2).call().then((res) => console.log('tokenUri', res));
// getTokensOfOwner(web3, '0xa4c65a9d0f892FBdA1EB04cC0634f1B94684F650', '0x615b80388E3D3CaC6AA3a904803acfE7939f0399').then((res) => console.log('getTokensOfOwner', res));
// nft.methods.ownerOf(1).call().then((owner) => console.log('owner of nft', owner));


/**
 * ==== Following testing methods is Send Tx ====
 */
const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

// let sendEncodeABI = nft.methods.increaseCap(1).encodeABI();
// let sendEncodeABI = nft.methods.updateBaseTokenURI("https://dragonaire.com/").encodeABI();
// const testAcc = '0x615b80388E3D3CaC6AA3a904803acfE7939f0399';
// let sendEncodeABI = nft.methods.mint(testAcc).encodeABI();
// let sendEncodeABI = nft.methods.updateTokenMetaData(1, 256).encodeABI();

// let sendEncodeABI = nft.methods.mintBatch(testAcc, 3).encodeABI();

/** transfer testing
 * Acc#1 0x615b80388E3D3CaC6AA3a904803acfE7939f0399 30 id2=>acc#2
 * Acc#2 0xC4BFA07776D423711ead76CDfceDbE258e32474A 
 * Acc#3 0xF0Ab3FD4bf892BcB9b40B9c6B5a05e02f3afe833 
 * kov#1 0x3FE7995Bf0a505a51196aA11218b181c8497D236 
 * kov#2 0x0bD170e705ba74d6E260da59AF38EE3980Cf1ce3 
 * kov#3 0x3444E23231619b361c8350F4C83F82BCfAB36F65 
 */
// let sendEncodeABI = nft.methods.safeTransferFrom('0x615b80388E3D3CaC6AA3a904803acfE7939f0399', '0xC4BFA07776D423711ead76CDfceDbE258e32474A', 2).encodeABI();
let sendEncodeABI = nft.methods.transferOwnership('0x0D84C154D3E063D0E70bde29BC997ee605ABEc35').encodeABI();
callContract(sendEncodeABI, nftAddress);
