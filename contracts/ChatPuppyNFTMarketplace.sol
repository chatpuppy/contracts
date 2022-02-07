// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/Context.sol";
import "./lib/Token/IERC165.sol";
import "./lib/Token/IERC721.sol";
import "./lib/Token/IERC20.sol";
import "./lib/Address.sol";
import "./lib/Token/SafeERC20.sol";
import "./lib/EnumerableSet.sol";
import "./interfaces/IAccessControl.sol";
import "./lib/Strings.sol";
import "./lib/Token/ERC165.sol";
import "./lib/AccessControl.sol";
import "./lib/AccessControlEnumerable.sol";
import "./lib/Counters.sol";

contract ChatPuppyNFTMarketplace is AccessControlEnumerable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    bytes32 public constant MAINTAINER_ROLE = keccak256("MAINTAINER_ROLE");

    struct Order {
        address seller;
        address buyer;
        uint256 tokenId;
        address paymentToken;
        uint256 price;
    }

    EnumerableSet.AddressSet private _supportedPaymentTokens;
    IERC721 public nftCore;
    uint256 public feeDecimal;
    uint256 public feeRate;
    address public feeRecipient;
    Counters.Counter private _orderIdTracker;

    mapping(uint256 => Order) public orders;
    EnumerableSet.UintSet private _onSaleOrders;
    mapping(address => EnumerableSet.UintSet) private _onSaleOrdersOfOwner;

    event OrderAdded(
        uint256 indexed orderId,
        address indexed seller,
        uint256 indexed tokenId,
        address paymentToken,
        uint256 price
    );
    event PriceUpdated(uint256 indexed orderId, uint256 price);
    event OrderCancelled(uint256 indexed orderId);
    event OrderMatched(
        uint256 indexed orderId,
        address indexed seller,
        address indexed buyer,
        uint256 tokenId,
        address paymentToken,
        uint256 price
    );
    event feeRateUpdated(uint256 feeDecimal, uint256 feeRate);

    constructor(
        address nftAddress_,
        address paymentToken_,
        uint256 feeDecimal_,
        uint256 feeRate_,
        address feeRecipient_
    ) {
        require(
            nftAddress_ != address(0),
            "ChatPuppyNFTMarketplace: nftAddress_ is zero address"
        );
        require(
            feeRecipient_ != address(0),
            "ChatPuppyNFTMarketplace: feeRecipient_ is zero address"
        );

        nftCore = IERC721(nftAddress_);
        _updateFeeRate(feeDecimal_, feeRate_);
        feeRecipient = feeRecipient_;
        _orderIdTracker.increment();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MAINTAINER_ROLE, _msgSender());

        _supportedPaymentTokens.add(paymentToken_);
    }

    modifier onlySupportedPaymentToken(address paymentToken_) {
        require(
            isPaymentTokenSupported(paymentToken_),
            "ChatPuppyNFTMarketplace: unsupport payment token"
        );
        _;
    }

    modifier onlyOnSaleOrder(uint256 orderId_) {
        require(
            _onSaleOrders.contains(orderId_),
            "ChatPuppyNFTMarketplace: order is not on sale"
        );
        _;
    }

    modifier onlyOnSaleOrderOfOwner(uint256 orderId_, address owner_) {
        require(
            _onSaleOrdersOfOwner[owner_].contains(orderId_),
            "ChatPuppyNFTMarketplace: order is not on sale"
        );
        _;
    }

    modifier canMatch(
        uint256 orderId_,
        address buyer_,
        uint256 price_
    ) {
        require(
            !isSeller(orderId_, buyer_),
            "ChatPuppyNFTMarketplace: buyer must be different from seller"
        );
        require(
            price_ == orders[orderId_].price,
            "ChatPuppyNFTMarketplace: price has been changed"
        );
        _;
    }

    function _calculateFee(uint256 orderId_) private view returns (uint256) {
        Order storage _order = orders[orderId_];
        if (feeRate == 0) {
            return 0;
        }

        return (feeRate * _order.price) / 10**(feeDecimal + 2);
    }

    function _updateFeeRate(uint256 feeDecimal_, uint256 feeRate_) internal {
        require(
            feeRate_ < 10**(feeDecimal_ + 2),
            "ChatPuppyNFTMarketplace: bad fee rate"
        );
        feeDecimal = feeDecimal_;
        feeRate = feeRate_;
        emit feeRateUpdated(feeDecimal_, feeRate_);
    }

    function isSeller(uint256 orderId_, address seller_)
        public
        view
        returns (bool)
    {
        return orders[orderId_].seller == seller_;
    }

    function supportedPaymentTokens() public view returns (address[] memory) {
        return _supportedPaymentTokens.values();
    }

    function onSaleOrderCount() public view returns (uint256) {
        return _onSaleOrders.length();
    }

    function onSaleOrderAt(uint256 index_) public view returns (uint256) {
        return _onSaleOrders.at(index_);
    }

    function onSaleOrders() public view returns (uint256[] memory) {
        return _onSaleOrders.values();
    }

    function onSaleOrderOfOwnerCount(address owner_)
        public
        view
        returns (uint256)
    {
        return _onSaleOrdersOfOwner[owner_].length();
    }

    function onSaleOrderOfOwnerAt(address owner_, uint256 index_)
        public
        view
        returns (uint256)
    {
        return _onSaleOrdersOfOwner[owner_].at(index_);
    }

    function onSaleOrdersOfOwner(address owner_)
        public
        view
        returns (uint256[] memory)
    {
        return _onSaleOrdersOfOwner[owner_].values();
    }

    function nextOrderId() public view returns (uint256) {
        return _orderIdTracker.current();
    }

    function updateNftCore(address _nftCoreAddress) external onlyRole(MAINTAINER_ROLE){
        nftCore = IERC721(_nftCoreAddress);
    }

    function updateFeeRecipient(address feeRecipient_) external onlyRole(MAINTAINER_ROLE){
        require(
            feeRecipient_ != address(0),
            "ChatPuppyNFTMarketplace: feeRecipient_ is zero address"
        );
        feeRecipient = feeRecipient_;
    }

    function updateFeeRate(uint256 feeDecimal_, uint256 feeRate_) external onlyRole(MAINTAINER_ROLE) {
        _updateFeeRate(feeDecimal_, feeRate_);
    }

    function addPaymentToken(address paymentToken_) external onlyRole(MAINTAINER_ROLE) {
        require(paymentToken_ != address(0), "ChatPuppyNFTMarketplace: payment token is zero address");
        require(_supportedPaymentTokens.add(paymentToken_), "ChatPuppyNFTMarketplace: already supported");
    }

    function isPaymentTokenSupported(address paymentToken_) public view returns (bool){
        return _supportedPaymentTokens.contains(paymentToken_);
    }

    function addOrder(
        uint256 tokenId_,
        address paymentToken_,
        uint256 price_
    ) public onlySupportedPaymentToken(paymentToken_)
    {
        require(
            nftCore.ownerOf(tokenId_) == _msgSender(),
            "ChatPuppyNFTMarketplace: sender is not owner of token"
        );
        require(
            nftCore.getApproved(tokenId_) == address(this) || nftCore.isApprovedForAll(_msgSender(), address(this)),
            "ChatPuppyNFTMarketplace: The contract is unauthorized to manage this token"
        );
        require(
            price_ > 0,
            "ChatPuppyNFTMarketplace: price must be greater than 0"
        );

        uint256 _orderId = _orderIdTracker.current();
        Order storage _order = orders[_orderId];
        _order.seller = _msgSender();
        _order.tokenId = tokenId_;
        _order.paymentToken = paymentToken_;
        _order.price = price_;
        _orderIdTracker.increment();

        _onSaleOrders.add(_orderId);
        _onSaleOrdersOfOwner[_msgSender()].add(_orderId);

        nftCore.transferFrom(_msgSender(), address(this), tokenId_);

        emit OrderAdded(
            _orderId,
            _msgSender(),
            tokenId_,
            paymentToken_,
            price_
        );
    }

    function updatePrice(uint256 orderId_, uint256 price_)
        public
        onlyOnSaleOrderOfOwner(orderId_, _msgSender())
    {
        require(
            price_ > 0,
            "ChatPuppyNFTMarketplace: price must be greater than 0"
        );
        Order storage _order = orders[orderId_];
        _order.price = price_;

        emit PriceUpdated(orderId_, price_);
    }

    function cancelOrder(uint256 orderId_)
        external
        onlyOnSaleOrderOfOwner(orderId_, _msgSender())
    {
        Order storage _order = orders[orderId_];
        _onSaleOrders.remove(orderId_);
        _onSaleOrdersOfOwner[_msgSender()].remove(orderId_);

        nftCore.transferFrom(address(this), _msgSender(), _order.tokenId);
        emit OrderCancelled(orderId_);
    }

    function matchOrder(uint256 orderId_, uint256 price_)
        external
        payable
        onlyOnSaleOrder(orderId_)
        canMatch(orderId_, _msgSender(), price_)
    {
        Order storage _order = orders[orderId_];
        _order.buyer = _msgSender();
        _onSaleOrders.remove(orderId_);
        _onSaleOrdersOfOwner[_order.seller].remove(orderId_);

        uint256 _feeAmount = _calculateFee(orderId_);
        if (_feeAmount > 0) {
            // if(_order.paymentToken == address(0)) {
            //     // Don't do anything cause the chain token has been in the contract,
            //     // The fee will store in the contract untill the owner withdraw from contract
            // } else {
                // paid by ERC20
                IERC20(_order.paymentToken).safeTransferFrom(
                    _msgSender(),
                    feeRecipient,
                    _feeAmount
                );
            // }
        }
        // if(_order.paymentToken == address(0)) {
        //     // paid from contract to the seller by chain token
        //     (bool sent, ) = _order.seller.call{value: _order.price - _feeAmount}("");
        //     require(sent, "ChatPuppyNFTMarketplace: Failed to send to seller by Ether");
        // } else {
            // paid by ERC20
            IERC20(_order.paymentToken).safeTransferFrom(
                _msgSender(),
                _order.seller,
                _order.price - _feeAmount
            );
        // }

        nftCore.transferFrom(address(this), _msgSender(), _order.tokenId);

        emit OrderMatched(
            orderId_,
            _order.seller,
            _order.buyer,
            _order.tokenId,
            _order.paymentToken,
            _order.price
        );
    }
}