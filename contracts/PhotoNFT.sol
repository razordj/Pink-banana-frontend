// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract PhotoNFT is ERC721URIStorage {
    uint256 public currentPhotoId;
    mapping(string => bool) public tokenURI_status;
    mapping(string => bool) public nftName_status;

     constructor (
        address owner,
        string memory _nftName,
        // string memory _nftSymbol,
        string memory _tokenURI,
        uint256 photoPrice,
        string memory desc,
        string memory tokenCollect
    ) public ERC721(_nftName, "CIZDE") {
        //check tokenURI is used already
        require(
            tokenURI_status[_tokenURI] !=  true,
            "Duplicate token URI."
        );

        //check nftName is used already
        require(
            nftName_status[_nftName] !=  true,
            "Duplicate nftName."
        );

        tokenURI_status[_tokenURI] =  true;
        nftName_status[_nftName] =  true;

        mint(owner, _tokenURI);
    }

    /**
     * @dev mint a photoNFT
     * @dev tokenURI - URL include ipfs hash
     */
    function mint(address to,string memory tokenURI) public  returns (uint256) {
        
        uint256 newPhotoId = getNextPhotoId();
        currentPhotoId++;

        _mint(to, newPhotoId);
        _setTokenURI(newPhotoId, tokenURI);
        return newPhotoId;
    }

    ///--------------------------------------
    /// Getter methods
    ///--------------------------------------

    ///--------------------------------------
    /// Private methods
    ///--------------------------------------
    /**
     * @return nextPhotoId
     */
    function getNextPhotoId() private view returns (uint256 nextPhotoId) {
        return currentPhotoId + 1;
    }
}
