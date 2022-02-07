// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "../interfaces/IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "./AccessControlEnumerable.sol";
import "./Context.sol";
import "./Strings.sol";
import "./Token/ERC165.sol";
import "./EnumerableSet.sol";
import "./Token/SafeERC20.sol";
import "./Token/IWETH.sol";
import "../interfaces/IRandomGenerator.sol";
import "../interfaces/IRandomConsumer.sol";
import "../interfaces/LinkTokenInterface.sol";
import "./VRFConsumerBase.sol";
// import "./BuyLink.sol";
// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract ChainLinkRandomGenerator is
    AccessControlEnumerable,
    IRandomGenerator,
    VRFConsumerBase
{
    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant CONSUMER_ROLE = keccak256("CONSUMER_ROLE");

    struct RequestPayload {
        address requester;
        uint256 tokenId;
    }

    mapping(bytes32 => RequestPayload) private _requestIdToRequestPayload;
    mapping(uint256 => uint256) private _tokenIdToRandomNumber;

    IERC20 public immutable linkToken;
    bytes32 internal immutable keyHash;
    uint256 internal immutable fee;

    event WithdrawLink(address indexed receiver, uint256 amount);

    constructor(
        address vrfCoordinator_,
        address link_,
        bytes32 keyHash_,
        uint256 fee_
    )
        VRFConsumerBase(vrfCoordinator_, link_)
    {
        keyHash = keyHash_;
        fee = fee_;
        linkToken = IERC20(link_);

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
        _setupRole(CONSUMER_ROLE, _msgSender());
    }

    receive() external payable {}

    /**
     * Requests randomness
     */
    function requestRandomNumber(uint256 tokenId_) public {
        require(
            hasRole(CONSUMER_ROLE, _msgSender()),
            "ChainLinkRandomGenerator: must have consumer role to request"
        );
        require(
            _tokenIdToRandomNumber[tokenId_] == uint256(0),
            "ChainLinkRandomGenerator: random number for token is already exist"
        );
        require(
            LINK.balanceOf(address(this)) >= fee,
            "ChainLinkRandomGenerator: not enough LINK"
        );

        bytes32 _requestId = requestRandomness(keyHash, fee);

        RequestPayload storage _payload = _requestIdToRequestPayload[
            _requestId
        ];
        _payload.tokenId = tokenId_;
        _payload.requester = _msgSender();
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId_, uint256 randomness_) internal override {
        RequestPayload storage _payload = _requestIdToRequestPayload[
            requestId_
        ];

        if (randomness_ == uint256(0)) {
            randomness_ = uint256(1); // Handle special value
        }

        _tokenIdToRandomNumber[_payload.tokenId] = randomness_;

        IRandomConsumer _consumer = IRandomConsumer(_payload.requester);
        _consumer.rawFulfillRandomness(_payload.tokenId, randomness_);

        delete _requestIdToRequestPayload[requestId_];
    }

    function getResultByTokenId(uint256 tokenId_) public view returns (uint256) {
        return _tokenIdToRandomNumber[tokenId_];
    }

    function withdrawLink(uint256 amount_) external {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "ChainLinkRandomGenerator: must have operator role to withdraw"
        );
        require(
            linkToken.balanceOf(address(this)) >= amount_,
            "ChainLinkRandomGenerator: amount exceeds balance"
        );

        linkToken.safeTransfer(_msgSender(), amount_);
        emit WithdrawLink(_msgSender(), amount_);
    }

    function withdrawBnb(uint256 amount_) external {
        require(
            hasRole(OPERATOR_ROLE, _msgSender()),
            "ChainLinkRandomGenerator: must have operator role to withdraw"
        );

        (bool success, ) = address(_msgSender()).call{value: amount_}(
            new bytes(0)
        );
        require(success, "ChainLinkRandomGenerator: insufficient balance");
    }
}