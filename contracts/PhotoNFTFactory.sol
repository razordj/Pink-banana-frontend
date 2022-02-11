// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Strings} from "./libraries/Strings.sol";
import {PhotoNFTFactoryStorages} from "./photo-nft-factory/commons/PhotoNFTFactoryStorages.sol";
import {PhotoNFT} from "./PhotoNFT.sol";
import {PhotoNFTMarketplace} from "./PhotoNFTMarketplace.sol";
import {PhotoNFTData} from "./PhotoNFTData.sol";

/**
 * @notice - This is the factory contract for a NFT of photo
 */
contract PhotoNFTFactory is PhotoNFTFactoryStorages {
    using Strings for string;

    // error FeeNotSufficient();

    address[] public photoAddresses;
    address PHOTO_NFT_MARKETPLACE;

    PhotoNFTMarketplace public photoNFTMarketplace;
    PhotoNFTData public photoNFTData;

    constructor(
        PhotoNFTMarketplace _photoNFTMarketplace,
        PhotoNFTData _photoNFTData
    ) public {
        photoNFTMarketplace = _photoNFTMarketplace;
        photoNFTData = _photoNFTData;
        PHOTO_NFT_MARKETPLACE = address(photoNFTMarketplace);
    }

    /**
     * @notice - Create a new photoNFT when a seller (owner) upload a photo onto IPFS
     */
    function createNewPhotoNFT(
        string memory nftName,
        // string memory nftSymbol,
        uint256 photoPrice,
        string memory ipfsHashOfPhoto,
        string memory description,
        string memory collection,
        uint256 amount
    ) public payable returns (bool) {
        address owner = msg.sender; // [Note]: Initial owner of photoNFT is msg.sender

        uint256 feeValue = photoPrice / 20;
        require(msg.value == feeValue, "Fee must be paid");

        //transfer fee

        address payable marketOwner = photoNFTMarketplace
            .getOwnerPayableAddress();
        marketOwner.transfer(feeValue);

        for (uint256 i = 0; i < amount; i++) {
            string memory tokenName = nftName;
            // string memory tokenSymbol = nftSymbol;
            string memory tokenDes = description;
            string memory tokenPhoto = ipfsHashOfPhoto;
            string memory tokenCollect = collection;
            uint256 tokenPrice = photoPrice;
            string memory tokenURI = getTokenURI(tokenPhoto); // [Note]: IPFS hash + URL
            PhotoNFT photoNFT = new PhotoNFT(
                owner,
                tokenName,
                // tokenSymbol,
                tokenURI,
                tokenPrice,
                tokenDes,
                tokenCollect
            );
            photoAddresses.push(address(photoNFT));

            // Save metadata of a photoNFT created
            photoNFTData.saveMetadataOfPhotoNFT(
                photoAddresses,
                photoNFT,
                tokenName,
                // tokenSymbol,
                msg.sender,
                tokenPrice,
                tokenPhoto,
                tokenDes,
                tokenCollect
            );
            // photoNFTData.updateStatus(photoNFT, "Open", tokenPrice);
            photoNFTMarketplace.registerTradeWhenCreateNewPhotoNFT(
                photoNFT,
                1,
                tokenPrice,
                msg.sender
            );

            emit PhotoNFTCreated(
                msg.sender,
                photoNFT,
                tokenName,
                // tokenSymbol,
                tokenPrice,
                tokenPhoto
            );
        }
    }

    ///-----------------
    /// Getter methods
    ///-----------------
    function baseTokenURI() public pure returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function getTokenURI(string memory _ipfsHashOfPhoto)
        public
        view
        returns (string memory)
    {
        return Strings.strConcat(baseTokenURI(), _ipfsHashOfPhoto);
    }
}
