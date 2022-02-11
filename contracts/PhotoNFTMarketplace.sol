// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


import {PhotoNFT} from "./PhotoNFT.sol";
import {PhotoNFTTradable} from "./PhotoNFTTradable.sol";
import {PhotoNFTMarketplaceEvents} from "./photo-nft-marketplace/commons/PhotoNFTMarketplaceEvents.sol";
import {PhotoNFTData} from "./PhotoNFTData.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PhotoNFTMarketplace is PhotoNFTTradable, PhotoNFTMarketplaceEvents {
    using SafeMath for uint256;
    address public PHOTO_NFT_MARKETPLACE;

    // address private _market_owner;
    address public _market_owner;
    // address private _market_owner;
    address public token_banana;

    // address private _market_owner;
    address private rewardpool;
    // PhotoNFTData public photoNFTData;

    constructor(PhotoNFTData _photoNFTData, address owner,address _token_banana,address _rewardpool)
        public
        PhotoNFTTradable(_photoNFTData)
    {
        photoNFTData = _photoNFTData;
        token_banana = _token_banana;
        rewardpool = _rewardpool;
        address payable PHOTO_NFT_MARKETPLACE = payable(address(this));
        _market_owner = owner;
    }

    function getOwnerPayableAddress() public returns (address payable) {
        return payable(_market_owner);
    }

    /**
     * @notice - Buy function is that buy NFT token and ownership transfer. (Reference from IERC721.sol)
     * @notice - msg.sender buy NFT with ETH (msg.value)
     * @notice - PhotoID is always 1. Because each photoNFT is unique.
     */
    function buyPhotoNFT(PhotoNFT _photoNFT) public payable returns (bool) {
        PhotoNFT photoNFT = _photoNFT;

        PhotoNFTData.Photo memory photo = photoNFTData.getPhotoByNFTAddress(
            photoNFT
        );
        address _seller = photo.ownerAddress; // Owner
        // address payable seller = payable(_seller); // Convert owner address with payable
        uint256 buyAmount = photo.photoPrice;
        // require(
        //     msg.value == buyAmount,
        //     "msg.value should be equal to the buyAmount"
        // );

        // Bought-amount is transferred into a seller wallet
        IERC20(token_banana).transferFrom( 
            msg.sender,
            _seller,
            buyAmount.mul(70).div(100));

        IERC20(token_banana).transferFrom(
            msg.sender,
            rewardpool,
            buyAmount.mul(30).div(100));
        // seller.transfer(msg.value);

        // Approve a buyer address as a receiver before NFT's transferFrom method is executed
        address buyer = msg.sender;
        uint256 photoId = 1; // [Note]: PhotoID is always 1. Because each photoNFT is unique.
        photoNFT.approve(buyer, photoId);

        address ownerBeforeOwnershipTransferred = photoNFT.ownerOf(photoId);

        // Transfer Ownership of the PhotoNFT from a seller to a buyer
        transferOwnershipOfPhotoNFT(photoNFT, photoId, buyer);
        photoNFTData.updateOwnerOfPhotoNFT(photoNFT, buyer);
        photoNFTData.updateStatus(photoNFT, "Cancelled", 0);

        // Event for checking result of transferring ownership of a photoNFT
        address ownerAfterOwnershipTransferred = photoNFT.ownerOf(photoId);
        emit PhotoNFTOwnershipChanged(
            photoNFT,
            photoId,
            ownerBeforeOwnershipTransferred,
            ownerAfterOwnershipTransferred
        );

        // Mint a photo with a new photoId
        //string memory tokenURI = photoNFTFactory.getTokenURI(photoData.ipfsHashOfPhoto);  // [Note]: IPFS hash + URL
        //photoNFT.mint(msg.sender, tokenURI);
    }

    function transferMarketplaceOwnership(address newOwner)
        public
        returns (bool)
    {
        // only the owner can send this
        require(
            msg.sender == _market_owner,
            "sender should be the market owner"
        );
        //set the marketplace owner
        _market_owner = newOwner;
    }

    ///-----------------------------------------------------
    /// Methods below are pending methods
    ///-----------------------------------------------------

    /**
     * @dev reputation function is that gives reputation to a user who has ownership of being posted photo.
     * @dev Each user has reputation data in struct
     */
    function reputation(
        address from,
        address to,
        uint256 photoId
    ) public returns (uint256, uint256) {
        // Photo storage photo = photos[photoId];
        // photo.reputation = photo.reputation.add(1);

        // emit AddReputation(photoId, photo.reputation);

        // return (photoId, photo.reputation);
        return (0, 0);
    }

    function changeTokenContractAddress(address _newAddress)
        external
    {
        require(_market_owner == msg.sender,"Only owner is allowed");
        token_banana = _newAddress;
    }

    function changeRewardpoolAddress(address _newAddress)
        external
    {
        require(_market_owner == msg.sender,"Only owner is allowed");
        rewardpool = _newAddress;
    }
    function getReputationCount(uint256 photoId) public view returns (uint256) {
        uint256 curretReputationCount;

        // Photo memory photo = photos[photoId];
        // curretReputationCount = photo.reputation;

        return curretReputationCount;
    }
}
