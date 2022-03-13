import { createRequire } from "module"; // Bring in the ability to create the 'require' method
import {default as common} from 'ethereumjs-common';
import { exit } from "process";
const require = createRequire(import.meta.url); // construct the require method
const Common = common.default
const Tx = require('ethereumjs-tx');

const BSC_MAIN = Common.forCustomChain(
	'mainnet', {
			name: 'bnb',
			networkId: 56, 
			chainId: 56
	}, 
	'istanbul'
)

const BSC_TEST = Common.forCustomChain(
	'mainnet', {
			name: 'bnb',
			networkId: 97, 
			chainId: 97
	}, 
	'istanbul'
)

export const execContract = (web3, chainId, priKey, sendEncodeABI, value, contractAddress, onTransactionHashFun, onConfirmedFunc, onReceiptFunc, onErrorFunc) => {
	const senderAddress = (web3.eth.accounts.privateKeyToAccount('0x' + priKey)).address;
		
	try {
		web3.eth.getTransactionCount(senderAddress).then((transactionNonce) => {
			const txData = {
				chainId,
				nonce: web3.utils.toHex(transactionNonce),
				gasLimit: web3.utils.toHex(500000),
				gasPrice: web3.utils.toHex(10000000000),
				value: web3.utils.toHex(value),
				to: contractAddress,
				from: senderAddress,
				data: sendEncodeABI
			};
	
			sendRawTransaction(web3, txData, priKey)
					.on('transactionHash', txHash => {
						console.log('transactionHash:', txHash)
						if(onTransactionHashFun !== null) onTransactionHashFun(txHash);
					})
					.on('receipt', receipt => {
						console.log('receipt:', receipt)
						if(onReceiptFunc !== null) onReceiptFunc(receipt);
					})
					.on('confirmation', (confirmationNumber, receipt) => {
						if(confirmationNumber >=1 && confirmationNumber < 2) {
							console.log('confirmations:', confirmationNumber);
							if(onConfirmedFunc !== null) onConfirmedFunc(confirmationNumber, receipt);
							// exit(0);
						}
					})
					.on('error:', error => {
						console.error(error)
						if(onErrorFunc !== null) onErrorFunc(error);
					})
		});
	} catch (err) {
		onErrorFunc(err);
	}
}

const sendRawTransaction = (web3, txData, priKey) => {
	// const transaction = new Tx(txData, {common: BSC_TEST});
	const transaction = new Tx(txData, {chain: 'kovan'});
	const privateKey = new Buffer.from(priKey, "hex");
	transaction.sign(privateKey);
	const serializedTx = transaction.serialize().toString('hex');
	return web3.eth.sendSignedTransaction('0x' + serializedTx);
}
