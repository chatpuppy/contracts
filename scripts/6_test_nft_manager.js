/**
 * Testing NFT Manager
 */

import {execContract} from './web3.js';
import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import {getTokensOfOwner} from 'erc721-balance';
import dotenv from 'dotenv';
dotenv.config();
const require = createRequire(import.meta.url); // construct the require method

// const rpcUrl = 'https://bsc-dataseed1.binance.org';
const rpcUrl = 'https://data-seed-prebsc-1-s1.binance.org:8545';
const chainId = 97;
const Web3 = require('web3');
const priKey = process.env.PRI_KEY;
const web3 = new Web3(new Web3.providers.HttpProvider(rpcUrl));

const nftManagerAddress = '0xF46a6bBAA4985156a145783301ff360539b3Ccf8';
const nftManagerJson = require('../build/contracts/DragonaireNFTManager.json');
const nftJson = require('../build/contracts/DragonaireNFTCore.json');

const nftManager = new web3.eth.Contract(nftManagerJson.abi, nftManagerAddress);
const user = '0x615b80388E3D3CaC6AA3a904803acfE7939f0399';

nftManager.methods.nftCore().call().then((nftAddress) => {
	console.log('nft Address', nftAddress); // 0x1cB4121a8cF941Ec5d83DBd4953ed0f3551F3CFD
	const nft = new web3.eth.Contract(nftJson.abi, nftAddress);
	nft.methods.name().call().then((response) => console.log('nft name', response));
	nft.methods.totalSupply().call().then((response) => console.log('totalSupply', response / 1));
	nft.methods.owner().call().then((owner) => console.log('owner of nft contract', owner));
	nft.methods.balanceOf(user).call().then((response) => console.log('balanceOf ' + user, response / 1));
	nft.methods.cap().call().then((cap) => console.log('cap', cap * 1));
	const tokenId = 6;
	nft.methods.tokenURI(tokenId).call().then((res) => console.log('tokenUri of ' + tokenId, res));
	nft.methods.ownerOf(tokenId).call().then((owner) => console.log('owner of nft ' + tokenId, owner));
	// getTokensOfOwner(web3, '0xa4c65a9d0f892FBdA1EB04cC0634f1B94684F650', user).then((res) => console.log('getTokensOfOwner', res));

	/**
	* ==== Following testing methods is Send Tx ====
	*/
	const callContract = (encodeABI, contractAddress) => execContract(web3, chainId, priKey, encodeABI, contractAddress, null, null, null, null);	

	// let sendEncodeABI = nft.methods.increaseCap(1).encodeABI();
	// let sendEncodeABI = nft.methods.updateBaseTokenURI("https://dragonaire.com/").encodeABI();
	// let sendEncodeABI = nft.methods.mint(user).encodeABI();

	// let sendEncodeABI = nft.methods.updateTokenMetaData(1, 256).encodeABI();
	
	/** transfer testing
	* Acc#1 0x615b80388E3D3CaC6AA3a904803acfE7939f0399 30 id2=>acc#2
	* Acc#2 0xC4BFA07776D423711ead76CDfceDbE258e32474A 
	* Acc#3 0xF0Ab3FD4bf892BcB9b40B9c6B5a05e02f3afe833 
	* kov#1 0x3FE7995Bf0a505a51196aA11218b181c8497D236 
	* kov#2 0x0bD170e705ba74d6E260da59AF38EE3980Cf1ce3 
	* kov#3 0x3444E23231619b361c8350F4C83F82BCfAB36F65 
	*/

	// let sendEncodeABI = nft.methods.safeTransferFrom('0x615b80388E3D3CaC6AA3a904803acfE7939f0399', '0xC4BFA07776D423711ead76CDfceDbE258e32474A', 2).encodeABI();
	// callContract(sendEncodeABI, nftAddress)

	/**
	 * Transfer nft manager contract address to super account as owner to nft token, to manager the NFT
	 * This step is very important and sencitive !!!
	 * =========
	 * IMPORTANT:
	 * If you want to manager NFT as mystery box, the owner of nft must be nft-manager contract address, and use mint method to add mystery box
	 */
	// let sendEncodeABI = nftManager.methods.upgradeContract('0x615b80388E3D3CaC6AA3a904803acfE7939f0399').encodeABI();

	// Mint mystery box NFT, testing TokenId: #6
	// let sendEncodeABI = nftManager.methods.mint(user, 1).encodeABI();

	// Batch mint mystery box NFT, testing TokenId: #7, #8
	// let sendEncodeABI = nftManager.methods.mintBatch(user, 2, 2).encodeABI();
	
	// callContract(sendEncodeABI, nftManagerAddress);
});

