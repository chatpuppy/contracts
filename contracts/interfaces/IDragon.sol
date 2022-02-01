//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IDragon {
    struct Dragon {
        string name;
        uint level;
        uint floorPrice;
        uint mainWeapon;
        uint subWeapon;
        uint headgear;
        uint armor;
        uint footwear;
        uint pants;
        uint gloves;
        uint mount;
        uint troop;
    }

    struct Version {
        uint startingIndex;
        uint currentSupply;
        uint maxSupply;
        uint salePrice;
        uint startTime;
        uint revealTime;
        string provenance; // This is the provenance record of all MoonDragon artworks in existence.
    }

    event DragonCreated(uint indexed knightId, uint floorPrice);
    event DragonListed(uint indexed knightId, uint price);
    event DragonDelisted(uint indexed knightId);
    event DragonBought(uint indexed knightId, address buyer, address seller, uint price);
    event DragonOffered(uint indexed knightId, address buyer, uint price);
    event DragonOfferCanceled(uint indexed knightId, address buyer);
    event DragonPriceIncreased(uint indexed knightId, uint floorPrice, uint increasedAmount);
    event NameChanged(uint indexed knightId, string newName);
    event PetAdopted(uint indexed knightId, uint indexed petId);
    event PetReleased(uint indexed knightId, uint indexed petId);
    event SkillLearned(uint indexed knightId, uint indexed skillId);
    event ItemsEquipped(uint indexed knightId, uint[] itemIds);
    event ItemsUnequipped(uint indexed knightId, uint[] itemIds);
    event DragonLeveledUp(uint indexed knightId, uint level, uint amount);
    event DuelConcluded(uint indexed winningDragonId, uint indexed losingDragonId, uint penaltyAmount);
    event StartingIndexFinalized(uint versionId, uint startingIndex);
    event NewVersionAdded(uint versionId);

    /**
     * @notice Claims moon knights when it's on presale phase.
     */
    function claimMoonDragon(uint versionId, uint amount) external payable;

    /**
     * @notice Changes a knight's name.
     *
     * Requirements:
     * - `newName` must be a valid string.
     * - `newName` is not duplicated to other.
     * - Token required: `serviceFeeInToken`.
     */
    function changeDragonName(uint knightId, string memory newName) external;

    /**
     * @notice Anyone can call this function to manually add `floorPrice` to a knight.
     *
     * Requirements:
     * - `msg.value` must not be zero.
     * - knight's `floorPrice` must be under `floorPriceCap`.
     * - Token required: `serviceFeeInToken` * value
     */
    function addFloorPriceToDragon(uint knightId) external payable;

    /**
     * @notice Owner equips items to their knight by burning ERC1155 Equipment NFTs.
     *
     * Requirements:
     * - caller must be owner of the knight.
     */
    function equipItems(uint knightId, uint[] memory itemIds) external;

    /**
     * @notice Owner removes items from their knight. ERC1155 Equipment NFTs are minted back to the owner.
     *
     * Requirements:
     * - caller must be owner of the knight.
     */
    function removeItems(uint knightId, uint[] memory itemIds) external;

    /**
     * @notice Burns a knight to claim its `floorPrice`.
     *
     * - Not financial advice: DONT DO THAT.
     * - Remember to remove all items before calling this function.
     */
    function sacrificeDragon(uint knightId) external;

    /**
     * @notice Lists a knight on sale.
     *
     * Requirements:
     * - `price` cannot be under knight's `floorPrice`.
     * - Caller must be the owner of the knight.
     */
    function list(uint knightId, uint price) external;

    /**
     * @notice Delist a knight on sale.
     */
    function delist(uint knightId) external;

    /**
     * @notice Instant buy a specific knight on sale.
     *
     * Requirements:
     * - Target knight must be currently on sale.
     * - Sent value must be exact the same as current listing price.
     */
    function buy(uint knightId) external payable;

    /**
     * @notice Gives offer for a knight.
     *
     * Requirements:
     * - Owner cannot offer.
     */
    function offer(uint knightId, uint offerValue) external payable;

    /**
     * @notice Owner take an offer to sell their knight.
     *
     * Requirements:
     * - Cannot take offer under knight's `floorPrice`.
     * - Offer value must be at least equal to `minPrice`.
     */
    function takeOffer(uint knightId, address offerAddr, uint minPrice) external;

    /**
     * @notice Cancels an offer for a specific knight.
     */
    function cancelOffer(uint knightId) external;

    /**
     * @notice Learns a skill for given Dragon.
     */
    function learnSkill(uint knightId, uint skillId) external;

    /**
     * @notice Adopts a Pet.
     */
    function adoptPet(uint knightId, uint petId) external;

    /**
     * @notice Abandons a Pet attached to a Dragon.
     */
    function abandonPet(uint knightId) external;

    /**
     * @notice Operators can level up a Dragon
     */
    function levelUp(uint knightId, uint amount) external;

    /**
     * @notice Finalizes the battle aftermath of 2 knights.
     */
    function finalizeDuelResult(uint winningDragonId, uint losingDragonId, uint penaltyInBps) external;

    /**
     * @notice Gets knight information.
     */
    function getDragon(uint knightId) external view returns (
        string memory name,
        uint level,
        uint floorPrice,
        uint pet,
        uint[] memory skills,
        uint[9] memory equipment
    );

    /**
     * @notice Gets current level of given knight.
     */
    function getDragonLevel(uint knightId) external view returns (uint);
}