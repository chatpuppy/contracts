// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./lib/Context.sol";
import "./lib/AccessControl.sol";
import "./lib/Address.sol";
import "./lib/Token/ERC721.sol";
import "./lib/Ownable.sol";
import "./lib/Token/IERC721Enumerable.sol";
import "./lib/Token/ERC721Burnable.sol";
import "./lib/AccessControlEnumerable.sol";
import "./lib/Token/ERC721Enumerable.sol";
import "./lib/Token/ERC721Pausable.sol";
import "./lib/Counters.sol";
import "./interfaces/IItemFactory.sol";

contract ChatPuppyNFTCore is
    Ownable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable
{
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;
    uint256 private _cap;

    struct Item {
        bytes32 dna;
        uint256 artifacts;
    }

    mapping(uint256 => Item) private _items;

    mapping(uint256 => string) private _tokenURIs;

    event CapUpdated(uint256 cap);
    event UpdateTokenURI(uint256 indexed tokenId, string tokenURI);
    event UpdateMetadata(uint256 indexed tokenId, bytes32 dna, uint256 artifacts);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialCap_
    ) ERC721(name_, symbol_) {
        require(initialCap_ > 0, "ChatPuppyNFTCore: cap is 0");
        _updateCap(initialCap_);
        _tokenIdTracker.increment();
    }

    function _mint(address to_, uint256 tokenId_) internal virtual override {
        require(
            ERC721Enumerable.totalSupply() < cap(),
            "ChatPuppyNFTCore: cap exceeded"
        );
        super._mint(to_, tokenId_);
    }

    function _updateCap(uint256 cap_) private {
        _cap = cap_;
        emit CapUpdated(cap_);
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }

    function exists(uint256 tokenId_) external view returns (bool) {
        return _exists(tokenId_);
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    function increaseCap(uint256 amount_) public onlyOwner {
        require(amount_ > 0, "ChatPuppyNFTCore: amount is 0");

        uint256 newCap = cap() + amount_;
        _updateCap(newCap);
    }

    function mint(address to_) public onlyOwner returns (uint256) {
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        uint256 _tokenId = _tokenIdTracker.current();
        _mint(to_, _tokenId);
        _tokenIdTracker.increment();

        return _tokenId;
    }

    /**
     * @dev Batch mint
     */
    function mintBatch(address to_, uint256 amount_) public onlyOwner {
        require(amount_ > 0, "ChatPuppyNFT: amount_ is 0");
        require(totalSupply() + amount_ <= cap(), "cap exceeded");

        for (uint256 i = 0; i < amount_; i++) {
            mint(to_);
        }
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must be owner.
     */
    function pause() public virtual onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must be owner.
     */
    function unpause() public virtual onlyOwner {
        _unpause();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId_) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId_);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
        require(
            _exists(tokenId_),
            "ChatPuppyNFTCore: URI query for nonexistent token"
        );
        return _tokenURIs[tokenId_];
    }

    function updateTokenMetaData(uint256 tokenId_, uint256 artifacts_) external onlyOwner {
        require(_exists(tokenId_), "ChatPuppyNFTCore: tokeId not exists");

        Item storage _info = _items[tokenId_];
        _info.artifacts = artifacts_;
    }

    function updateTokenMetaData(uint256 tokenId_, uint256 artifacts_, bytes32 dna_) external onlyOwner {
        require(_exists(tokenId_), "ChatPuppyNFTCore: tokeId not exists");

        Item storage _info = _items[tokenId_];
        _info.artifacts = artifacts_;

        if (dna_ != 0 && _info.dna == 0) {
            _info.dna = dna_;
        }
        emit UpdateMetadata(tokenId_, dna_, artifacts_);
    }

    function updateTokenURI(uint256 tokenId_, string calldata uri_) external {
        require(_exists(tokenId_), "ChatPuppyNFTCore: tokeId not exists");
        require((ownerOf(tokenId_) == _msgSender() && bytes(_tokenURIs[tokenId_]).length == 0)
            || _msgSender() == owner(), "ChatPuppyNFTCore: owner of nft can only set once, contract owner can set always");
        _tokenURIs[tokenId_] = uri_;
        emit UpdateTokenURI(tokenId_, uri_);
    }

    function tokenMetaData(uint256 tokenId_) external view returns (bytes32 _dna, uint256 _artifacts, string memory _hexArtifacts) {
        _dna = _items[tokenId_].dna;
        _artifacts = _items[tokenId_].artifacts;
        _hexArtifacts = _items[tokenId_].artifacts.toHexString();
    }
}