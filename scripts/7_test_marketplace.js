/**
 * Testing NFT Marketplace
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

const marketplaceAddress = '0xb8Dc7A4aceeC5e95E3e5ACc9Ee9E552efb6c2733';
const marketplaceJson = require('../build/contracts/ChatPuppyNFTMarketplace.json');
const nftJson = require('../build/contracts/ChatPuppyNFTCore.json');

const marketplace = new web3.eth.Contract(marketplaceJson.abi, marketplaceAddress);

marketplace.methods.nftCore().call().then((nftAddress) => {
	console.log('nft Address', nftAddress);
	const nft = new web3.eth.Contract(nftJson.abi, nftAddress);
	nft.methods.name().call().then((response) => console.log('nft name', response));
	nft.methods.totalSupply().call().then((response) => console.log('totalSupply', response / 1));
	nft.methods.owner().call().then((owner) => console.log('owner of contract', owner));
	nft.methods.balanceOf('0xC4BFA07776D423711ead76CDfceDbE258e32474A').call().then((response) => console.log('balanceOf', response / 1));
	nft.methods.cap().call().then((cap) => console.log('cap', cap * 1));
	nft.methods.tokenURI(2).call().then((res) => console.log('tokenUri', res));
	nft.methods.ownerOf(2).call().then((owner) => console.log('owner of nft', owner));

	/**
	 * ==== Following testing methods is Send Tx ====
	 */
	const callContract = (encodeABI, contractAddress, value) => execContract(web3, chainId, priKey, encodeABI, value === null ? 0:value, contractAddress, null, null, null, null);	

	// let sendEncodeABI = marketplace.methods.addPaymentToken(0).encodeABI();

	// Approve marketplace to the NFT
	// ######

	// List nft
	// let sendEncodeABI = marketplace.methods.addOrder(1, '0x0000000000000000000000000000000000000000', '100000000000000000').encodeABI();
	// callContract(sendEncodeABI, marketplaceAddress);
});
