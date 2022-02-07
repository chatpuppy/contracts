/**
 * Testing NFT Manager(Mystery box)
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

const nftManagerAddress = '0xd79142Bb9aa94055751FF14F299F6Aa5253AE2C7';
const nftManagerJson = require('../build/contracts/ChatPuppyNFTManager.json');
const nftJson = require('../build/contracts/ChatPuppyNFTCore.json');

const nftManager = new web3.eth.Contract(nftManagerJson.abi, nftManagerAddress);
const user = '0x615b80388E3D3CaC6AA3a904803acfE7939f0399';

const tokenId = 1;
nftManager.methods.boxStatus(tokenId).call().then((result) => console.log('canUnbox ' + result));

nftManager.methods.nftCore().call().then((nftAddress) => {
	console.log('nft Address', nftAddress); // 0x91A568eF27D75db2faBe21e8ad8F947FB42F9bAa
	const nft = new web3.eth.Contract(nftJson.abi, nftAddress);
	nft.methods.name().call().then((response) => console.log('nft name', response));
	nft.methods.totalSupply().call().then((response) => console.log('totalSupply', response / 1));
	nft.methods.owner().call().then((owner) => console.log('owner of nft contract', owner));
	nft.methods.balanceOf(user).call().then((response) => console.log('balanceOf ' + user, response / 1));
	nft.methods.cap().call().then((cap) => console.log('cap', cap * 1));
	
	nft.methods.tokenURI(tokenId).call().then((res) => console.log('tokenUri of ' + tokenId, res));
	nft.methods.ownerOf(tokenId).call().then((owner) => console.log('owner of nft ' + tokenId, owner));
	nft.methods.tokenMetaData(tokenId).call().then((metaData) => console.log('metadata of nft ' + tokenId, metaData));
	// // token id: 8, artifacts: 31557149308712695702487117390359031863579641058793881665793
	// hex: 5070003060002000000000000000000000000000000000000
	// box type: 1
	// item type: 1
	// item id: 5(ChatPuppy)
	// artifacts: 05070003060002 ? 

	// token id: 9, artifacts: 19002945463794915018104391483800381860728843057866773430529
	// hex: 3070002060002000000000000000000000000000000000000


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

	// Mint mystery box NFT
	// let sendEncodeABI = nftManager.methods.mint(user, 1).encodeABI();

	// Batch mint mystery box NFT
	// BUG: Can only batch mint 3 nfts one time.
	// let sendEncodeABI = nftManager.methods.mintBatch(user, 1, 3).encodeABI();
	
	// Unbox mystery box
	// let sendEncodeABI = nftManager.methods.unbox(3).encodeABI();

	// callContract(sendEncodeABI, nftManagerAddress);
});

